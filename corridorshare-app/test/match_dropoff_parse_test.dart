import 'package:flutter_test/flutter_test.dart';
import 'package:corridorshare_app/models/package_model.dart';

void main() {
  test('package JSON prefers real dropoff_lat/lng when present', () {
    final pkg = PackageModel.fromJson({
      'id': 'pkg-1',
      'sender_id': 'sender-1',
      'item_description': 'Docs',
      'proposed_reward_minor': 45000,
      'status': 'pending',
      'pickup_lat': 23.81,
      'pickup_lng': 90.41,
      'dropoff_lat': 24.75,
      'dropoff_lng': 90.42,
      'pickup_radius_meters': 2000,
      'distance_from_corridor': 120,
      'is_near_miss': false,
      'eta': '2026-08-12T12:00:00Z',
      'item_type': 'Parcel',
      'weight_kg': 2.5,
    });
    expect(pkg.dropoff.latitude, closeTo(24.75, 0.0001));
    expect(pkg.dropoff.longitude, closeTo(90.42, 0.0001));
    expect(pkg.weightKg, 2.5);
  });
}
