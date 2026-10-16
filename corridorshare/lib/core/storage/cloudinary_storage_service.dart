import 'dart:typed_data';

import 'package:cloudinary_public/cloudinary_public.dart';
import 'package:corridorshare/core/config/cloudinary_config.dart';
import 'package:corridorshare/core/storage/storage_service.dart';

/// Cloudinary implementation of [StorageService] utilizing unsigned upload presets.
class CloudinaryStorageService implements StorageService {
  CloudinaryStorageService({
    CloudinaryPublic? client,
    String? cloudName,
    String? uploadPreset,
  }) : _client = client ??
            CloudinaryPublic(
              cloudName ?? CloudinaryConfig.cloudName,
              uploadPreset ?? CloudinaryConfig.uploadPreset,
              cache: false,
            );

  final CloudinaryPublic _client;

  @override
  Future<String> uploadImage({
    required String filePath,
    String? folder,
    String? fileName,
  }) async {
    try {
      final CloudinaryResponse response = await _client.uploadFile(
        CloudinaryFile.fromFile(
          filePath,
          folder: folder,
          resourceType: CloudinaryResourceType.Image,
        ),
      );
      return response.secureUrl;
    } catch (e) {
      throw Exception('Failed to upload image to Cloudinary: $e');
    }
  }

  @override
  Future<String> uploadImageBytes({
    required Uint8List bytes,
    required String fileName,
    String? folder,
  }) async {
    try {
      final CloudinaryResponse response = await _client.uploadFile(
        CloudinaryFile.fromBytesData(
          bytes,
          identifier: fileName,
          folder: folder,
          resourceType: CloudinaryResourceType.Image,
        ),
      );
      return response.secureUrl;
    } catch (e) {
      throw Exception('Failed to upload image bytes to Cloudinary: $e');
    }
  }
}
