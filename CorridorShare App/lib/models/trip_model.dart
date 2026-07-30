class TripModel {
  final String id;
  final String travelerId;
  final String departureCity;
  final String destinationCity;
  final String travelTime;
  final double weightCapacityKg;
  final String status;
  final String travelerName;
  final String travelerRating;

  TripModel({
    required this.id,
    required this.travelerId,
    required this.departureCity,
    required this.destinationCity,
    required this.travelTime,
    required this.weightCapacityKg,
    this.status = 'scheduled',
    this.travelerName = 'Aminul Islam',
    this.travelerRating = '4.9 ★',
  });

  factory TripModel.fromJson(Map<String, dynamic> json) {
    return TripModel(
      id: json['id'] ?? '',
      travelerId: json['traveler_id'] ?? '',
      departureCity: json['departure_city'] ?? 'Dhaka',
      destinationCity: json['destination_city'] ?? 'Mymensingh',
      travelTime: json['travel_time'] ?? 'Tonight 8 PM',
      weightCapacityKg: (json['weight_capacity_kg'] as num?)?.toDouble() ?? 5.0,
      status: json['status'] ?? 'scheduled',
      travelerName: json['traveler_name'] ?? 'Aminul Islam',
      travelerRating: json['traveler_rating'] ?? '4.9 ★',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'traveler_id': travelerId,
      'departure_city': departureCity,
      'destination_city': destinationCity,
      'travel_time': travelTime,
      'weight_capacity_kg': weightCapacityKg,
      'status': status,
      'traveler_name': travelerName,
      'traveler_rating': travelerRating,
    };
  }
}
