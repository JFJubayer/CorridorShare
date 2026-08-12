import { describe, expect, it } from 'vitest';
import { pointWkt, routeWkt } from './routeGeometry';

describe('routeGeometry helpers', () => {
  it('formats PostGIS-friendly WKT', () => {
    expect(pointWkt({ latitude: 23.7, longitude: 90.4 })).toBe('POINT(90.4 23.7)');
    expect(routeWkt([
      { latitude: 23.7, longitude: 90.4 },
      { latitude: 24.7, longitude: 90.5 },
    ])).toBe('LINESTRING(90.4 23.7, 90.5 24.7)');
  });
});
