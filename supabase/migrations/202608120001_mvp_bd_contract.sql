-- MVP Bangladesh contract: nationwide corridor matching, recipient contact,
-- admin staging wallet credit, storage buckets, lock-amount hardening, and
-- safe status-transition guards. Additive only — does not rewrite initial schema.

-- ---------------------------------------------------------------------------
-- Packages: recipient contact (phone required, name optional)
-- ---------------------------------------------------------------------------
alter table public.packages
  add column if not exists recipient_phone text,
  add column if not exists recipient_name text;

update public.packages
set recipient_phone = coalesce(nullif(btrim(recipient_phone), ''), 'UNSET')
where recipient_phone is null or nullif(btrim(recipient_phone), '') is null;

alter table public.packages
  alter column recipient_phone set not null;

do $$
begin
  if not exists (
    select 1 from pg_constraint
    where conname = 'packages_recipient_phone_nonempty'
      and conrelid = 'public.packages'::regclass
  ) then
    alter table public.packages
      add constraint packages_recipient_phone_nonempty
      check (nullif(btrim(recipient_phone), '') is not null);
  end if;
end;
$$;

create index if not exists packages_dropoff_location_idx
  on public.packages using gist (dropoff_location);

comment on column public.packages.recipient_phone is
  'Required contact phone for the parcel recipient (Bangladesh numbers preferred).';
comment on column public.packages.recipient_name is
  'Optional display name for the parcel recipient.';

-- ---------------------------------------------------------------------------
-- Trusted status updates (deal RPCs set a transaction-local flag)
-- ---------------------------------------------------------------------------
create or replace function public.mark_trusted_status_update()
returns void
language plpgsql
security definer
set search_path = pg_catalog, public
as $$
begin
  perform set_config('corridorshare.trusted_status_update', '1', true);
end;
$$;

revoke all on function public.mark_trusted_status_update() from public, anon, authenticated;

create or replace function public.enforce_package_status_guard()
returns trigger
language plpgsql
set search_path = pg_catalog, public
as $$
begin
  if tg_op = 'UPDATE'
     and new.status is distinct from old.status
     and current_setting('corridorshare.trusted_status_update', true) is distinct from '1' then
    -- Clients may cancel or mark matched for UX; delivered/in_transit are RPC-owned.
    if new.status in ('delivered', 'in_transit') then
      raise exception 'Package status % may only be set by authorized deal functions', new.status
        using errcode = '42501';
    end if;
    if old.status = 'delivered' then
      raise exception 'Delivered packages cannot change status via client update'
        using errcode = '42501';
    end if;
  end if;
  return new;
end;
$$;

drop trigger if exists packages_status_guard on public.packages;
create trigger packages_status_guard
before update on public.packages
for each row execute function public.enforce_package_status_guard();

create or replace function public.enforce_trip_status_guard()
returns trigger
language plpgsql
set search_path = pg_catalog, public
as $$
begin
  if tg_op = 'UPDATE'
     and new.status is distinct from old.status
     and current_setting('corridorshare.trusted_status_update', true) is distinct from '1' then
    if old.status = 'completed' and new.status <> 'completed' then
      raise exception 'Completed trips cannot change status via client update'
        using errcode = '42501';
    end if;
  end if;
  return new;
end;
$$;

drop trigger if exists trips_status_guard on public.trips;
create trigger trips_status_guard
before update on public.trips
for each row execute function public.enforce_trip_status_guard();

-- ---------------------------------------------------------------------------
-- Matching: pickup AND dropoff near any BD LineString; weight ≤ capacity
-- ---------------------------------------------------------------------------
create or replace function public.match_packages_within_corridor(
  traveler_trip_id uuid,
  buffer_distance_meters double precision default 3000.0
)
returns table (
  package_id uuid,
  sender_id uuid,
  item_description text,
  item_type text,
  proposed_reward_minor bigint,
  is_premium boolean,
  distance_from_corridor double precision,
  is_near_miss boolean,
  pickup_lat double precision,
  pickup_lng double precision,
  pickup_radius_meters integer
)
language plpgsql
security definer
set search_path = pg_catalog, public
as $$
declare
  traveler_route extensions.geometry;
  trip_capacity numeric(7, 2);
