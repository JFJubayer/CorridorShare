import '../core/money/money.dart';

/// Wire statuses mirror `public.deal_status`:
/// negotiating | locked | in_transit | completed | cancelled.
/// `escrowLocked` is the app-facing name for DB `locked`.
enum DealStatus { negotiating, escrowLocked, inTransit, completed, cancelled }

extension DealStatusWire on DealStatus {
  String get label => switch (this) {
        DealStatus.negotiating => 'Negotiating',
        DealStatus.escrowLocked => 'Escrow Locked',
        DealStatus.inTransit => 'In Transit',
        DealStatus.completed => 'Completed',
        DealStatus.cancelled => 'Cancelled',
      };

  static DealStatus fromWire(String value) => switch (value.toLowerCase()) {
        'negotiating' => DealStatus.negotiating,
        'locked' => DealStatus.escrowLocked,
        'escrow_locked' => DealStatus.escrowLocked,
        'in_transit' => DealStatus.inTransit,
        'completed' => DealStatus.completed,
        // Historical client alias; refunds cancel the deal in the DB.
        'refunded' => DealStatus.cancelled,
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
  // open_box_verified is set at lock time by lock_deal_with_inspection.
  }) : assert(
          !openBoxVerified ||
              status == DealStatus.escrowLocked ||
              status == DealStatus.inTransit ||
              status == DealStatus.completed,
        );

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
    final minor = json['final_agreed_price_minor'];
    final legacy = json['final_agreed_price'];
    final amountMinor = minor is num
        ? minor.toInt()
        : legacy is num
            ? Money.fromBdt(legacy).minorUnits
            : null;
    if (amountMinor == null) {
      throw const FormatException('Deal price (final_agreed_price_minor) is required.');
    }
    final status = DealStatusWire.fromWire(_requiredString(json, 'status'));
    final locked = (json['deal_locked'] as bool?) ??
        (status == DealStatus.escrowLocked ||
            status == DealStatus.inTransit ||
            status == DealStatus.completed);
    final verified = json['open_box_verified'] as bool? ?? false;
    return DealModel(
      id: _requiredString(json, 'id'),
      tripId: _requiredString(json, 'trip_id'),
      packageId: _requiredString(json, 'package_id'),
      travelerId: _requiredString(json, 'traveler_id'),
      senderId: _requiredString(json, 'sender_id'),
      agreedPrice: Money.fromMinorUnits(amountMinor),
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
