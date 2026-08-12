const NOMINATIM_URL = 'https://nominatim.openstreetmap.org/search';
const OSRM_URL = 'https://router.project-osrm.org/route/v1/driving';

export function pointWkt({ latitude, longitude }) {
  return `POINT(${longitude} ${latitude})`;
}

export function routeWkt(points) {
  if (!points?.length) throw new Error('A route needs at least one coordinate.');
  return `LINESTRING(${points.map(({ latitude, longitude }) => `${longitude} ${latitude}`).join(', ')})`;
}

export function latLngPairsFromOsrmGeometry(geometry) {
  return (geometry?.coordinates ?? []).map(([longitude, latitude]) => ({ latitude, longitude }));
}

export async function geocodePlace(query, { signal } = {}) {
  const trimmed = String(query || '').trim();
  if (!trimmed) throw new Error('Enter a city or place name in Bangladesh.');

  const url = new URL(NOMINATIM_URL);
  url.searchParams.set('q', trimmed);
  url.searchParams.set('format', 'json');
  url.searchParams.set('limit', '1');
  url.searchParams.set('countrycodes', 'bd');

  const response = await fetch(url.toString(), {
    signal,
    headers: {
      Accept: 'application/json',
      'Accept-Language': 'en',
    },
  });
  if (!response.ok) throw new Error('Unable to look up that place right now. Try again shortly.');
  const results = await response.json();
  if (!Array.isArray(results) || results.length === 0) {
    throw new Error(`Could not find "${trimmed}" in Bangladesh. Try a clearer city or area name.`);
  }
  return {
    latitude: Number(results[0].lat),
    longitude: Number(results[0].lon),
    label: results[0].display_name,
  };
}

export async function fetchDrivingRoute(start, end, { signal } = {}) {
  const url = `${OSRM_URL}/${start.longitude},${start.latitude};${end.longitude},${end.latitude}?overview=full&geometries=geojson`;
  const response = await fetch(url, { signal });
  if (!response.ok) throw new Error('Unable to calculate a driving corridor for those places.');
  const data = await response.json();
  const route = data?.routes?.[0];
  if (!route?.geometry) {
    throw new Error('No driving route found between those places. Check the city names and try again.');
  }
  const points = latLngPairsFromOsrmGeometry(route.geometry);
  if (points.length < 2) {
    return [start, end];
  }
  return points;
}

export async function buildTripRouteGeometry({ departure, destination, signal } = {}) {
  const [start, end] = await Promise.all([
    geocodePlace(departure, { signal }),
    geocodePlace(destination, { signal }),
  ]);
  let points;
  try {
    points = await fetchDrivingRoute(start, end, { signal });
  } catch {
    points = [start, end];
  }
  return {
    start,
    end,
    points,
    route_path: routeWkt(points),
    leafletRoute: points.map(({ latitude, longitude }) => [latitude, longitude]),
  };
}

export async function buildPackagePointGeometry({ pickup, dropoff, signal } = {}) {
  const [pickupPoint, dropoffPoint] = await Promise.all([
    geocodePlace(pickup, { signal }),
    geocodePlace(dropoff, { signal }),
  ]);
  return {
    pickupPoint,
    dropoffPoint,
    pickup_location: pointWkt(pickupPoint),
    dropoff_location: pointWkt(dropoffPoint),
  };
}
