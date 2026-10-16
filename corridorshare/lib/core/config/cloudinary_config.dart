import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Configuration helper for Cloudinary storage credentials.
///
/// Supports resolution via:
/// 1. `--dart-define=CLOUDINARY_CLOUD_NAME=...` / `--dart-define=CLOUDINARY_UPLOAD_PRESET=...`
/// 2. `.env` file variables (`CLOUDINARY_CLOUD_NAME`, `cloud_name`, `CLOUDINARY_UPLOAD_PRESET`, `upload_preset`)
class CloudinaryConfig {
  const CloudinaryConfig._();

  static const String defaultUploadPreset = 'corridorshare_uploads';

  static String get cloudName {
    const String fromDefine = String.fromEnvironment('CLOUDINARY_CLOUD_NAME');
    if (fromDefine.isNotEmpty) {
      return fromDefine;
    }
    return dotenv.env['CLOUDINARY_CLOUD_NAME'] ??
        dotenv.env['cloud_name'] ??
        '';
  }

  static String get uploadPreset {
    const String fromDefine = String.fromEnvironment('CLOUDINARY_UPLOAD_PRESET');
    if (fromDefine.isNotEmpty) {
      return fromDefine;
    }
    return dotenv.env['CLOUDINARY_UPLOAD_PRESET'] ??
        dotenv.env['upload_preset'] ??
        defaultUploadPreset;
  }

  static bool get isConfigured =>
      cloudName.trim().isNotEmpty && uploadPreset.trim().isNotEmpty;
}
