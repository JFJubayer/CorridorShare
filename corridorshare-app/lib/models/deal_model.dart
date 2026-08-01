import '../core/money/money.dart';

enum DealStatus { negotiating, escrowLocked, completed, refunded, cancelled }

extension DealStatusWire on DealStatus {
  String get label => switch (this) {
        DealStatus.negotiating => 'Negotiating',
        DealStatus.escrowLocked => 'Escrow Locked',
        DealStatus.completed => 'Completed',
        DealStatus.refunded => 'Refunded',
        DealStatus.cancelled => 'Cancelled',
      };

  static DealStatus fromWire(String value) => switch (value.toLowerCase()) {
        'negotiating' => DealStatus.negotiating,
        'locked' => DealStatus.escrowLocked,
        'escrow_locked' => DealStatus.escrowLocked,
        'completed' => DealStatus.completed,
        'refunded' => DealStatus.refunded,
        'cancelled' => DealStatus.cancelled,
        _ => throw FormatException('Unknown deal status: $value'),
      };
}

class DealModel {
  const DealModel({
    required this.id,
    required this.tripId,
    required this.packageId,
    required this.travelerId,
    required this.senderId,
    required this.agreedPrice,
    required this.status,
    required this.packageItem,
    required this.routeInfo,
    this.dealLocked = false,
    this.openBoxVerified = false,
  }) : assert(dealLocked == (status == DealStatus.escrowLocked || status == DealStatus.completed)),
       assert(!openBoxVerified || status == DealStatus.completed);

  final String id;
  final String tripId;
  final String packageId;
  final String travelerId;
  final String senderId;
  final Money agreedPrice;
  final bool dealLocked;
  final bool openBoxVerified;
  final DealStatus status;
  final String packageItem;
  final String routeInfo;

  DealModel copyWith({
    Money? agreedPrice,
    bool? dealLocked,
    bool? openBoxVerified,
    DealStatus? status,
  }) =>
      DealModel(
        id: id,
        tripId: tripId,
        packageId: packageId,
        travelerId: travelerId,
        senderId: senderId,
        agreedPrice: agreedPrice ?? this.agreedPrice,
        dealLocked: dealLocked ?? this.dealLocked,
        openBoxVerified: openBoxVerified ?? this.openBoxVerified,
        status: status ?? this.status,
        packageItem: packageItem,
        routeInfo: routeInfo,
      );

  factory DealModel.fromJson(Map<String, dynamic> json) {
    final amount = json['final_agreed_price'];
    if (amount is! num) {
      throw const FormatException('Deal price is required.');
    }
    final status = DealStatusWire.fromWire(_requiredString(json, 'status'));
    final locked = (json['deal_locked'] as bool?) ??
        (status == DealStatus.escrowLocked || status == DealStatus.completed);
    final verified = (json['open_box_verified'] as bool?) ??
        status == DealStatus.completed;
    return DealModel(
      id: _requiredString(json, 'id'),
      tripId: _requiredString(json, 'trip_id'),
      packageId: _requiredString(json, 'package_id'),
      travelerId: _requiredString(json, 'traveler_id'),
      senderId: _requiredString(json, 'sender_id'),
      agreedPrice: Money.fromBdt(amount),
      dealLocked: locked,
      openBoxVerified: verified,
      status: status,
      packageItem: _requiredString(json, 'package_item'),
      routeInfo: _requiredString(json, 'route_info'),
    );
  }
}

class ChatMessageModel {
  const ChatMessageModel({
    required this.id,
    required this.dealId,
    required this.senderId,
    required this.senderName,
    required this.text,
    required this.createdAt,
    this.imageUrl,
  }) : assert(text != '');

  final String id;
  final String dealId;
  final String senderId;
  final String senderName;
  final String text;
  final DateTime createdAt;
  final String? imageUrl;

  String get timestamp => '${createdAt.hour.toString().padLeft(2, '0')}:${createdAt.minute.toString().padLeft(2, '0')}';
}

String _requiredString(Map<String, dynamic> json, String key) {
  final value = json[key];
  if (value is! String || value.trim().isEmpty) {
    throw FormatException('Missing required field: $key');
  }
  return value;
}