begin
  if buffer_distance_meters < 100 or buffer_distance_meters > 50000 then
    raise exception 'Buffer distance must be between 100 and 50000 meters' using errcode = '22023';
  end if;

  select t.route_path, t.weight_capacity_kg
  into traveler_route, trip_capacity
  from public.trips t
  where t.id = traveler_trip_id and t.traveler_id = auth.uid();

  if traveler_route is null then
    raise exception 'Trip not found or not owned by caller' using errcode = '42501';
  end if;

  -- Any user-defined Bangladesh LineString works; no corridor catalog is required.
  return query
  select
    p.id,
    p.sender_id,
    p.item_description,
    p.item_type,
    p.proposed_reward_minor,
    p.is_premium,
    extensions.st_distance(
      p.pickup_location::extensions.geography,
      traveler_route::extensions.geography
    ),
    extensions.st_distance(
      p.pickup_location::extensions.geography,
      traveler_route::extensions.geography
    ) > p.pickup_radius_meters,
    extensions.st_y(p.pickup_location),
    extensions.st_x(p.pickup_location),
    p.pickup_radius_meters
  from public.packages p
  where p.status = 'pending'
    and p.sender_id <> auth.uid()
    and (p.weight_kg is null or p.weight_kg <= trip_capacity)
    and extensions.st_dwithin(
      p.pickup_location::extensions.geography,
      traveler_route::extensions.geography,
      buffer_distance_meters
    )
    and extensions.st_dwithin(
      p.dropoff_location::extensions.geography,
      traveler_route::extensions.geography,
      buffer_distance_meters
    )
  order by p.is_premium desc, extensions.st_distance(
    p.pickup_location::extensions.geography,
    traveler_route::extensions.geography
  );
end;
$$;

comment on function public.match_packages_within_corridor(uuid, double precision) is
  'Returns pending packages whose pickup AND dropoff are within buffer meters of the caller-owned trip LineString (any Bangladesh route). Packages with weight_kg set must fit trip weight_capacity_kg; null weight is allowed.';

-- ---------------------------------------------------------------------------
-- Lock amount hardening: prefer agreed deal price, else package proposed reward
-- ---------------------------------------------------------------------------
-- Rule (documented):
--   lock_amount := coalesce(deal.final_agreed_price_minor, package.proposed_reward_minor)
--   Client p_amount_minor must equal lock_amount. Travelers cannot invent a
--   different escrow amount at lock time.
create or replace function public.lock_deal_with_inspection(
  p_deal_id uuid,
  p_amount_minor bigint,
  p_inspection_photo_url text,
  p_idempotency_key text
)
returns public.chats_and_deals
language plpgsql
security definer
set search_path = pg_catalog, public
as $$
declare
  deal_record public.chats_and_deals;
  deal_lookup record;
  package_sender_id uuid;
  trip_traveler_id uuid;
  package_reward bigint;
  lock_amount bigint;
begin
  if p_amount_minor <= 0 then
    raise exception 'Amount must be positive' using errcode = '22023';
  end if;
  if nullif(btrim(p_inspection_photo_url), '') is null then
    raise exception 'Inspection photo is required' using errcode = '22023';
  end if;
  if nullif(btrim(p_idempotency_key), '') is null then
    raise exception 'Idempotency key is required' using errcode = '22023';
  end if;

  select d as deal, p.sender_id as sender_id, t.traveler_id,
         p.proposed_reward_minor as package_reward
  into deal_lookup
  from public.chats_and_deals d
  join public.packages p on p.id = d.package_id
  join public.trips t on t.id = d.trip_id
  where d.id = p_deal_id
  for update of d;

  if not found then
    raise exception 'Deal not found or caller is not the traveler' using errcode = '42501';
  end if;

  deal_record := deal_lookup.deal;
  package_sender_id := deal_lookup.sender_id;
  trip_traveler_id := deal_lookup.traveler_id;
  package_reward := deal_lookup.package_reward;

  if trip_traveler_id <> auth.uid() then
    raise exception 'Deal not found or caller is not the traveler' using errcode = '42501';
  end if;

  lock_amount := coalesce(deal_record.final_agreed_price_minor, package_reward);
  if lock_amount is null or lock_amount <= 0 then
    raise exception 'No agreed package reward available to lock' using errcode = '22023';
  end if;
  if p_amount_minor <> lock_amount then
    raise exception 'Lock amount must equal agreed package reward (% poisha)', lock_amount
      using errcode = '22023';
  end if;

  if exists (
    select 1 from public.wallet_transactions
    where profile_id = package_sender_id and idempotency_key = p_idempotency_key
  ) then
    return deal_record;
  end if;

  if deal_record.deal_locked then
    raise exception 'Deal is already locked' using errcode = '23505';
  end if;

  update public.wallet_accounts
  set available_balance_minor = available_balance_minor - lock_amount,
      held_balance_minor = held_balance_minor + lock_amount
  where profile_id = package_sender_id and available_balance_minor >= lock_amount;
  if not found then
    raise exception 'Insufficient available balance' using errcode = '22003';
  end if;

  insert into public.wallet_transactions (
    profile_id, deal_id, kind, amount_minor, idempotency_key, description
  ) values (
    package_sender_id, p_deal_id, 'hold', lock_amount, p_idempotency_key, 'Deal funds held in escrow'
  );

  update public.chats_and_deals
  set final_agreed_price_minor = lock_amount,
      inspection_photo_url = p_inspection_photo_url,
      open_box_verified = true,
      deal_locked = true,
      status = 'locked',
      locked_at = now()
  where id = p_deal_id
  returning * into deal_record;

  perform public.mark_trusted_status_update();
  update public.packages
  set status = 'matched'
  where id = deal_record.package_id and status = 'pending';

  return deal_record;
