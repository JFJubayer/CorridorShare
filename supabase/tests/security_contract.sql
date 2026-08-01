begin;

create extension if not exists pgtap;
select plan(6);

insert into auth.users (
  id, instance_id, aud, role, phone, encrypted_password,
  raw_app_meta_data, raw_user_meta_data, created_at, updated_at
) values
  (
    '10000000-0000-0000-0000-000000000001',
    '00000000-0000-0000-0000-000000000000',
    'authenticated', 'authenticated', '+8801700000001', crypt('test-password', gen_salt('bf')),
    '{}', '{"full_name":"Contract User A"}', now(), now()
  ),
  (
    '10000000-0000-0000-0000-000000000002',
    '00000000-0000-0000-0000-000000000000',
    'authenticated', 'authenticated', '+8801700000002', crypt('test-password', gen_salt('bf')),
    '{}', '{"full_name":"Contract User B"}', now(), now()
  );

insert into public.trips (
  id, traveler_id, departure_city, destination_city, route_path, travel_time, weight_capacity_kg
) values (
  '20000000-0000-0000-0000-000000000002',
  '10000000-0000-0000-0000-000000000002',
  'Dhaka', 'Mymensingh',
  st_geomfromtext('LINESTRING(90.399452 23.777176, 90.407438 24.757082)', 4326),
  now() + interval '1 day', 10
);

insert into public.packages (
  id, sender_id, pickup_location, dropoff_location, item_description,
  proposed_reward_minor, weight_kg
) values (
  '30000000-0000-0000-0000-000000000002',
  '10000000-0000-0000-0000-000000000002',
  st_geomfromtext('POINT(90.425539 24.002284)', 4326),
  st_geomfromtext('POINT(90.407438 24.757082)', 4326),
  'Contract test parcel', 25000, 2
);

insert into public.chats_and_deals (id, trip_id, package_id)
values (
  '40000000-0000-0000-0000-000000000002',
  '20000000-0000-0000-0000-000000000002',
  '30000000-0000-0000-0000-000000000002'
);

set local role authenticated;
select set_config('request.jwt.claim.sub', '10000000-0000-0000-0000-000000000001', true);
select set_config('request.jwt.claim.role', 'authenticated', true);

select is(public.current_user_is_admin(), false, 'ordinary users are not administrators');

select throws_ok(
  $$update public.profiles set role = 'admin' where id = auth.uid()$$,
  'ordinary users cannot assign themselves an admin role'
);

select throws_ok(
  $$update public.wallet_accounts set available_balance_minor = 999999 where profile_id = auth.uid()$$,
  'authenticated clients cannot directly update wallets'
);

select throws_ok(
  $$select * from public.match_packages_within_corridor('20000000-0000-0000-0000-000000000002', 5000)$$,
  'users cannot match against another traveler trip'
);

select throws_ok(
  $$insert into public.messages (deal_id, sender_id, message_text) values ('40000000-0000-0000-0000-000000000002', auth.uid(), 'not a participant')$$,
  'messages are limited to deal participants'
);

select throws_ok(
  $$select public.wallet_credit_from_provider(auth.uid(), 10000, 'forged-credit', 'forged')$$,
  'wallet credit is not executable by authenticated clients'
);

select * from finish();
rollback;
