import 'dart:convert';

/// Meetup pin chat convention — must stay in parity with
/// `corridorshare-website/src/shared/chat/meetupPin.js`.
class MeetupPin {
  const MeetupPin({
    required this.lat,
    required this.lng,
    this.label = 'Meetup',
  });

  static const prefix = 'CS_MEETUP_PIN:';

  final double lat;
  final double lng;
  final String label;

  String encode() => '$prefix${jsonEncode({
        'lat': lat,
        'lng': lng,
        'label': label,
      })}';

  String get mapsUrl =>
      'https://www.openstreetmap.org/?mlat=$lat&mlon=$lng#map=16/$lat/$lng';

  String get preview =>
      'Meetup pin: $label (${lat.toStringAsFixed(4)}, ${lng.toStringAsFixed(4)})';

  static MeetupPin? tryParse(String text) {
    if (!text.startsWith(prefix)) return null;
    try {
      final data = jsonDecode(text.substring(prefix.length));
      if (data is! Map) return null;
      final lat = _asDouble(data['lat']);
      final lng = _asDouble(data['lng']);
      if (lat == null || lng == null) return null;
      final rawLabel = data['label'];
      final label = rawLabel is String && rawLabel.trim().isNotEmpty
          ? rawLabel.trim()
          : 'Meetup';
      return MeetupPin(lat: lat, lng: lng, label: label);
    } on Object {
      return null;
    }
  }

  static String format({
    required double lat,
    required double lng,
    String label = 'Meetup',
  }) =>
      MeetupPin(lat: lat, lng: lng, label: label).encode();

  static String previewOrText(String text) {
    final pin = tryParse(text);
    return pin?.preview ?? text;
  }
}

double? _asDouble(Object? value) {
  if (value is num && value.isFinite) return value.toDouble();
  if (value is String) return double.tryParse(value);
  return null;
}