end;
$$;

comment on function public.lock_deal_with_inspection(uuid, bigint, text, text) is
  'Locks a deal after inspection. Escrow amount is coalesce(final_agreed_price_minor, packages.proposed_reward_minor); p_amount_minor must match that value.';

-- Keep wallet_release / wallet_refund package status writes trusted
create or replace function public.wallet_release(
  p_deal_id uuid,
  p_delivery_otp text,
  p_idempotency_key text
)
returns public.chats_and_deals
language plpgsql
security definer
set search_path = pg_catalog, public
as $$
declare
  deal_record public.chats_and_deals;
  deal_lookup record;
  package_sender_id uuid;
  trip_traveler_id uuid;
  agreed_amount bigint;
begin
  select d as deal, p.sender_id as sender_id, t.traveler_id,
         d.final_agreed_price_minor as agreed_amount
  into deal_lookup
  from public.chats_and_deals d
  join public.packages p on p.id = d.package_id
  join public.trips t on t.id = d.trip_id
  where d.id = p_deal_id
  for update of d;

  if not found then
    raise exception 'Deal not found or caller is not the traveler' using errcode = '42501';
  end if;

  deal_record := deal_lookup.deal;
  package_sender_id := deal_lookup.sender_id;
  trip_traveler_id := deal_lookup.traveler_id;
  agreed_amount := deal_lookup.agreed_amount;

  if trip_traveler_id <> auth.uid() then
    raise exception 'Deal not found or caller is not the traveler' using errcode = '42501';
  end if;
  if not deal_record.deal_locked or agreed_amount is null then
    raise exception 'Deal is not locked' using errcode = '22023';
  end if;
  if deal_record.delivery_otp_hash is null
     or extensions.crypt(p_delivery_otp, deal_record.delivery_otp_hash) <> deal_record.delivery_otp_hash then
    raise exception 'Invalid delivery OTP' using errcode = '28P01';
  end if;
  if exists (
    select 1 from public.wallet_transactions
    where profile_id = package_sender_id and idempotency_key = p_idempotency_key
  ) then
    return deal_record;
  end if;

  update public.wallet_accounts
  set held_balance_minor = held_balance_minor - agreed_amount
  where profile_id = package_sender_id and held_balance_minor >= agreed_amount;
  if not found then
    raise exception 'Held balance is inconsistent' using errcode = '22003';
  end if;

  update public.wallet_accounts
  set available_balance_minor = available_balance_minor + agreed_amount
  where profile_id = trip_traveler_id;

  insert into public.wallet_transactions (profile_id, deal_id, kind, amount_minor, idempotency_key, description)
  values
    (package_sender_id, p_deal_id, 'release', agreed_amount, p_idempotency_key, 'Escrow released'),
    (trip_traveler_id, p_deal_id, 'credit', agreed_amount, p_idempotency_key, 'Delivery payout received');

  update public.chats_and_deals
  set status = 'completed', completed_at = now()
  where id = p_deal_id returning * into deal_record;

  perform public.mark_trusted_status_update();
  update public.packages set status = 'delivered' where id = deal_record.package_id;
  return deal_record;
