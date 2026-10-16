import 'package:corridorshare/features/trips/domain/entities/trip_status.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('TripStatus state transitions', () {
    test('open can transition to full, completed, cancelled', () {
      expect(TripStatus.open.canTransitionTo(TripStatus.full), isTrue);
      expect(TripStatus.open.canTransitionTo(TripStatus.completed), isTrue);
      expect(TripStatus.open.canTransitionTo(TripStatus.cancelled), isTrue);
    });

    test('full can transition to open, completed, cancelled', () {
      expect(TripStatus.full.canTransitionTo(TripStatus.open), isTrue);
      expect(TripStatus.full.canTransitionTo(TripStatus.completed), isTrue);
      expect(TripStatus.full.canTransitionTo(TripStatus.cancelled), isTrue);
    });

    test('completed and cancelled are terminal states', () {
      expect(TripStatus.completed.canTransitionTo(TripStatus.open), isFalse);
      expect(TripStatus.completed.canTransitionTo(TripStatus.full), isFalse);
      expect(TripStatus.cancelled.canTransitionTo(TripStatus.open), isFalse);
      expect(TripStatus.cancelled.canTransitionTo(TripStatus.completed), isFalse);
    });
  });
}
