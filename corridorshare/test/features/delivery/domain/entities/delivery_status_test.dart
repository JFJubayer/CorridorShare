import 'package:corridorshare/features/delivery/domain/entities/delivery_status.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DeliveryStatus transitions', () {
    test('matched can transition to inTransit and cancelled', () {
      expect(
        DeliveryStatus.matched.canTransitionTo(DeliveryStatus.inTransit),
        isTrue,
      );
      expect(
        DeliveryStatus.matched.canTransitionTo(DeliveryStatus.cancelled),
        isTrue,
      );
      expect(
        DeliveryStatus.matched.canTransitionTo(DeliveryStatus.delivered),
        isFalse,
      );
    });

    test('inTransit can transition to delivered and disputed', () {
      expect(
        DeliveryStatus.inTransit.canTransitionTo(DeliveryStatus.delivered),
        isTrue,
      );
      expect(
        DeliveryStatus.inTransit.canTransitionTo(DeliveryStatus.disputed),
        isTrue,
      );
      expect(
        DeliveryStatus.inTransit.canTransitionTo(DeliveryStatus.matched),
        isFalse,
      );
    });

    test('disputed can transition to delivered or cancelled', () {
      expect(
        DeliveryStatus.disputed.canTransitionTo(DeliveryStatus.delivered),
        isTrue,
      );
      expect(
        DeliveryStatus.disputed.canTransitionTo(DeliveryStatus.cancelled),
        isTrue,
      );
    });

    test('delivered and cancelled are terminal states', () {
      expect(DeliveryStatus.delivered.isTerminal, isTrue);
      expect(DeliveryStatus.cancelled.isTerminal, isTrue);
      expect(DeliveryStatus.matched.isTerminal, isFalse);
      expect(DeliveryStatus.inTransit.isTerminal, isFalse);
      expect(DeliveryStatus.disputed.isTerminal, isFalse);

      expect(
        DeliveryStatus.delivered.canTransitionTo(DeliveryStatus.inTransit),
        isFalse,
      );
      expect(
        DeliveryStatus.cancelled.canTransitionTo(DeliveryStatus.matched),
        isFalse,
      );
    });
  });
}
