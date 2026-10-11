// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'CorridorShare';

  @override
  String get tabHome => 'Home';

  @override
  String get tabMyPosts => 'My posts';

  @override
  String get tabChats => 'Chats';

  @override
  String get tabProfile => 'Profile';

  @override
  String get phoneLabel => 'Phone number';

  @override
  String get phoneHint => '01XXXXXXXXX';

  @override
  String get phoneContinue => 'Continue';

  @override
  String get phoneInvalid => 'Enter a valid Bangladeshi mobile number.';

  @override
  String get otpTitle => 'Enter the 6-digit code';

  @override
  String get otpHint => '6-digit code';

  @override
  String get otpVerify => 'Verify';

  @override
  String get otpResend => 'Resend code';

  @override
  String get otpInvalid => 'The code is incorrect. Try again.';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageBangla => 'বাংলা';

  @override
  String get logout => 'Log out';

  @override
  String get profileNamePlaceholder => 'Your name';

  @override
  String get profileVerified => 'Verified';

  @override
  String get profileUnverified => 'Not verified';

  @override
  String get profileRating => 'Rating';

  @override
  String get homeGreeting => 'Welcome to CorridorShare';

  @override
  String get homeEmpty => 'No trips or parcels to show yet.';

  @override
  String get myPostsSending => 'Sending';

  @override
  String get myPostsCarrying => 'Carrying';

  @override
  String get chatsEmpty => 'No conversations yet.';

  @override
  String get commonRetry => 'Retry';

  @override
  String get commonCancel => 'Cancel';

  @override
  String get commonLoading => 'Loading…';
}
