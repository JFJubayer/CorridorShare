import 'dart:typed_data';

import 'package:corridorshare/core/config/cloudinary_config.dart';
import 'package:corridorshare/core/di/injection.dart';
import 'package:corridorshare/core/storage/cloudinary_storage_service.dart';
import 'package:corridorshare/core/storage/in_memory_storage_service.dart';
import 'package:corridorshare/core/storage/storage_service.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('InMemoryStorageService', () {
    late InMemoryStorageService storage;

    setUp(() {
      storage = InMemoryStorageService();
    });

    test('uploadImage generates URL and caches path', () async {
      final String url = await storage.uploadImage(
        filePath: '/tmp/test_parcel.jpg',
        folder: 'parcels',
      );

      expect(url, 'https://res.cloudinary.com/demo/image/upload/parcels/test_parcel.jpg');
      expect(storage.uploadedFiles[url], '/tmp/test_parcel.jpg');
    });

    test('uploadImageBytes generates URL and caches byte payload', () async {
      final Uint8List bytes = Uint8List.fromList(<int>[1, 2, 3, 4]);
      final String url = await storage.uploadImageBytes(
        bytes: bytes,
        fileName: 'proof.png',
        folder: 'handover_proofs',
      );

      expect(
        url,
        'https://res.cloudinary.com/demo/image/upload/handover_proofs/proof.png',
      );
      expect(storage.uploadedFiles[url], bytes);
    });
  });

  group('CloudinaryConfig & DI Provider', () {
    test('CloudinaryConfig parses dotenv values', () {
      dotenv.testLoad(
        fileInput: 'CLOUDINARY_CLOUD_NAME=my_cloud\nCLOUDINARY_UPLOAD_PRESET=my_preset',
      );

      expect(CloudinaryConfig.cloudName, 'my_cloud');
      expect(CloudinaryConfig.uploadPreset, 'my_preset');
      expect(CloudinaryConfig.isConfigured, isTrue);

      final ProviderContainer container = ProviderContainer();
      final StorageService service = container.read(storageServiceProvider);
      expect(service, isA<CloudinaryStorageService>());
      container.dispose();
    });

    test('Falls back to InMemoryStorageService when credentials missing', () {
      dotenv.testLoad(fileInput: '');

      final ProviderContainer container = ProviderContainer();
      final StorageService service = container.read(storageServiceProvider);
      expect(service, isA<InMemoryStorageService>());
      container.dispose();
    });
  });
}
