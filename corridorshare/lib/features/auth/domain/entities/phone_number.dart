import 'package:freezed_annotation/freezed_annotation.dart';

part 'phone_number.freezed.dart';

/// Bangladesh-aware phone number value object.
///
/// We accept two shapes that map to the same underlying E.164 number:
///  - `+8801XXXXXXXXX` (E.164, 14 chars including the leading `+`)
///  - `01XXXXXXXXX` (local form, 11 chars)
///
/// Use [PhoneNumber.tryParse] (returns `null` for invalid input) or
/// [PhoneNumber.parse] (throws [FormatException]). There is no public
/// const constructor so validation cannot be bypassed.
@freezed
abstract class PhoneNumber with _$PhoneNumber {

  /// Parse a user-supplied phone string. Throws [FormatException] on invalid
  /// input — callers should wrap in a `try` or rely on [tryParse].
  factory PhoneNumber.parse(String input) {
    final PhoneNumber? value = tryParse(input);
    if (value == null) {
      throw FormatException('Invalid Bangladeshi phone number: $input');
    }
    return value;
  }
  const PhoneNumber._();

  /// Construct from an E.164 string that has already been validated.
  /// Prefer [PhoneNumber.tryParse] / [PhoneNumber.parse].
  const factory PhoneNumber(String e164) = _PhoneNumber;

  /// Local display form, always `XXXXXXXXXX` (10 digits after the leading
  /// 0, total 11 chars).
  String get local => e164.startsWith('+880')
      ? e164.substring(4)
      : e164;

  /// Non-throwing variant of [parse]. Returns `null` for invalid input.
  static PhoneNumber? tryParse(String input) {
    final String trimmed = input.trim().replaceAll(RegExp(r'\s+'), '');
    if (!RegExp(r'^\+?\d+$').hasMatch(trimmed)) {
      return null;
    }
    if (trimmed.startsWith('+8801') && trimmed.length == 14) {
      return PhoneNumber(trimmed);
    }
    if (trimmed.startsWith('01') && trimmed.length == 11) {
      return PhoneNumber('+880${trimmed.substring(1)}');
    }
    return null;
  }

  @override
  String toString() => e164;
}