end;
$$;

create or replace function public.wallet_refund(
  p_deal_id uuid,
  p_idempotency_key text
)
returns public.chats_and_deals
language plpgsql
security definer
set search_path = pg_catalog, public
as $$
declare
  deal_record public.chats_and_deals;
  deal_lookup record;
  package_sender_id uuid;
  agreed_amount bigint;
begin
  select d as deal, p.sender_id as sender_id,
         d.final_agreed_price_minor as agreed_amount
  into deal_lookup
  from public.chats_and_deals d
  join public.packages p on p.id = d.package_id
  where d.id = p_deal_id
  for update of d;

  if not found then
    raise exception 'Deal not found or caller is unauthorized' using errcode = '42501';
  end if;

  deal_record := deal_lookup.deal;
  package_sender_id := deal_lookup.sender_id;
  agreed_amount := deal_lookup.agreed_amount;

  if package_sender_id <> auth.uid() and not public.current_user_is_admin() then
    raise exception 'Deal not found or caller is unauthorized' using errcode = '42501';
  end if;
  if deal_record.status = 'completed' then
    raise exception 'Completed deals cannot be refunded' using errcode = '22023';
  end if;
  if exists (
    select 1 from public.wallet_transactions
    where profile_id = package_sender_id and idempotency_key = p_idempotency_key
  ) then
    return deal_record;
  end if;

  if deal_record.deal_locked and agreed_amount is not null then
    update public.wallet_accounts
    set held_balance_minor = held_balance_minor - agreed_amount,
        available_balance_minor = available_balance_minor + agreed_amount
    where profile_id = package_sender_id and held_balance_minor >= agreed_amount;
    if not found then
      raise exception 'Held balance is inconsistent' using errcode = '22003';
    end if;
    insert into public.wallet_transactions (profile_id, deal_id, kind, amount_minor, idempotency_key, description)
    values (package_sender_id, p_deal_id, 'refund', agreed_amount, p_idempotency_key, 'Escrow returned to sender');
  end if;

  update public.chats_and_deals set status = 'cancelled' where id = p_deal_id returning * into deal_record;

  perform public.mark_trusted_status_update();
  update public.packages set status = 'pending' where id = deal_record.package_id;
  return deal_record;
end;
$$;

-- ---------------------------------------------------------------------------
-- Admin-only manual wallet credit (staging funding; NOT a payment provider)
-- ---------------------------------------------------------------------------
create or replace function public.admin_credit_wallet(
  p_profile_id uuid,
  p_amount_minor bigint,
  p_idempotency_key text,
  p_note text default null
)
returns public.wallet_accounts
language plpgsql
security definer
set search_path = pg_catalog, public
as $$
declare
  account_record public.wallet_accounts;
  credit_note text;
begin
  if not public.current_user_is_admin() then
    raise exception 'Admin access required' using errcode = '42501';
  end if;
  if p_amount_minor <= 0 then
    raise exception 'Amount must be positive' using errcode = '22023';
  end if;
  if nullif(btrim(p_idempotency_key), '') is null then
    raise exception 'Idempotency key is required' using errcode = '22023';
  end if;

  credit_note := coalesce(
    nullif(btrim(p_note), ''),
    'Admin manual wallet credit (staging)'
  );

  if exists (
    select 1 from public.wallet_transactions
    where profile_id = p_profile_id and idempotency_key = p_idempotency_key
  ) then
    select * into account_record from public.wallet_accounts where profile_id = p_profile_id;
    return account_record;
  end if;

  update public.wallet_accounts
  set available_balance_minor = available_balance_minor + p_amount_minor
  where profile_id = p_profile_id
  returning * into account_record;

  if account_record.profile_id is null then
    raise exception 'Wallet account not found' using errcode = 'P0002';
  end if;

  insert into public.wallet_transactions (profile_id, kind, amount_minor, idempotency_key, description)
  values (p_profile_id, 'credit', p_amount_minor, p_idempotency_key, credit_note);

  return account_record;
end;
$$;

comment on function public.admin_credit_wallet(uuid, bigint, text, text) is
  'Administrator-only staging wallet credit. Writes an immutable ledger credit and increases available_balance_minor. Not for ordinary members; payment-provider credits remain wallet_credit_from_provider (service_role).';

