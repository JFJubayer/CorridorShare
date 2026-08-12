import '../core/money/money.dart';

enum PackageStatus { pending, matched, inTransit, delivered, cancelled }

extension PackageStatusWire on PackageStatus {
  static PackageStatus fromWire(String value) => switch (value.toLowerCase()) {
        'pending' => PackageStatus.pending,
        'matched' => PackageStatus.matched,
        'in_transit' => PackageStatus.inTransit,
        'delivered' => PackageStatus.delivered,
        'cancelled' => PackageStatus.cancelled,
        _ => throw FormatException('Unknown package status: $value'),
      };
}

class GeoPoint {
  const GeoPoint(this.latitude, this.longitude)
      : assert(latitude >= -90 && latitude <= 90),
        assert(longitude >= -180 && longitude <= 180);

  final double latitude;
  final double longitude;

  bool isSameAs(GeoPoint other) =>
      latitude == other.latitude && longitude == other.longitude;
}

class PackageModel {
  PackageModel({
    required this.id,
    required this.senderId,
    required this.itemDescription,
    required this.reward,
    required this.status,
    required this.pickup,
    required this.dropoff,
    required this.pickupRadiusMeters,
    required this.distanceFromCorridor,
    required this.isNearMiss,
    required this.routeInfo,
    required this.eta,
    required this.itemType,
    this.isPremium = false,
    this.recipientPhone,
    this.recipientName,
    this.weightKg,
  }) : assert(pickupRadiusMeters > 0),
       assert(distanceFromCorridor >= 0),
       assert(!pickup.isSameAs(dropoff), 'dropoff must differ from pickup');

  final String id;
  final String senderId;
  final String itemDescription;
  final Money reward;
  final bool isPremium;
  final PackageStatus status;
  final GeoPoint pickup;
  final GeoPoint dropoff;
  final int pickupRadiusMeters;
  final double distanceFromCorridor;
  final bool isNearMiss;
  final String routeInfo;
  final DateTime eta;
  final String itemType;
  final String? recipientPhone;
  final String? recipientName;
  final double? weightKg;

  // Temporary presentation compatibility during the UI migration.
  double get proposedReward => reward.asBdt;
  double get pickupLat => pickup.latitude;
  double get pickupLng => pickup.longitude;
  String get etaLabel => '${eta.hour.toString().padLeft(2, '0')}:${eta.minute.toString().padLeft(2, '0')}';

  factory PackageModel.fromJson(Map<String, dynamic> json) {
    final minor = json['proposed_reward_minor'];
    final legacy = json['proposed_reward'];
    final amountMinor = minor is num
        ? minor.toInt()
        : legacy is num
            ? Money.fromBdt(legacy).minorUnits
            : null;
    final lat = (json['pickup_lat'] as num?)?.toDouble();
    final lng = (json['pickup_lng'] as num?)?.toDouble();
    final dropLat = (json['dropoff_lat'] as num?)?.toDouble();
    final dropLng = (json['dropoff_lng'] as num?)?.toDouble();
    final eta = DateTime.tryParse(json['eta'] as String? ?? '') ??
        DateTime.tryParse(json['created_at'] as String? ?? '');
    final radius = (json['pickup_radius_meters'] as num?)?.toInt();
    final distance = (json['distance_from_corridor'] as num?)?.toDouble() ?? 0;
    if (amountMinor == null || lat == null || lng == null || eta == null || radius == null) {
      throw const FormatException('Package payload has invalid required fields.');
    }
    final pickup = GeoPoint(lat, lng);
    final dropoff = (dropLat != null && dropLng != null)
        ? GeoPoint(dropLat, dropLng)
        : GeoPoint(lat + 0.01, lng + 0.01);
    return PackageModel(
      id: _requiredString(json, 'id'),
      senderId: _requiredString(json, 'sender_id'),
      itemDescription: _requiredString(json, 'item_description'),
      reward: Money.fromMinorUnits(amountMinor),
      isPremium: json['is_premium'] as bool? ?? false,
      status: PackageStatusWire.fromWire(_requiredString(json, 'status')),
      pickup: pickup,
      dropoff: dropoff,
      pickupRadiusMeters: radius,
      distanceFromCorridor: distance,
      isNearMiss: json['is_near_miss'] as bool? ?? false,
      routeInfo: (json['route_info'] as String?)?.trim().isNotEmpty == true
          ? json['route_info'] as String
          : 'Corridor match',
      eta: eta,
      itemType: (json['item_type'] as String?)?.trim().isNotEmpty == true
          ? json['item_type'] as String
          : 'Parcel',
      recipientPhone: (json['recipient_phone'] as String?)?.trim(),
      recipientName: (json['recipient_name'] as String?)?.trim(),
      weightKg: (json['weight_kg'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'sender_id': senderId,
        'item_description': itemDescription,
        'proposed_reward_minor': reward.minorUnits,
        'is_premium': isPremium,
        'status': switch (status) {
          PackageStatus.inTransit => 'in_transit',
          _ => status.name,
        },
        'pickup_lat': pickup.latitude,
        'pickup_lng': pickup.longitude,
        'dropoff_lat': dropoff.latitude,
        'dropoff_lng': dropoff.longitude,
        'pickup_radius_meters': pickupRadiusMeters,
        'distance_from_corridor': distanceFromCorridor,
        'is_near_miss': isNearMiss,
        'route_info': routeInfo,
        'eta': eta.toUtc().toIso8601String(),
        'item_type': itemType,
        if (recipientPhone != null && recipientPhone!.isNotEmpty) 'recipient_phone': recipientPhone,
        if (recipientName != null && recipientName!.isNotEmpty) 'recipient_name': recipientName,
        if (weightKg != null) 'weight_kg': weightKg,
      };
}

String _requiredString(Map<String, dynamic> json, String key) {
  final value = json[key];
  if (value is! String || value.trim().isEmpty) {
    throw FormatException('Missing required field: $key');
  }
  return value;
}
