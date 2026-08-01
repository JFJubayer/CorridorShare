import { packageRepository } from '@/repositories/packageRepository';
import { tripRepository } from '@/repositories/tripRepository';

const DHAKA_POINT = { latitude: 23.777176, longitude: 90.399452 };
const MYMENSINGH_POINT = { latitude: 24.757082, longitude: 90.407438 };

function pointWkt({ latitude, longitude }) {
  return `POINT(${longitude} ${latitude})`;
}

function routeWkt(points) {
  return `LINESTRING(${points.map(({ latitude, longitude }) => `${longitude} ${latitude}`).join(', ')})`;
}

export async function postTrip({ userId, form }) {
  if (!userId) throw new Error('Sign in before posting a trip.');
  const travelTime = new Date(form.date);
  const capacity = Number(form.capacity);
  if (Number.isNaN(travelTime.valueOf()) || !Number.isFinite(capacity) || capacity <= 0) {
    throw new Error('Enter a valid travel date and positive capacity.');
  }
  return tripRepository.create({
    traveler_id: userId,
    departure_city: form.departure.trim(),
    destination_city: form.destination.trim(),
    route_path: routeWkt([DHAKA_POINT, MYMENSINGH_POINT]),
    travel_time: travelTime.toISOString(),
    weight_capacity_kg: capacity,
    status: 'scheduled',
  });
}

export async function postPackage({ userId, form }) {
  if (!userId) throw new Error('Sign in before requesting delivery.');
  const rewardMinor = Math.round(Number(form.reward) * 100);
  const weight = Number(form.weight);
  if (!form.desc.trim() || !Number.isSafeInteger(rewardMinor) || rewardMinor <= 0 || !Number.isFinite(weight) || weight <= 0) {
    throw new Error('Enter a description, a positive weight, and a positive reward.');
  }
  return packageRepository.create({
    sender_id: userId,
    pickup_location: pointWkt(DHAKA_POINT),
    dropoff_location: pointWkt(MYMENSINGH_POINT),
    pickup_radius_meters: 2000,
    item_description: form.desc.trim(),
    weight_kg: weight,
    proposed_reward_minor: rewardMinor,
    is_premium: false,
    status: 'pending',
  });
}
