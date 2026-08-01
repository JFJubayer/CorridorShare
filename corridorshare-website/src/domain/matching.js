export const MATCHING_RPC = 'match_packages_within_corridor';

export function createMatchingParams(travelerTripId, bufferDistanceMeters) {
  return { traveler_trip_id: travelerTripId, buffer_distance_meters: bufferDistanceMeters };
}
