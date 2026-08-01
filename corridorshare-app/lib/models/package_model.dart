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
}

class PackageModel {
  const PackageModel({
    required this.id,
    required this.senderId,
    required this.itemDescription,
    required this.reward,
    required this.status,
    required this.pickup,
    required this.pickupRadiusMeters,
    required this.distanceFromCorridor,
    required this.isNearMiss,
    required this.routeInfo,
    required this.eta,
    required this.itemType,
    this.isPremium = false,
  }) : assert(pickupRadiusMeters > 0),
       assert(distanceFromCorridor >= 0);

  final String id;
  final String senderId;
  final String itemDescription;
  final Money reward;
  final bool isPremium;
  final PackageStatus status;
  final GeoPoint pickup;
  final int pickupRadiusMeters;
  final double distanceFromCorridor;
  final bool isNearMiss;
  final String routeInfo;
  final DateTime eta;
  final String itemType;

  // Temporary presentation compatibility during the UI migration.
  double get proposedReward => reward.asBdt;
  double get pickupLat => pickup.latitude;
  double get pickupLng => pickup.longitude;
  String get etaLabel => '${eta.hour.toString().padLeft(2, '0')}:${eta.minute.toString().padLeft(2, '0')}';

  factory PackageModel.fromJson(Map<String, dynamic> json) {
    final amount = json['proposed_reward'];
    final lat = (json['pickup_lat'] as num?)?.toDouble();
    final lng = (json['pickup_lng'] as num?)?.toDouble();
    final eta = DateTime.tryParse(json['eta'] as String? ?? '');
    final radius = json['pickup_radius_meters'] as int?;
    final distance = (json['distance_from_corridor'] as num?)?.toDouble();
    if (amount is! num || lat == null || lng == null || eta == null || radius == null || distance == null) {
      throw const FormatException('Package payload has invalid required fields.');
    }
    return PackageModel(
      id: _requiredString(json, 'id'),
      senderId: _requiredString(json, 'sender_id'),
      itemDescription: _requiredString(json, 'item_description'),
      reward: Money.fromBdt(amount),
      isPremium: json['is_premium'] as bool? ?? false,
      status: PackageStatusWire.fromWire(_requiredString(json, 'status')),
      pickup: GeoPoint(lat, lng),
      pickupRadiusMeters: radius,
      distanceFromCorridor: distance,
      isNearMiss: json['is_near_miss'] as bool? ?? false,
      routeInfo: _requiredString(json, 'route_info'),
      eta: eta,
      itemType: _requiredString(json, 'item_type'),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'sender_id': senderId,
        'item_description': itemDescription,
        'proposed_reward': reward.asBdt,
        'is_premium': isPremium,
        'status': status.name,
        'pickup_lat': pickup.latitude,
        'pickup_lng': pickup.longitude,
        'pickup_radius_meters': pickupRadiusMeters,
        'distance_from_corridor': distanceFromCorridor,
        'is_near_miss': isNearMiss,
        'route_info': routeInfo,
        'eta': eta.toUtc().toIso8601String(),
        'item_type': itemType,
      };
}

String _requiredString(Map<String, dynamic> json, String key) {
  final value = json[key];
  if (value is! String || value.trim().isEmpty) {
    throw FormatException('Missing required field: $key');
  }
  return value;
}
