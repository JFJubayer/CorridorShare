import 'dart:typed_data';

import 'package:corridorshare/core/storage/storage_service.dart';

/// In-memory implementation of [StorageService] for testing and offline development.
class InMemoryStorageService implements StorageService {
  InMemoryStorageService({this.baseUrl = 'https://res.cloudinary.com/demo/image/upload'});

  final String baseUrl;
  final Map<String, dynamic> uploadedFiles = <String, dynamic>{};

  @override
  Future<String> uploadImage({
    required String filePath,
    String? folder,
    String? fileName,
  }) async {
    final String resolvedName = fileName ?? filePath.split('/').last;
    final String path = folder != null ? '$folder/$resolvedName' : resolvedName;
    final String url = '$baseUrl/$path';
    uploadedFiles[url] = filePath;
    return url;
  }

  @override
  Future<String> uploadImageBytes({
    required Uint8List bytes,
    required String fileName,
    String? folder,
  }) async {
    final String path = folder != null ? '$folder/$fileName' : fileName;
    final String url = '$baseUrl/$path';
    uploadedFiles[url] = bytes;
    return url;
  }
}
