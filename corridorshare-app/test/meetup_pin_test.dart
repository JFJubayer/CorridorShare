import 'package:flutter_test/flutter_test.dart';
import 'package:corridorshare_app/core/chat/meetup_pin.dart';

void main() {
  test('encodes and parses CS_MEETUP_PIN messages like the website', () {
    final encoded = MeetupPin.format(lat: 23.81, lng: 90.41, label: 'Meetup');
    expect(encoded.startsWith('CS_MEETUP_PIN:'), isTrue);

    final pin = MeetupPin.tryParse(encoded);
    expect(pin, isNotNull);
    expect(pin!.lat, closeTo(23.81, 0.0001));
    expect(pin.lng, closeTo(90.41, 0.0001));
    expect(pin.label, 'Meetup');
    expect(pin.mapsUrl, contains('mlat=23.81'));
    expect(MeetupPin.previewOrText(encoded), contains('Meetup pin'));
  });

  test('returns null for ordinary chat text', () {
    expect(MeetupPin.tryParse('Meet near the bus stand'), isNull);
  });
}
