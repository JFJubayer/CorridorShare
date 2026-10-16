import 'package:corridorshare/core/config/cloudinary_config.dart';
import 'package:corridorshare/core/storage/cloudinary_storage_service.dart';
import 'package:corridorshare/core/storage/in_memory_storage_service.dart';
import 'package:corridorshare/core/storage/storage_service.dart';
import 'package:corridorshare/features/admin/data/datasources/admin_datasource.dart';
import 'package:corridorshare/features/admin/data/repositories/admin_repository_impl.dart';
import 'package:corridorshare/features/admin/domain/repositories/admin_repository.dart';
import 'package:corridorshare/features/auth/data/datasources/auth_datasource.dart';
import 'package:corridorshare/features/auth/data/datasources/fake_auth_datasource.dart';
import 'package:corridorshare/features/auth/data/datasources/firebase_auth_datasource.dart';
import 'package:corridorshare/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:corridorshare/features/auth/domain/repositories/auth_repository.dart';
import 'package:corridorshare/features/chats/data/datasources/chat_datasource.dart';
import 'package:corridorshare/features/chats/data/datasources/in_memory_chat_datasource.dart';
import 'package:corridorshare/features/chats/data/repositories/chat_repository_impl.dart';
import 'package:corridorshare/features/chats/domain/repositories/chat_repository.dart';
import 'package:corridorshare/features/delivery/data/datasources/delivery_datasource.dart';
import 'package:corridorshare/features/delivery/data/datasources/in_memory_delivery_datasource.dart';
import 'package:corridorshare/features/delivery/data/repositories/delivery_repository_impl.dart';
import 'package:corridorshare/features/delivery/domain/repositories/delivery_repository.dart';
import 'package:corridorshare/features/offers/data/datasources/in_memory_offer_datasource.dart';
import 'package:corridorshare/features/offers/data/datasources/offer_datasource.dart';
import 'package:corridorshare/features/offers/data/repositories/offer_repository_impl.dart';
import 'package:corridorshare/features/offers/domain/repositories/offer_repository.dart';
import 'package:corridorshare/features/parcels/data/datasources/in_memory_parcel_datasource.dart';
import 'package:corridorshare/features/parcels/data/datasources/parcel_datasource.dart';
import 'package:corridorshare/features/parcels/data/repositories/parcel_repository_impl.dart';
import 'package:corridorshare/features/parcels/domain/repositories/parcel_repository.dart';
import 'package:corridorshare/features/reviews/data/datasources/in_memory_review_datasource.dart';
import 'package:corridorshare/features/reviews/data/datasources/review_datasource.dart';
import 'package:corridorshare/features/reviews/data/repositories/review_repository_impl.dart';
import 'package:corridorshare/features/reviews/domain/repositories/review_repository.dart';
import 'package:corridorshare/features/trips/data/datasources/in_memory_trip_datasource.dart';
import 'package:corridorshare/features/trips/data/datasources/trip_datasource.dart';
import 'package:corridorshare/features/trips/data/repositories/trip_repository_impl.dart';
import 'package:corridorshare/features/trips/domain/repositories/trip_repository.dart';
import 'package:corridorshare/features/wallet/data/datasources/in_memory_wallet_datasource.dart';
import 'package:corridorshare/features/wallet/data/datasources/wallet_datasource.dart';
import 'package:corridorshare/features/wallet/data/repositories/wallet_repository_impl.dart';
import 'package:corridorshare/features/wallet/domain/repositories/wallet_repository.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// --- Auth ---
final authDataSourceProvider = Provider<AuthDataSource>((ref) {
  if (Firebase.apps.isNotEmpty) {
    return FirebaseAuthDataSource();
  }
  return FakeAuthDataSource();
});

final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => AuthRepositoryImpl(ref.watch(authDataSourceProvider)),
);

// --- Trips ---
final tripDataSourceProvider = Provider<TripDataSource>((ref) {
  return InMemoryTripDataSource();
});

final tripRepositoryProvider = Provider<TripRepository>((ref) {
  final dataSource = ref.watch(tripDataSourceProvider);
  return TripRepositoryImpl(dataSource);
});

// --- Parcels ---
final parcelDataSourceProvider = Provider<ParcelDataSource>((ref) {
  return InMemoryParcelDataSource();
});

final parcelRepositoryProvider = Provider<ParcelRepository>((ref) {
  final dataSource = ref.watch(parcelDataSourceProvider);
  return ParcelRepositoryImpl(dataSource);
});

// --- Offers ---
final offerDataSourceProvider = Provider<OfferDataSource>((ref) {
  return InMemoryOfferDataSource();
});

final offerRepositoryProvider = Provider<OfferRepository>((ref) {
  final dataSource = ref.watch(offerDataSourceProvider);
  return OfferRepositoryImpl(dataSource);
});

// --- Chats ---
final chatDataSourceProvider = Provider<ChatDataSource>((ref) {
  final offerDataSource = ref.watch(offerDataSourceProvider);
  return InMemoryChatDataSource(offerDataSource: offerDataSource);
});

final chatRepositoryProvider = Provider<ChatRepository>((ref) {
  final dataSource = ref.watch(chatDataSourceProvider);
  return ChatRepositoryImpl(dataSource);
});

// --- Delivery ---
final deliveryDataSourceProvider = Provider<DeliveryDataSource>((ref) {
  return InMemoryDeliveryDataSource();
});

final deliveryRepositoryProvider = Provider<DeliveryRepository>((ref) {
  final dataSource = ref.watch(deliveryDataSourceProvider);
  return DeliveryRepositoryImpl(dataSource);
});

// --- Wallet ---
final walletDataSourceProvider = Provider<WalletDataSource>((ref) {
  return InMemoryWalletDataSource();
});

final walletRepositoryProvider = Provider<WalletRepository>((ref) {
  final dataSource = ref.watch(walletDataSourceProvider);
  return WalletRepositoryImpl(dataSource);
});

// --- Reviews ---
final reviewDataSourceProvider = Provider<ReviewDataSource>((ref) {
  return InMemoryReviewDataSource();
});

final reviewRepositoryProvider = Provider<ReviewRepository>((ref) {
  final dataSource = ref.watch(reviewDataSourceProvider);
  return ReviewRepositoryImpl(dataSource);
});

// --- Admin ---
final adminDataSourceProvider = Provider<AdminDataSource>((ref) {
  return InMemoryAdminDataSource(
    tripDataSource: ref.watch(tripDataSourceProvider),
    parcelDataSource: ref.watch(parcelDataSourceProvider),
    deliveryDataSource: ref.watch(deliveryDataSourceProvider),
    walletDataSource: ref.watch(walletDataSourceProvider),
  );
});

final adminRepositoryProvider = Provider<AdminRepository>((ref) {
  return AdminRepositoryImpl(ref.watch(adminDataSourceProvider));
});

// --- Storage ---
final storageServiceProvider = Provider<StorageService>((ref) {
  if (CloudinaryConfig.isConfigured) {
    return CloudinaryStorageService();
  }
  return InMemoryStorageService();
});
