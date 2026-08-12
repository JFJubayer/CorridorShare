-- Extend match_packages_within_corridor to return dropoff coords + weight_kg
-- for friends-beta map/list UIs. Filters unchanged: pickup+dropoff near route,
-- weight ≤ trip capacity (null weight allowed), pending, not own packages.
--
-- RETURNS TABLE shape changed → must DROP then CREATE (CREATE OR REPLACE cannot
-- alter OUT/returns-table columns).

drop function if exists public.match_packages_within_corridor(uuid, double precision);

create function public.match_packages_within_corridor(
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
  pickup_radius_meters integer,
  dropoff_lat double precision,
  dropoff_lng double precision,
  weight_kg numeric
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
    p.pickup_radius_meters,
    extensions.st_y(p.dropoff_location),
    extensions.st_x(p.dropoff_location),
    p.weight_kg
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
  'Returns pending packages whose pickup AND dropoff are within buffer meters of the caller-owned trip LineString (any Bangladesh route). Includes pickup/dropoff lat/lng and weight_kg. Packages with weight_kg set must fit trip weight_capacity_kg; null weight is allowed.';

revoke all on function public.match_packages_within_corridor(uuid, double precision) from public, anon;
grant execute on function public.match_packages_within_corridor(uuid, double precision) to authenticated;
