import 'package:flutter/foundation.dart';

/// The app must be started explicitly in either its live or demo data mode.
///
/// `supabase` is deliberately the default so a missing environment value can
/// never silently turn a production build into a local-only application.
enum AppDataMode { supabase, demo }

class AppConfig {
  const AppConfig({
    required this.dataMode,
    this.supabaseUrl,
    this.supabaseAnonKey,
  });

  factory AppConfig.fromEnvironment() {
    const mode = String.fromEnvironment('DATA_MODE', defaultValue: 'supabase');
    const url = String.fromEnvironment('SUPABASE_URL');
    const anonKey = String.fromEnvironment('SUPABASE_ANON_KEY');

    if (mode != 'supabase' && mode != 'demo') {
      throw StateError('DATA_MODE must be either "supabase" or "demo".');
    }
    if (mode == 'demo' && kReleaseMode) {
      throw StateError('Demo mode is not available in release builds.');
    }

    return AppConfig(
      dataMode: mode == 'demo' ? AppDataMode.demo : AppDataMode.supabase,
      supabaseUrl: url.isEmpty ? null : url,
      supabaseAnonKey: anonKey.isEmpty ? null : anonKey,
    );
  }

  final AppDataMode dataMode;
  final String? supabaseUrl;
  final String? supabaseAnonKey;

  bool get isDemo => dataMode == AppDataMode.demo;

  bool get hasSupabaseCredentials =>
      supabaseUrl != null && supabaseAnonKey != null;

  void validateForStartup() {
    if (dataMode == AppDataMode.supabase && !hasSupabaseCredentials) {
      throw StateError(
        'SUPABASE_URL and SUPABASE_ANON_KEY are required when DATA_MODE=supabase.',
      );
    }
  }
}
