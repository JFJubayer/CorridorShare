begin;

create extension if not exists pgtap;
select plan(21);

insert into auth.users (
  id, instance_id, aud, role, phone, encrypted_password,
  raw_app_meta_data, raw_user_meta_data, created_at, updated_at
) values
  (
    '10000000-0000-0000-0000-000000000001',
    '00000000-0000-0000-0000-000000000000',
    'authenticated', 'authenticated', '+8801700000001',
    extensions.crypt('test-password', extensions.gen_salt('bf')),
    '{}', '{"full_name":"Contract User A"}', now(), now()
  ),
  (
    '10000000-0000-0000-0000-000000000002',
    '00000000-0000-0000-0000-000000000000',
    'authenticated', 'authenticated', '+8801700000002',
    extensions.crypt('test-password', extensions.gen_salt('bf')),
    '{}', '{"full_name":"Contract User B"}', now(), now()
  ),
  (
    '10000000-0000-0000-0000-000000000003',
    '00000000-0000-0000-0000-000000000000',
    'authenticated', 'authenticated', '+8801700000003',
    extensions.crypt('test-password', extensions.gen_salt('bf')),
    '{}', '{"full_name":"Contract Admin"}', now(), now()
  );

-- Promote admin outside authenticated RLS (table owner / migration role).
update public.profiles
set role = 'admin'
where id = '10000000-0000-0000-0000-000000000003';

insert into public.trips (
  id, traveler_id, departure_city, destination_city, route_path, travel_time, weight_capacity_kg
) values (
  '20000000-0000-0000-0000-000000000002',
  '10000000-0000-0000-0000-000000000002',
  'Dhaka', 'Mymensingh',
  extensions.st_geomfromtext('LINESTRING(90.399452 23.777176, 90.407438 24.757082)', 4326),
  now() + interval '1 day', 10
);

-- Multi-city sample (Chittagong–Sylhet style) for nationwide geometry notes.
insert into public.trips (
  id, traveler_id, departure_city, destination_city, route_path, travel_time, weight_capacity_kg
) values (
  '20000000-0000-0000-0000-000000000099',
  '10000000-0000-0000-0000-000000000002',
  'Chattogram', 'Sylhet',
  extensions.st_geomfromtext(
    'LINESTRING(91.7832 22.3569, 91.8687 24.8949)',
    4326
  ),
  now() + interval '2 days', 8
);

insert into public.packages (
  id, sender_id, pickup_location, dropoff_location, item_description,
  proposed_reward_minor, weight_kg, recipient_phone, recipient_name
) values (
  '30000000-0000-0000-0000-000000000002',
  '10000000-0000-0000-0000-000000000002',
  extensions.st_geomfromtext('POINT(90.425539 24.002284)', 4326),
  extensions.st_geomfromtext('POINT(90.407438 24.757082)', 4326),
  'Contract test parcel', 25000, 2, '+8801711000002', 'Recipient B'
);

-- Pickup on Dhaka–Mymensingh corridor but dropoff far away (should not match).
insert into public.packages (
  id, sender_id, pickup_location, dropoff_location, item_description,
  proposed_reward_minor, weight_kg, recipient_phone
) values (
  '30000000-0000-0000-0000-000000000010',
  '10000000-0000-0000-0000-000000000001',
  extensions.st_geomfromtext('POINT(90.425539 24.002284)', 4326),
  extensions.st_geomfromtext('POINT(88.6065 24.3745)', 4326), -- Rajshahi-ish, off corridor
  'Dropoff-far parcel', 18000, 1, '+8801711000010'
);

-- Over-capacity package (pickup+dropoff on corridor).
insert into public.packages (
  id, sender_id, pickup_location, dropoff_location, item_description,
  proposed_reward_minor, weight_kg, recipient_phone
) values (
  '30000000-0000-0000-0000-000000000011',
  '10000000-0000-0000-0000-000000000001',
  extensions.st_geomfromtext('POINT(90.401 23.9)', 4326),
  extensions.st_geomfromtext('POINT(90.405 24.5)', 4326),
  'Overweight parcel', 20000, 50, '+8801711000011'
);

-- Happy-path matchable package owned by A (traveler is B).
insert into public.packages (
  id, sender_id, pickup_location, dropoff_location, item_description,
  proposed_reward_minor, weight_kg, recipient_phone, recipient_name
) values (
  '30000000-0000-0000-0000-000000000012',
  '10000000-0000-0000-0000-000000000001',
  extensions.st_geomfromtext('POINT(90.401 23.9)', 4326),
  extensions.st_geomfromtext('POINT(90.405 24.5)', 4326),
  'Matchable parcel', 22000, 3, '+8801711000012', 'Recipient A'
);

insert into public.chats_and_deals (id, trip_id, package_id)
values (
  '40000000-0000-0000-0000-000000000002',
  '20000000-0000-0000-0000-000000000002',
  '30000000-0000-0000-0000-000000000002'
);

insert into public.chats_and_deals (id, trip_id, package_id)
values (
  '40000000-0000-0000-0000-000000000012',
  '20000000-0000-0000-0000-000000000002',
  '30000000-0000-0000-0000-000000000012'
);

-- ---------------------------------------------------------------------------
-- Baseline abuse / privilege checks (as ordinary user A)
-- ---------------------------------------------------------------------------
set local role authenticated;
select set_config('request.jwt.claim.sub', '10000000-0000-0000-0000-000000000001', true);
select set_config('request.jwt.claim.role', 'authenticated', true);

select is(public.current_user_is_admin(), false, 'ordinary users are not administrators');

