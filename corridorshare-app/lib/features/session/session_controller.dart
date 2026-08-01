import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/config/app_config.dart';

enum AppRole { sender, traveler }
enum NidStatus { unverified, pending, verified, suspended }

class SessionController extends ChangeNotifier {
  SessionController({required AppConfig config}) : _config = config;

  final AppConfig _config;
  AppRole _role = AppRole.sender;
  bool _isAuthenticated = false;
  String _phone = '';
  NidStatus _nidStatus = NidStatus.unverified;
  bool _isDarkMode = true;
  String _userId = '00000000-0000-4000-8000-000000000111';

  AppRole get role => _role;
  bool get isTraveler => _role == AppRole.traveler;
  bool get isAuthenticated => _isAuthenticated;
  String get phone => _phone;
  NidStatus get nidStatus => _nidStatus;
  bool get isDarkMode => _isDarkMode;
  String get userId => _userId;

  void toggleRole() {
    _role = isTraveler ? AppRole.sender : AppRole.traveler;
    notifyListeners();
  }

  void setRole(AppRole newRole) {
    if (_role == newRole) return;
    _role = newRole;
    notifyListeners();
  }

  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
  }

  Future<void> bootstrap() async {
    if (_config.isDemo) return;
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;
    _userId = user.id;
    _phone = user.phone ?? '';
    _isAuthenticated = true;
    // The profile/KYC repository will replace this after it loads the protected
    // server-owned profile state.
    _nidStatus = NidStatus.pending;
    notifyListeners();
  }

  Future<void> requestOtp(String phone) async {
    final normalizedPhone = phone.trim();
    if (normalizedPhone.isEmpty) {
      throw ArgumentError.value(phone, 'phone', 'is required');
    }
    if (_config.isDemo) {
      throw StateError('Demo mode has no SMS service. Use the explicit demo session action.');
    }
    await Supabase.instance.client.auth.signInWithOtp(phone: normalizedPhone);
  }

  Future<void> verifyOtp({required String phone, required String otp}) async {
    final normalizedPhone = phone.trim();
    if (otp.trim().length != 6 || normalizedPhone.isEmpty) {
      throw ArgumentError('A phone number and six-digit OTP are required.');
    }
    if (_config.isDemo) {
      throw StateError('Demo mode does not accept fabricated OTPs.');
    }
    final response = await Supabase.instance.client.auth.verifyOTP(
          phone: normalizedPhone,
          token: otp.trim(),
          type: OtpType.sms,
        );
    final user = response.user;
    if (user == null) {
      throw StateError('OTP verification did not create a session.');
    }
    _phone = normalizedPhone;
    _userId = user.id;
    _isAuthenticated = true;
    // KYC is always server-owned. A signed-in user is not automatically verified.
    _nidStatus = NidStatus.pending;
    notifyListeners();
  }

  /// Explicitly enters a local, non-production demo session. This is not an
  /// authentication mechanism and is unavailable from release builds.
  void startDemoSession(String phone) {
    if (!_config.isDemo) {
      throw StateError('Demo sessions require DATA_MODE=demo.');
    }
    if (phone.trim().isEmpty) {
      throw ArgumentError.value(phone, 'phone', 'is required');
    }
    _phone = phone.trim();
    _isAuthenticated = true;
    _nidStatus = NidStatus.verified;
    notifyListeners();
  }

  Future<void> logout() async {
    if (!_config.isDemo) {
      await Supabase.instance.client.auth.signOut();
    }
    _isAuthenticated = false;
    _phone = '';
    _nidStatus = NidStatus.unverified;
    notifyListeners();
  }

  void applyServerProfile({required String nidStatus}) {
    _nidStatus = switch (nidStatus) {
      'unverified' => NidStatus.unverified,
      'pending' => NidStatus.pending,
      'verified' => NidStatus.verified,
      'suspended' => NidStatus.suspended,
      _ => throw FormatException('Unknown NID status: $nidStatus'),
    };
    notifyListeners();
  }
}