revoke all on function public.admin_credit_wallet(uuid, bigint, text, text)
from public, anon;
grant execute on function public.admin_credit_wallet(uuid, bigint, text, text) to authenticated;

-- Re-assert existing RPC grants after create or replace
revoke all on function public.match_packages_within_corridor(uuid, double precision) from public, anon;
revoke all on function public.lock_deal_with_inspection(uuid, bigint, text, text) from public, anon;
revoke all on function public.wallet_release(uuid, text, text) from public, anon;
revoke all on function public.wallet_refund(uuid, text) from public, anon;
grant execute on function public.match_packages_within_corridor(uuid, double precision) to authenticated;
grant execute on function public.lock_deal_with_inspection(uuid, bigint, text, text) to authenticated;
grant execute on function public.wallet_release(uuid, text, text) to authenticated;
grant execute on function public.wallet_refund(uuid, text) to authenticated;

-- ---------------------------------------------------------------------------
-- Storage: NID photos (private) + parcel inspection evidence
-- ---------------------------------------------------------------------------
insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values
  (
    'nid-photos',
    'nid-photos',
    false,
    5242880,
    array['image/jpeg', 'image/png', 'image/webp']::text[]
  ),
  (
    'parcel-inspections',
    'parcel-inspections',
    false,
    10485760,
    array['image/jpeg', 'image/png', 'image/webp']::text[]
  )
on conflict (id) do update
set
  public = excluded.public,
  file_size_limit = excluded.file_size_limit,
  allowed_mime_types = excluded.allowed_mime_types;

-- NID: owner folder {uid}/... ; admins may read all
drop policy if exists nid_photos_insert_own on storage.objects;
create policy nid_photos_insert_own on storage.objects
for insert to authenticated
with check (
  bucket_id = 'nid-photos'
  and (storage.foldername(name))[1] = auth.uid()::text
);

drop policy if exists nid_photos_update_own on storage.objects;
create policy nid_photos_update_own on storage.objects
for update to authenticated
using (
  bucket_id = 'nid-photos'
  and (storage.foldername(name))[1] = auth.uid()::text
)
with check (
  bucket_id = 'nid-photos'
  and (storage.foldername(name))[1] = auth.uid()::text
);

drop policy if exists nid_photos_select_own_or_admin on storage.objects;
create policy nid_photos_select_own_or_admin on storage.objects
for select to authenticated
using (
  bucket_id = 'nid-photos'
  and (
    (storage.foldername(name))[1] = auth.uid()::text
    or public.current_user_is_admin()
  )
);

drop policy if exists nid_photos_delete_own on storage.objects;
create policy nid_photos_delete_own on storage.objects
for delete to authenticated
using (
  bucket_id = 'nid-photos'
  and (storage.foldername(name))[1] = auth.uid()::text
);

-- Inspections: uploader owns path prefix; participants/admins can read via URL
-- stored on the deal (path convention {uid}/{deal_id}/...)
drop policy if exists parcel_inspections_insert_own on storage.objects;
create policy parcel_inspections_insert_own on storage.objects
for insert to authenticated
with check (
  bucket_id = 'parcel-inspections'
  and (storage.foldername(name))[1] = auth.uid()::text
);

drop policy if exists parcel_inspections_update_own on storage.objects;
create policy parcel_inspections_update_own on storage.objects
for update to authenticated
using (
  bucket_id = 'parcel-inspections'
  and (storage.foldername(name))[1] = auth.uid()::text
)
with check (
  bucket_id = 'parcel-inspections'
  and (storage.foldername(name))[1] = auth.uid()::text
);

drop policy if exists parcel_inspections_select_own_or_admin on storage.objects;
create policy parcel_inspections_select_own_or_admin on storage.objects
for select to authenticated
using (
  bucket_id = 'parcel-inspections'
  and (
    (storage.foldername(name))[1] = auth.uid()::text
    or public.current_user_is_admin()
  )
);

drop policy if exists parcel_inspections_delete_own on storage.objects;
create policy parcel_inspections_delete_own on storage.objects
for delete to authenticated
using (
  bucket_id = 'parcel-inspections'
  and (storage.foldername(name))[1] = auth.uid()::text
);