select ok(
  not has_function_privilege(
    'anon',
    'public.lock_deal_with_inspection(uuid,bigint,text,text)',
    'EXECUTE'
  ),
  'anonymous clients cannot execute authenticated deal RPCs'
);

select throws_ok(
  $$update public.profiles set role = 'admin' where id = auth.uid()$$,
  '42501',
  'permission denied for table profiles',
  'ordinary users cannot assign themselves an admin role'
);

select throws_ok(
  $$update public.wallet_accounts set available_balance_minor = 999999 where profile_id = auth.uid()$$,
  '42501',
  'permission denied for table wallet_accounts',
  'authenticated clients cannot directly update wallets'
);

select throws_ok(
  $$select * from public.match_packages_within_corridor('20000000-0000-0000-0000-000000000002', 5000)$$,
  '42501',
  'Trip not found or not owned by caller',
  'users cannot match against another traveler trip'
);

select throws_ok(
  $$insert into public.messages (deal_id, sender_id, message_text) values ('40000000-0000-0000-0000-000000000002', auth.uid(), 'not a participant')$$,
  '42501',
  'new row violates row-level security policy for table "messages"',
  'messages are limited to deal participants'
);

select ok(
  not has_function_privilege(
    'authenticated',
    'public.wallet_credit_from_provider(uuid,bigint,text,text)',
    'EXECUTE'
  ),
  'wallet credit is not executable by authenticated clients'
);

select throws_ok(
  $$select public.admin_credit_wallet('10000000-0000-0000-0000-000000000001', 1000, 'abuse-credit-1', 'nope')$$,
  '42501',
  'Admin access required',
  'ordinary users cannot call admin_credit_wallet'
);

select throws_ok(
  $$update public.packages set status = 'delivered' where id = '30000000-0000-0000-0000-000000000012'$$,
  '42501',
  'Package status delivered may only be set by authorized deal functions',
  'clients cannot mark packages delivered directly'
);

-- ---------------------------------------------------------------------------
-- Matching happy path + dropoff/weight filters (as traveler B)
-- ---------------------------------------------------------------------------
select set_config('request.jwt.claim.sub', '10000000-0000-0000-0000-000000000002', true);

select ok(
  exists (
    select 1
    from public.match_packages_within_corridor('20000000-0000-0000-0000-000000000002', 5000)
    where package_id = '30000000-0000-0000-0000-000000000012'
  ),
  'match returns packages with pickup and dropoff near the trip route'
);

select ok(
  not exists (
    select 1
    from public.match_packages_within_corridor('20000000-0000-0000-0000-000000000002', 5000)
    where package_id = '30000000-0000-0000-0000-000000000010'
  ),
  'packages with dropoff far from the route are excluded'
);

select ok(
  not exists (
    select 1
    from public.match_packages_within_corridor('20000000-0000-0000-0000-000000000002', 5000)
    where package_id = '30000000-0000-0000-0000-000000000011'
  ),
  'packages heavier than trip capacity are excluded'
);

-- ---------------------------------------------------------------------------
-- Lock amount must equal package proposed reward
-- ---------------------------------------------------------------------------
-- Fund sender A via admin credit (switch to admin), then traveler locks.
reset role;
set local role authenticated;
select set_config('request.jwt.claim.sub', '10000000-0000-0000-0000-000000000003', true);
select set_config('request.jwt.claim.role', 'authenticated', true);

select is(
  (public.admin_credit_wallet(
    '10000000-0000-0000-0000-000000000001',
    50000,
    'admin-credit-sender-a',
    'staging fund for lock test'
  )).available_balance_minor,
  50000::bigint,
  'admin can credit a member wallet for staging'
);

-- Idempotent replay
select is(
  (public.admin_credit_wallet(
    '10000000-0000-0000-0000-000000000001',
    50000,
    'admin-credit-sender-a',
    'staging fund for lock test'
  )).available_balance_minor,
  50000::bigint,
  'admin_credit_wallet is idempotent on the same key'
);

select set_config('request.jwt.claim.sub', '10000000-0000-0000-0000-000000000002', true);

select throws_ok(
  $$select public.lock_deal_with_inspection(
    '40000000-0000-0000-0000-000000000012',
    99999,
    'https://example.test/inspection.jpg',
    'lock-wrong-amount'
  )$$,
  '22023',
  'Lock amount must equal agreed package reward (22000 poisha)',
  'lock rejects amounts that differ from the package reward'
);

select is(
  (public.lock_deal_with_inspection(
    '40000000-0000-0000-0000-000000000012',
    22000,
    'https://example.test/inspection.jpg',
    'lock-correct-amount'
  )).deal_locked,
  true,
  'lock succeeds when amount equals proposed package reward'
);

select is(
  (select status from public.packages where id = '30000000-0000-0000-0000-000000000012'),
  'matched'::public.package_status,
  'locking a deal marks the package matched via trusted path'
);

-- Wallet ledger assertions bypass RLS (owner of the test transaction).
reset role;
select is(
  (select available_balance_minor from public.wallet_accounts
   where profile_id = '10000000-0000-0000-0000-000000000001'),
  28000::bigint,
  'lock holds the agreed reward from the sender available balance'
);

select is(
  (select held_balance_minor from public.wallet_accounts
   where profile_id = '10000000-0000-0000-0000-000000000001'),
  22000::bigint,
  'lock moves the agreed reward into held balance'
);

-- Storage buckets present
select ok(
  exists (select 1 from storage.buckets where id = 'nid-photos'),
  'nid-photos storage bucket exists'
);
select ok(
  exists (select 1 from storage.buckets where id = 'parcel-inspections'),
  'parcel-inspections storage bucket exists'
);

select * from finish();
rollback;
