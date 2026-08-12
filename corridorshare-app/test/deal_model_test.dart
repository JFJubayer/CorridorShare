import 'package:flutter_test/flutter_test.dart';
import 'package:corridorshare_app/core/money/money.dart';
import 'package:corridorshare_app/models/deal_model.dart';

void main() {
  test('openBoxVerified is allowed while escrow is locked', () {
    final deal = DealModel(
      id: 'd1',
      tripId: 't1',
      packageId: 'p1',
      travelerId: 'tr',
      senderId: 's',
      agreedPrice: Money.fromBdt(100),
      status: DealStatus.escrowLocked,
      dealLocked: true,
      openBoxVerified: true,
      packageItem: 'Docs',
      routeInfo: 'Dhaka → Sylhet',
    );
    expect(deal.openBoxVerified, isTrue);
    expect(DealStatusWire.fromWire('locked'), DealStatus.escrowLocked);
    expect(DealStatusWire.fromWire('in_transit'), DealStatus.inTransit);
    expect(DealStatusWire.fromWire('refunded'), DealStatus.cancelled);
  });

  test('fromJson reads final_agreed_price_minor', () {
    final deal = DealModel.fromJson({
      'id': 'd1',
      'trip_id': 't1',
      'package_id': 'p1',
      'traveler_id': 'tr',
      'sender_id': 's',
      'final_agreed_price_minor': 25000,
      'status': 'locked',
      'deal_locked': true,
      'open_box_verified': true,
      'package_item': 'Docs',
      'route_info': 'Route',
    });
    expect(deal.agreedPrice.minorUnits, 25000);
    expect(deal.status, DealStatus.escrowLocked);
  });
}
