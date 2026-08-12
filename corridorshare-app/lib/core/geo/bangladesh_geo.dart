import '../../models/package_model.dart';

/// Bangladesh-wide corridor waypoints used for trip routes and package
/// pickup/dropoff selection. Values are WGS84 and intentionally cover major
/// highways beyond a single N3 segment.
class BdPlace {
  const BdPlace({
    required this.id,
    required this.label,
    required this.region,
    required this.point,
  });

  final String id;
  final String label;
  final String region;
  final GeoPoint point;
}

class BangladeshGeo {
  BangladeshGeo._();

  static const List<BdPlace> places = [
    BdPlace(id: 'dhaka_uttara', label: 'Dhaka — Uttara', region: 'Dhaka', point: GeoPoint(23.8759, 90.3795)),
    BdPlace(id: 'dhaka_airport', label: 'Dhaka — Airport Road', region: 'Dhaka', point: GeoPoint(23.8513, 90.4086)),
    BdPlace(id: 'dhaka_motijheel', label: 'Dhaka — Motijheel', region: 'Dhaka', point: GeoPoint(23.7330, 90.4172)),
    BdPlace(id: 'gazipur', label: 'Gazipur Chaurasta', region: 'Dhaka', point: GeoPoint(23.9999, 90.4203)),
    BdPlace(id: 'tangail', label: 'Tangail', region: 'Dhaka', point: GeoPoint(24.2513, 89.9167)),
    BdPlace(id: 'mymensingh', label: 'Mymensingh Bypass', region: 'Mymensingh', point: GeoPoint(24.7471, 90.4203)),
    BdPlace(id: 'jamalpur', label: 'Jamalpur', region: 'Mymensingh', point: GeoPoint(24.9375, 89.9370)),
    BdPlace(id: 'chittagong', label: 'Chattogram — Agrabad', region: 'Chattogram', point: GeoPoint(22.3239, 91.8117)),
    BdPlace(id: 'coxsbazar', label: "Cox's Bazar", region: 'Chattogram', point: GeoPoint(21.4272, 92.0058)),
    BdPlace(id: 'comilla', label: 'Cumilla', region: 'Chattogram', point: GeoPoint(23.4607, 91.1809)),
    BdPlace(id: 'sylhet', label: 'Sylhet — Zindabazar', region: 'Sylhet', point: GeoPoint(24.8949, 91.8687)),
    BdPlace(id: 'rajshahi', label: 'Rajshahi', region: 'Rajshahi', point: GeoPoint(24.3745, 88.6042)),
    BdPlace(id: 'rangpur', label: 'Rangpur', region: 'Rangpur', point: GeoPoint(25.7439, 89.2752)),
    BdPlace(id: 'khulna', label: 'Khulna', region: 'Khulna', point: GeoPoint(22.8456, 89.5403)),
    BdPlace(id: 'barishal', label: 'Barishal', region: 'Barishal', point: GeoPoint(22.7010, 90.3535)),
    BdPlace(id: 'bogura', label: 'Bogura', region: 'Rajshahi', point: GeoPoint(24.8465, 89.3770)),
  ];

  static BdPlace? byId(String id) {
    for (final place in places) {
      if (place.id == id) return place;
    }
    return null;
  }

  static String pointWkt(GeoPoint point) =>
      'POINT(${point.longitude} ${point.latitude})';

  static String lineStringWkt(List<GeoPoint> points) {
    if (points.length < 2) {
      throw ArgumentError('A route needs at least two geographic points.');
    }
    final body = points.map((p) => '${p.longitude} ${p.latitude}').join(', ');
    return 'LINESTRING($body)';
  }

  /// Build a simple corridor polyline between two catalog places. When the
  /// endpoints are far apart we keep them as the authoritative user input
  /// rather than inventing a hardcoded national highway.
  static List<GeoPoint> routeBetween(BdPlace departure, BdPlace destination) {
    if (departure.id == destination.id) {
      throw ArgumentError('Departure and destination must be different places.');
    }
    return [departure.point, destination.point];
  }
}
