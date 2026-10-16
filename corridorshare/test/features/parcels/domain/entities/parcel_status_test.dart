import 'package:corridorshare/features/parcels/domain/entities/parcel_status.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ParcelStatus state transitions', () {
    test('open transitions to matched or cancelled', () {
      expect(ParcelStatus.open.canTransitionTo(ParcelStatus.matched), isTrue);
      expect(ParcelStatus.open.canTransitionTo(ParcelStatus.cancelled), isTrue);
      expect(ParcelStatus.open.canTransitionTo(ParcelStatus.inTransit), isFalse);
      expect(ParcelStatus.open.canTransitionTo(ParcelStatus.delivered), isFalse);
    });

    test('matched transitions to inTransit or cancelled', () {
      expect(ParcelStatus.matched.canTransitionTo(ParcelStatus.inTransit), isTrue);
      expect(ParcelStatus.matched.canTransitionTo(ParcelStatus.cancelled), isTrue);
      expect(ParcelStatus.matched.canTransitionTo(ParcelStatus.delivered), isFalse);
    });

    test('inTransit transitions to delivered or disputed', () {
      expect(ParcelStatus.inTransit.canTransitionTo(ParcelStatus.delivered), isTrue);
      expect(ParcelStatus.inTransit.canTransitionTo(ParcelStatus.disputed), isTrue);
      expect(ParcelStatus.inTransit.canTransitionTo(ParcelStatus.cancelled), isFalse);
    });

    test('disputed transitions to delivered or cancelled', () {
      expect(ParcelStatus.disputed.canTransitionTo(ParcelStatus.delivered), isTrue);
      expect(ParcelStatus.disputed.canTransitionTo(ParcelStatus.cancelled), isTrue);
    });

    test('delivered and cancelled are terminal states', () {
      expect(ParcelStatus.delivered.canTransitionTo(ParcelStatus.open), isFalse);
      expect(ParcelStatus.delivered.canTransitionTo(ParcelStatus.disputed), isFalse);
      expect(ParcelStatus.cancelled.canTransitionTo(ParcelStatus.open), isFalse);
    });
  });
}
