import 'dart:typed_data';

/// Abstract storage service for uploading images and media.
///
/// Decouples features (profile avatars, parcel photos, handover proofs)
/// from any specific storage provider.
abstract class StorageService {
  /// Upload an image file from a local file path.
  ///
  /// Returns the public secure HTTPS URL of the uploaded image.
  Future<String> uploadImage({
    required String filePath,
    String? folder,
    String? fileName,
  });

  /// Upload raw image bytes (useful for web, camera buffer, or unit tests).
  ///
  /// Returns the public secure HTTPS URL of the uploaded image.
  Future<String> uploadImageBytes({
    required Uint8List bytes,
    required String fileName,
    String? folder,
  });
}
