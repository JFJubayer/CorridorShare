import 'package:corridorshare/features/auth/domain/entities/phone_number.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PhoneNumber.tryParse', () {
    test('accepts local form 01XXXXXXXXX', () {
      final PhoneNumber? phone = PhoneNumber.tryParse('01712345678');
      expect(phone, isNotNull);
      expect(phone!.e164, '+8801712345678');
      expect(phone.local, '1712345678');
    });

    test('accepts E.164 form +880XXXXXXXXXX', () {
      final PhoneNumber? phone = PhoneNumber.tryParse('+8801712345678');
      expect(phone, isNotNull);
      expect(phone!.e164, '+8801712345678');
    });

    test('strips whitespace', () {
      final PhoneNumber? phone = PhoneNumber.tryParse('  01712 345 678 ');
      expect(phone, isNotNull);
      expect(phone!.e164, '+8801712345678');
    });

    test('rejects numbers that are too short', () {
      expect(PhoneNumber.tryParse('0171234567'), isNull);
    });

    test('rejects numbers that are too long', () {
      expect(PhoneNumber.tryParse('017123456789'), isNull);
    });

    test('rejects numbers that do not start with 01', () {
      expect(PhoneNumber.tryParse('+8802712345678'), isNull);
      expect(PhoneNumber.tryParse('02712345678'), isNull);
    });

    test('rejects non-numeric characters', () {
      expect(PhoneNumber.tryParse('01712abc678'), isNull);
    });
  });

  group('PhoneNumber.parse', () {
    test('throws FormatException for invalid input', () {
      expect(() => PhoneNumber.parse('123'), throwsFormatException);
    });
  });
}
