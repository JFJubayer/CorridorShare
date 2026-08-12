import 'package_model.dart';

enum TripStatus { scheduled, active, completed, cancelled }

extension TripStatusLabel on TripStatus {
  String get label => switch (this) {
        TripStatus.scheduled => 'Scheduled',
        TripStatus.active => 'Active',
        TripStatus.completed => 'Completed',
        TripStatus.cancelled => 'Cancelled',
      };

  static TripStatus fromWire(String value) => switch (value.toLowerCase()) {
        'scheduled' => TripStatus.scheduled,
        'active' => TripStatus.active,
        'completed' => TripStatus.completed,
        'cancelled' => TripStatus.cancelled,
        _ => throw FormatException('Unknown trip status: $value'),
      };
}

class TripModel {
  const TripModel({
    required this.id,
    required this.travelerId,
    required this.departureCity,
    required this.destinationCity,
    required this.travelTime,
    required this.weightCapacityKg,
    required this.status,
    required this.travelerName,
    required this.travelerRating,
    this.routePoints = const [],
  }) : assert(weightCapacityKg > 0);

  final String id;
  final String travelerId;
  final String departureCity;
  final String destinationCity;
  final DateTime travelTime;
  final double weightCapacityKg;
  final TripStatus status;
  final String travelerName;
  final double travelerRating;
  final List<GeoPoint> routePoints;

  String get travelTimeLabel => '${travelTime.hour.toString().padLeft(2, '0')}:${travelTime.minute.toString().padLeft(2, '0')}';
  String get travelerRatingLabel => '${travelerRating.toStringAsFixed(1)} ★';

  factory TripModel.fromJson(Map<String, dynamic> json) {
    final time = DateTime.tryParse(json['travel_time'] as String? ?? '');
    final capacity = (json['weight_capacity_kg'] as num?)?.toDouble();
    final rating = (json['traveler_rating'] as num?)?.toDouble() ?? 0;
    if (time == null || capacity == null || capacity <= 0) {
      throw const FormatException('Trip payload has invalid required fields.');
    }
    return TripModel(
      id: _requiredString(json, 'id'),
      travelerId: _requiredString(json, 'traveler_id'),
      departureCity: _requiredString(json, 'departure_city'),
      destinationCity: _requiredString(json, 'destination_city'),
      travelTime: time,
      weightCapacityKg: capacity,
      status: TripStatusLabel.fromWire(_requiredString(json, 'status')),
      travelerName: (json['traveler_name'] as String?)?.trim().isNotEmpty == true
          ? json['traveler_name'] as String
          : 'Verified traveler',
      travelerRating: rating,
      routePoints: _routePointsFrom(json['route_path']),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'traveler_id': travelerId,
        'departure_city': departureCity,
        'destination_city': destinationCity,
        'travel_time': travelTime.toUtc().toIso8601String(),
        'weight_capacity_kg': weightCapacityKg,
        'status': status.name,
        'traveler_name': travelerName,
        'traveler_rating': travelerRating,
      };
}

List<GeoPoint> _routePointsFrom(dynamic value) {
  if (value is Map && value['coordinates'] is List) {
    final coords = value['coordinates'] as List<dynamic>;
    return coords
        .whereType<List>()
        .where((pair) => pair.length >= 2)
        .map((pair) => GeoPoint((pair[1] as num).toDouble(), (pair[0] as num).toDouble()))
        .toList(growable: false);
  }
  if (value is String) {
    final match = RegExp(r'LINESTRING\((.+)\)', caseSensitive: false).firstMatch(value);
    if (match != null) {
      return match
          .group(1)!
          .split(',')
          .map((segment) {
            final parts = segment.trim().split(RegExp(r'\s+'));
            return GeoPoint(double.parse(parts[1]), double.parse(parts[0]));
          })
          .toList(growable: false);
    }
  }
  return const [];
}

String _requiredString(Map<String, dynamic> json, String key) {
  final value = json[key];
  if (value is! String || value.trim().isEmpty) {
    throw FormatException('Missing required field: $key');
  }
  return value;
}
