class PackageModel {
  final String id;
  final String senderId;
  final String itemDescription;
  final double proposedReward;
  final bool isPremium;
  final String status;
  final double pickupLat;
  final double pickupLng;
  final int pickupRadiusMeters;
  final double distanceFromCorridor;
  final bool isNearMiss;
  final String routeInfo;
  final String eta;
  final String itemType;

  PackageModel({
    required this.id,
    required this.senderId,
    required this.itemDescription,
    required this.proposedReward,
    this.isPremium = false,
    this.status = 'pending',
    required this.pickupLat,
    required this.pickupLng,
    this.pickupRadiusMeters = 2000,
    this.distanceFromCorridor = 0.0,
    this.isNearMiss = false,
    this.routeInfo = 'Dhaka to Mymensingh',
    this.eta = 'Today',
    this.itemType = 'Parcel Cargo',
  });

  factory PackageModel.fromJson(Map<String, dynamic> json) {
    return PackageModel(
      id: json['id'] ?? json['package_id'] ?? '',
      senderId: json['sender_id'] ?? '',
      itemDescription: json['item_description'] ?? json['item_type'] ?? 'Package Item',
      proposedReward: (json['proposed_reward'] as num?)?.toDouble() ?? 150.0,
      isPremium: json['is_premium'] ?? false,
      status: json['status'] ?? 'pending',
      pickupLat: (json['pickup_lat'] as num?)?.toDouble() ?? 23.777176,
      pickupLng: (json['pickup_lng'] as num?)?.toDouble() ?? 90.399452,
      pickupRadiusMeters: json['pickup_radius_meters'] ?? 2000,
      distanceFromCorridor: (json['distance_from_corridor'] as num?)?.toDouble() ?? 0.0,
      isNearMiss: json['is_near_miss'] ?? false,
      routeInfo: json['route_info'] ?? 'Dhaka to Mymensingh Corridor',
      eta: json['eta'] ?? 'Today 6 PM',
      itemType: json['item_type'] ?? 'Parcel Cargo',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sender_id': senderId,
      'item_description': itemDescription,
      'proposed_reward': proposedReward,
      'is_premium': isPremium,
      'status': status,
      'pickup_lat': pickupLat,
      'pickup_lng': pickupLng,
      'pickup_radius_meters': pickupRadiusMeters,
      'distance_from_corridor': distanceFromCorridor,
      'is_near_miss': isNearMiss,
      'route_info': routeInfo,
      'eta': eta,
      'item_type': itemType,
    };
  }
}
