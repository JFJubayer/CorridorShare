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

  String get travelTimeLabel => '${travelTime.hour.toString().padLeft(2, '0')}:${travelTime.minute.toString().padLeft(2, '0')}';
  String get travelerRatingLabel => '${travelerRating.toStringAsFixed(1)} ★';

  factory TripModel.fromJson(Map<String, dynamic> json) {
    final time = DateTime.tryParse(json['travel_time'] as String? ?? '');
    final capacity = (json['weight_capacity_kg'] as num?)?.toDouble();
    final rating = (json['traveler_rating'] as num?)?.toDouble();
    if (time == null || capacity == null || capacity <= 0 || rating == null) {
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
      travelerName: _requiredString(json, 'traveler_name'),
      travelerRating: rating,
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

String _requiredString(Map<String, dynamic> json, String key) {
  final value = json[key];
  if (value is! String || value.trim().isEmpty) {
    throw FormatException('Missing required field: $key');
  }
  return value;
}
