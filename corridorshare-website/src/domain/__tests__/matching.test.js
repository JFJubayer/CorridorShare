import { expect, it } from 'vitest';
import { createMatchingParams } from '../matching';

it('maps matching inputs to the database contract', () => {
  expect(createMatchingParams('trip-1', 5000)).toEqual({ traveler_trip_id: 'trip-1', buffer_distance_meters: 5000 });
});
