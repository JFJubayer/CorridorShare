import 'package:corridorshare/features/offers/domain/entities/offer_status.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('OfferStatus transitions', () {
    test('pendingTraveller can transition to pendingSender, accepted, rejected, cancelled', () {
      expect(
        OfferStatus.pendingTraveller.canTransitionTo(OfferStatus.pendingSender),
        isTrue,
      );
      expect(
        OfferStatus.pendingTraveller.canTransitionTo(OfferStatus.accepted),
        isTrue,
      );
      expect(
        OfferStatus.pendingTraveller.canTransitionTo(OfferStatus.rejected),
        isTrue,
      );
      expect(
        OfferStatus.pendingTraveller.canTransitionTo(OfferStatus.cancelled),
        isTrue,
      );
      expect(
        OfferStatus.pendingTraveller.canTransitionTo(OfferStatus.pendingTraveller),
        isTrue,
      );
    });

    test('pendingSender can transition to pendingTraveller, accepted, rejected, cancelled', () {
      expect(
        OfferStatus.pendingSender.canTransitionTo(OfferStatus.pendingTraveller),
        isTrue,
      );
      expect(
        OfferStatus.pendingSender.canTransitionTo(OfferStatus.accepted),
        isTrue,
      );
      expect(
        OfferStatus.pendingSender.canTransitionTo(OfferStatus.rejected),
        isTrue,
      );
      expect(
        OfferStatus.pendingSender.canTransitionTo(OfferStatus.cancelled),
        isTrue,
      );
    });

    test('terminal states cannot transition to any other state', () {
      for (final terminal in [
        OfferStatus.accepted,
        OfferStatus.rejected,
        OfferStatus.cancelled,
      ]) {
        expect(terminal.isTerminal, isTrue);
        expect(terminal.canTransitionTo(OfferStatus.pendingSender), isFalse);
        expect(terminal.canTransitionTo(OfferStatus.pendingTraveller), isFalse);
      }

      expect(OfferStatus.pendingTraveller.isTerminal, isFalse);
      expect(OfferStatus.pendingSender.isTerminal, isFalse);
    });
  });
}
