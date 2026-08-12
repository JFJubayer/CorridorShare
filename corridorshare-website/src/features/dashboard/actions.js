import { packageRepository } from '@/repositories/packageRepository';
import { tripRepository } from '@/repositories/tripRepository';
import { buildPackagePointGeometry, buildTripRouteGeometry } from '@/shared/geo/routeGeometry';

function isMissingColumnError(error, column) {
  const message = `${error?.message || ''} ${error?.details || ''} ${error?.hint || ''}`.toLowerCase();
  return message.includes(column.toLowerCase()) && (
    message.includes('column') || message.includes('schema cache') || message.includes('does not exist')
  );
}

export async function postTrip({ userId, form }) {
  if (!userId) throw new Error('Sign in before posting a trip.');
  const travelTime = new Date(form.date);
  const capacity = Number(form.capacity);
  if (Number.isNaN(travelTime.valueOf()) || !Number.isFinite(capacity) || capacity <= 0) {
    throw new Error('Enter a valid travel date and positive capacity.');
  }
  const departure = form.departure.trim();
  const destination = form.destination.trim();
  if (!departure || !destination) {
    throw new Error('Enter both departure and destination cities anywhere in Bangladesh.');
  }

  const geometry = await buildTripRouteGeometry({ departure, destination });

  return tripRepository.create({
    traveler_id: userId,
    departure_city: departure,
    destination_city: destination,
    route_path: geometry.route_path,
    travel_time: travelTime.toISOString(),
    weight_capacity_kg: capacity,
    status: 'scheduled',
  });
}

export async function postPackage({ userId, form }) {
  if (!userId) throw new Error('Sign in before requesting delivery.');
  const rewardMinor = Math.round(Number(form.reward) * 100);
  const weight = Number(form.weight);
  const pickup = (form.pickup || form.location || '').trim();
  const dropoff = (form.dropoff || form.destination || '').trim();
  const recipientPhone = (form.recipientPhone || '').trim();

  if (!form.desc.trim() || !Number.isSafeInteger(rewardMinor) || rewardMinor <= 0 || !Number.isFinite(weight) || weight <= 0) {
    throw new Error('Enter a description, a positive weight, and a positive reward.');
  }
  if (!pickup || !dropoff) {
    throw new Error('Enter pickup and drop-off places anywhere in Bangladesh.');
  }
  if (!recipientPhone) {
    throw new Error('Enter the recipient phone number so the traveler can arrange handoff.');
  }

  const recipientName = (form.recipientName || '').trim();
  const geometry = await buildPackagePointGeometry({ pickup, dropoff });

  const payload = {
    sender_id: userId,
    pickup_location: geometry.pickup_location,
    dropoff_location: geometry.dropoff_location,
    pickup_radius_meters: 2000,
    item_description: form.desc.trim(),
    weight_kg: weight,
    proposed_reward_minor: rewardMinor,
    recipient_phone: recipientPhone,
    is_premium: false,
    status: 'pending',
  };
  if (recipientName) {
    payload.recipient_name = recipientName;
  }

  try {
    return await packageRepository.create(payload);
  } catch (error) {
    // Older schemas may lack recipient_* columns until backend PR #2 is applied.
    if (isMissingColumnError(error, 'recipient_phone') || isMissingColumnError(error, 'recipient_name')) {
      const {
        recipient_phone: _ignoredPhone,
        recipient_name: _ignoredName,
        ...withoutRecipient
      } = payload;
      const contactBits = [`[recipient_phone:${recipientPhone}]`];
      if (recipientName) contactBits.push(`[recipient_name:${recipientName}]`);
      withoutRecipient.item_description = `${payload.item_description}\n${contactBits.join(' ')}`;
      return packageRepository.create(withoutRecipient);
    }
    throw error;
  }
}
