create extension if not exists postgis;
create extension if not exists pgcrypto;

create type public.profile_role as enum ('member', 'admin');
create type public.profile_nid_status as enum ('unverified', 'pending', 'verified', 'suspended');
create type public.trip_status as enum ('scheduled', 'active', 'completed', 'cancelled');
create type public.package_status as enum ('pending', 'matched', 'in_transit', 'delivered', 'cancelled');
create type public.deal_status as enum ('negotiating', 'locked', 'in_transit', 'completed', 'cancelled');
create type public.wallet_transaction_kind as enum ('credit', 'hold', 'release', 'refund');

create table public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  phone_number text unique,
  full_name text,
  role public.profile_role not null default 'member',
  nid_status public.profile_nid_status not null default 'unverified',
  nid_photo_url text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table public.wallet_accounts (
  profile_id uuid primary key references public.profiles(id) on delete cascade,
  available_balance_minor bigint not null default 0 check (available_balance_minor >= 0),
  held_balance_minor bigint not null default 0 check (held_balance_minor >= 0),
  currency_code text not null default 'BDT' check (currency_code = 'BDT'),
  updated_at timestamptz not null default now()
);

create table public.trips (
  id uuid primary key default gen_random_uuid(),
  traveler_id uuid not null references public.profiles(id) on delete cascade,
  departure_city text not null,
  destination_city text not null,
  route_path geometry(LineString, 4326) not null,
  travel_time timestamptz not null,
  weight_capacity_kg numeric(7, 2) not null check (weight_capacity_kg > 0),
  status public.trip_status not null default 'scheduled',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table public.packages (
  id uuid primary key default gen_random_uuid(),
  sender_id uuid not null references public.profiles(id) on delete cascade,
  pickup_location geometry(Point, 4326) not null,
  dropoff_location geometry(Point, 4326) not null,
  pickup_radius_meters integer not null default 2000 check (pickup_radius_meters between 100 and 50000),
  item_description text not null,
  item_type text,
  weight_kg numeric(7, 2) check (weight_kg > 0),
  proposed_reward_minor bigint not null check (proposed_reward_minor > 0),
  is_premium boolean not null default false,
  status public.package_status not null default 'pending',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table public.chats_and_deals (
  id uuid primary key default gen_random_uuid(),
  trip_id uuid not null references public.trips(id) on delete cascade,
  package_id uuid not null references public.packages(id) on delete cascade,
  final_agreed_price_minor bigint check (final_agreed_price_minor > 0),
  status public.deal_status not null default 'negotiating',
  deal_locked boolean not null default false,
  open_box_verified boolean not null default false,
  inspection_photo_url text,
  delivery_otp_hash text,
  locked_at timestamptz,
  completed_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (trip_id, package_id)
);

create table public.messages (
  id uuid primary key default gen_random_uuid(),
  deal_id uuid not null references public.chats_and_deals(id) on delete cascade,
  sender_id uuid not null references public.profiles(id) on delete cascade,
  message_text text,
  image_verification_url text,
  created_at timestamptz not null default now(),
  check (nullif(btrim(message_text), '') is not null or image_verification_url is not null)
);

create table public.wallet_transactions (
  id uuid primary key default gen_random_uuid(),
  profile_id uuid not null references public.profiles(id) on delete cascade,
  deal_id uuid references public.chats_and_deals(id) on delete set null,
  kind public.wallet_transaction_kind not null,
  amount_minor bigint not null check (amount_minor > 0),
  idempotency_key text not null,
  description text,
  created_at timestamptz not null default now(),
  unique (profile_id, idempotency_key)
);

create index trips_route_path_idx on public.trips using gist (route_path);
create index trips_traveler_id_idx on public.trips (traveler_id);
create index packages_pickup_location_idx on public.packages using gist (pickup_location);
create index packages_sender_id_idx on public.packages (sender_id);
create index deals_trip_id_idx on public.chats_and_deals (trip_id);
create index deals_package_id_idx on public.chats_and_deals (package_id);
create index messages_deal_created_idx on public.messages (deal_id, created_at);
create index wallet_transactions_profile_created_idx on public.wallet_transactions (profile_id, created_at);

create or replace function public.set_updated_at()
returns trigger
language plpgsql
set search_path = pg_catalog, public
as $$
begin
  new.updated_at := now();
  return new;
end;
$$;

create trigger profiles_set_updated_at before update on public.profiles
for each row execute function public.set_updated_at();
create trigger wallet_accounts_set_updated_at before update on public.wallet_accounts
for each row execute function public.set_updated_at();
create trigger trips_set_updated_at before update on public.trips
for each row execute function public.set_updated_at();
create trigger packages_set_updated_at before update on public.packages
for each row execute function public.set_updated_at();
create trigger deals_set_updated_at before update on public.chats_and_deals
for each row execute function public.set_updated_at();

create or replace function public.handle_new_auth_user()
returns trigger
language plpgsql
security definer
set search_path = pg_catalog, public
as $$
begin
  insert into public.profiles (id, phone_number, full_name)
  values (new.id, new.phone, nullif(new.raw_user_meta_data ->> 'full_name', ''));
  insert into public.wallet_accounts (profile_id) values (new.id);
  return new;
end;
$$;

create trigger on_auth_user_created
after insert on auth.users
for each row execute function public.handle_new_auth_user();

create or replace function public.current_user_is_admin()
returns boolean
language sql
stable
security definer
set search_path = pg_catalog, public
as $$
  select exists (
    select 1 from public.profiles
    where id = auth.uid() and role = 'admin'
  );
$$;

alter table public.profiles enable row level security;
alter table public.wallet_accounts enable row level security;
alter table public.wallet_transactions enable row level security;
alter table public.trips enable row level security;
alter table public.packages enable row level security;
alter table public.chats_and_deals enable row level security;
alter table public.messages enable row level security;

create policy profiles_read_own_or_admin on public.profiles
for select to authenticated using (auth.uid() = id or public.current_user_is_admin());
create policy profiles_update_own on public.profiles
for update to authenticated using (auth.uid() = id) with check (auth.uid() = id);

create policy wallet_accounts_read_own_or_admin on public.wallet_accounts
for select to authenticated using (auth.uid() = profile_id or public.current_user_is_admin());
create policy wallet_transactions_read_own_or_admin on public.wallet_transactions
for select to authenticated using (auth.uid() = profile_id or public.current_user_is_admin());

create policy trips_read_authenticated on public.trips
for select to authenticated using (true);
create policy trips_insert_own on public.trips
for insert to authenticated with check (auth.uid() = traveler_id);
create policy trips_update_own on public.trips
for update to authenticated using (auth.uid() = traveler_id) with check (auth.uid() = traveler_id);
create policy trips_delete_own on public.trips
for delete to authenticated using (auth.uid() = traveler_id);

create policy packages_read_authenticated on public.packages
for select to authenticated using (true);
create policy packages_insert_own on public.packages
for insert to authenticated with check (auth.uid() = sender_id);
create policy packages_update_own on public.packages
for update to authenticated using (auth.uid() = sender_id) with check (auth.uid() = sender_id);
create policy packages_delete_own on public.packages
for delete to authenticated using (auth.uid() = sender_id);

create policy deals_read_participant on public.chats_and_deals
for select to authenticated using (
  exists (select 1 from public.trips t where t.id = trip_id and t.traveler_id = auth.uid())
  or exists (select 1 from public.packages p where p.id = package_id and p.sender_id = auth.uid())
  or public.current_user_is_admin()
);
create policy deals_create_participant on public.chats_and_deals
for insert to authenticated with check (
  exists (select 1 from public.trips t where t.id = trip_id and t.traveler_id = auth.uid())
  or exists (select 1 from public.packages p where p.id = package_id and p.sender_id = auth.uid())
);

create policy messages_read_participant on public.messages
for select to authenticated using (
  exists (
    select 1
    from public.chats_and_deals d
    join public.trips t on t.id = d.trip_id
    join public.packages p on p.id = d.package_id
    where d.id = deal_id and auth.uid() in (t.traveler_id, p.sender_id)
  ) or public.current_user_is_admin()
);
create policy messages_insert_participant on public.messages
for insert to authenticated with check (
  sender_id = auth.uid()
  and exists (
    select 1
    from public.chats_and_deals d
    join public.trips t on t.id = d.trip_id
    join public.packages p on p.id = d.package_id
    where d.id = deal_id and auth.uid() in (t.traveler_id, p.sender_id)
  )
);

revoke all on public.profiles from anon, authenticated;
grant select on public.profiles to authenticated;
grant update (full_name, nid_photo_url) on public.profiles to authenticated;

revoke all on public.wallet_accounts from anon, authenticated;
revoke all on public.wallet_transactions from anon, authenticated;
grant select on public.wallet_accounts, public.wallet_transactions to authenticated;

revoke all on public.trips, public.packages, public.chats_and_deals, public.messages from anon, authenticated;
grant select, insert, update, delete on public.trips, public.packages to authenticated;
grant select, insert on public.chats_and_deals, public.messages to authenticated;

create or replace function public.admin_set_nid_status(
  p_profile_id uuid,
  p_status public.profile_nid_status
)
returns public.profiles
language plpgsql
security definer
set search_path = pg_catalog, public
as $$
declare
  updated_profile public.profiles;
begin
  if not public.current_user_is_admin() then
    raise exception 'Admin access required' using errcode = '42501';
  end if;
  if p_status not in ('pending', 'verified', 'suspended') then
    raise exception 'Unsupported KYC status' using errcode = '22023';
  end if;
  update public.profiles set nid_status = p_status where id = p_profile_id returning * into updated_profile;
  if updated_profile.id is null then
    raise exception 'Profile not found' using errcode = 'P0002';
  end if;
  return updated_profile;
end;
$$;

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
  traveler_route geometry;
begin
  if buffer_distance_meters < 100 or buffer_distance_meters > 50000 then
    raise exception 'Buffer distance must be between 100 and 50000 meters' using errcode = '22023';
  end if;

  select t.route_path into traveler_route
  from public.trips t
  where t.id = traveler_trip_id and t.traveler_id = auth.uid();

  if traveler_route is null then
    raise exception 'Trip not found or not owned by caller' using errcode = '42501';
  end if;

  return query
  select
    p.id,
    p.sender_id,
    p.item_description,
    p.item_type,
    p.proposed_reward_minor,
    p.is_premium,
    st_distance(p.pickup_location::geography, traveler_route::geography),
    st_distance(p.pickup_location::geography, traveler_route::geography) > p.pickup_radius_meters,
    st_y(p.pickup_location),
    st_x(p.pickup_location),
    p.pickup_radius_meters
  from public.packages p
  where p.status = 'pending'
    and p.sender_id <> auth.uid()
    and st_dwithin(p.pickup_location::geography, traveler_route::geography, buffer_distance_meters)
  order by p.is_premium desc, st_distance(p.pickup_location::geography, traveler_route::geography);
end;
$$;

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

  select d as deal, p.sender_id as sender_id, t.traveler_id
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

  if trip_traveler_id <> auth.uid() then
    raise exception 'Deal not found or caller is not the traveler' using errcode = '42501';
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
  set available_balance_minor = available_balance_minor - p_amount_minor,
      held_balance_minor = held_balance_minor + p_amount_minor
  where profile_id = package_sender_id and available_balance_minor >= p_amount_minor;
  if not found then
    raise exception 'Insufficient available balance' using errcode = '22003';
  end if;

  insert into public.wallet_transactions (
    profile_id, deal_id, kind, amount_minor, idempotency_key, description
  ) values (
    package_sender_id, p_deal_id, 'hold', p_amount_minor, p_idempotency_key, 'Deal funds held in escrow'
  );

  update public.chats_and_deals
  set final_agreed_price_minor = p_amount_minor,
      inspection_photo_url = p_inspection_photo_url,
      open_box_verified = true,
      deal_locked = true,
      status = 'locked',
      locked_at = now()
  where id = p_deal_id
  returning * into deal_record;

  return deal_record;
end;
$$;

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
     or crypt(p_delivery_otp, deal_record.delivery_otp_hash) <> deal_record.delivery_otp_hash then
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
  update public.packages set status = 'delivered' where id = deal_record.package_id;
  return deal_record;
end;
$$;

create or replace function public.issue_delivery_otp(p_deal_id uuid)
returns text
language plpgsql
security definer
set search_path = pg_catalog, public
as $$
declare
  package_sender_id uuid;
  generated_otp text;
  random_bytes bytea;
  random_number bigint;
begin
  select p.sender_id into package_sender_id
  from public.chats_and_deals d
  join public.packages p on p.id = d.package_id
  where d.id = p_deal_id and d.deal_locked and d.status = 'locked'
  for update of d;

  if package_sender_id is null or package_sender_id <> auth.uid() then
    raise exception 'Locked deal not found or caller is not the sender' using errcode = '42501';
  end if;

  random_bytes := gen_random_bytes(4);
  random_number := get_byte(random_bytes, 0)::bigint * 16777216
    + get_byte(random_bytes, 1)::bigint * 65536
    + get_byte(random_bytes, 2)::bigint * 256
    + get_byte(random_bytes, 3)::bigint;
  generated_otp := lpad((random_number % 1000000)::text, 6, '0');

  update public.chats_and_deals
  set delivery_otp_hash = crypt(generated_otp, gen_salt('bf'))
  where id = p_deal_id;
  return generated_otp;
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
  update public.packages set status = 'pending' where id = deal_record.package_id;
  return deal_record;
end;
$$;

create or replace function public.wallet_credit_from_provider(
  p_profile_id uuid,
  p_amount_minor bigint,
  p_idempotency_key text,
  p_description text default 'Provider-confirmed wallet credit'
)
returns public.wallet_accounts
language plpgsql
security definer
set search_path = pg_catalog, public
as $$
declare
  account_record public.wallet_accounts;
begin
  if p_amount_minor <= 0 then
    raise exception 'Amount must be positive' using errcode = '22023';
  end if;
  if exists (
    select 1 from public.wallet_transactions
    where profile_id = p_profile_id and idempotency_key = p_idempotency_key
  ) then
    select * into account_record from public.wallet_accounts where profile_id = p_profile_id;
    return account_record;
  end if;
  update public.wallet_accounts
  set available_balance_minor = available_balance_minor + p_amount_minor
  where profile_id = p_profile_id returning * into account_record;
  if account_record.profile_id is null then
    raise exception 'Wallet account not found' using errcode = 'P0002';
  end if;
  insert into public.wallet_transactions (profile_id, kind, amount_minor, idempotency_key, description)
  values (p_profile_id, 'credit', p_amount_minor, p_idempotency_key, p_description);
  return account_record;
end;
$$;

revoke all on function public.current_user_is_admin() from public;
revoke all on function public.admin_set_nid_status(uuid, public.profile_nid_status) from public;
revoke all on function public.match_packages_within_corridor(uuid, double precision) from public;
revoke all on function public.lock_deal_with_inspection(uuid, bigint, text, text) from public;
revoke all on function public.wallet_release(uuid, text, text) from public;
revoke all on function public.issue_delivery_otp(uuid) from public;
revoke all on function public.wallet_refund(uuid, text) from public;
revoke all on function public.wallet_credit_from_provider(uuid, bigint, text, text) from public;

grant execute on function public.current_user_is_admin() to authenticated;
grant execute on function public.admin_set_nid_status(uuid, public.profile_nid_status) to authenticated;
grant execute on function public.match_packages_within_corridor(uuid, double precision) to authenticated;
grant execute on function public.lock_deal_with_inspection(uuid, bigint, text, text) to authenticated;
grant execute on function public.wallet_release(uuid, text, text) to authenticated;
grant execute on function public.issue_delivery_otp(uuid) to authenticated;
grant execute on function public.wallet_refund(uuid, text) to authenticated;
grant execute on function public.wallet_credit_from_provider(uuid, bigint, text, text) to service_role;

do $$
begin
  if exists (select 1 from pg_publication where pubname = 'supabase_realtime')
     and not exists (
       select 1 from pg_publication_tables
       where pubname = 'supabase_realtime' and schemaname = 'public' and tablename = 'messages'
     ) then
    alter publication supabase_realtime add table public.messages;
  end if;
end;
$$;
