import 'dart:typed_data';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/config/app_config.dart';
import '../../core/geo/bangladesh_geo.dart';
import '../../core/money/money.dart';
import '../../models/deal_model.dart';
import '../../models/package_model.dart';
import '../../models/trip_model.dart';

/// Live data adapter. Financial and OTP mutations use protected database RPCs,
/// never direct table updates from the client.
class SupabaseBackendRepository {
  SupabaseBackendRepository(this._client);

  final SupabaseClient _client;

  static const nidPhotosBucket = 'nid-photos';
  static const parcelInspectionsBucket = 'parcel-inspections';

  Future<Map<String, dynamic>> fetchCurrentProfile() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) throw StateError('No authenticated Supabase user.');
    final row = await _client
        .from('profiles')
        .select('id, phone_number, full_name, role, nid_status, nid_photo_url')
        .eq('id', userId)
        .single();
    return Map<String, dynamic>.from(row);
  }

  Future<Map<String, dynamic>> fetchCurrentWallet() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) throw StateError('No authenticated Supabase user.');
    final row = await _client
        .from('wallet_accounts')
        .select('available_balance_minor, held_balance_minor')
        .eq('profile_id', userId)
        .single();
    return Map<String, dynamic>.from(row);
  }

  Future<List<TripModel>> fetchTrips() async {
    final rows = await _client.from('trips').select().order('travel_time');
    return (rows as List<dynamic>)
        .map((row) => _tripFromRow(Map<String, dynamic>.from(row as Map)))
        .toList(growable: false);
  }

  Future<List<PackageModel>> fetchPackages() async {
    final rows = await _client.from('packages').select().order('created_at');
    return (rows as List<dynamic>)
        .map((row) => _packageFromRow(Map<String, dynamic>.from(row as Map)))
        .toList(growable: false);
  }

  Future<List<DealModel>> fetchDeals() async {
    final rows = await _client
        .from('chats_and_deals')
        .select('*, trips!inner(traveler_id), packages!inner(sender_id, item_description)')
        .order('created_at');
    return (rows as List<dynamic>)
        .where((row) => (row as Map)['final_agreed_price_minor'] != null)
        .map((row) => _dealFromRow(Map<String, dynamic>.from(row as Map)))
        .toList(growable: false);
  }

  Future<List<ChatMessageModel>> fetchMessages(String dealId) async {
    final rows = await _client.from('messages').select().eq('deal_id', dealId).order('created_at');
    return (rows as List<dynamic>).map((row) {
      final data = Map<String, dynamic>.from(row as Map);
      return ChatMessageModel(
        id: _string(data, 'id'),
        dealId: _string(data, 'deal_id'),
        senderId: _string(data, 'sender_id'),
        senderName: 'Participant',
        text: _string(data, 'message_text'),
        createdAt: DateTime.parse(_string(data, 'created_at')),
        imageUrl: data['image_verification_url'] as String?,
      );
    }).toList(growable: false);
  }

  Future<TripModel> createTrip(TripModel trip) async {
    if (trip.routePoints.length < 2) {
      throw ArgumentError('createTrip requires real route geometry from user input (2+ points).');
    }
    final row = await _client.from('trips').insert({
      'traveler_id': trip.travelerId,
      'departure_city': trip.departureCity,
      'destination_city': trip.destinationCity,
      'route_path': BangladeshGeo.lineStringWkt(trip.routePoints),
      'travel_time': trip.travelTime.toUtc().toIso8601String(),
      'weight_capacity_kg': trip.weightCapacityKg,
    }).select().single();
    return _tripFromRow(Map<String, dynamic>.from(row));
  }

  Future<PackageModel> createPackage(PackageModel package) async {
    if (package.pickup.isSameAs(package.dropoff)) {
      throw ArgumentError('dropoff_location must differ from pickup_location.');
    }
    final payload = <String, dynamic>{
      'sender_id': package.senderId,
      'pickup_location': BangladeshGeo.pointWkt(package.pickup),
      'dropoff_location': BangladeshGeo.pointWkt(package.dropoff),
      'pickup_radius_meters': package.pickupRadiusMeters,
      'item_description': package.itemDescription,
      'item_type': package.itemType,
      'proposed_reward_minor': package.reward.minorUnits,
      'is_premium': package.isPremium,
      if (package.weightKg != null) 'weight_kg': package.weightKg,
    };
    final phone = package.recipientPhone?.trim();
    if (phone == null || phone.isEmpty) {
      throw ArgumentError('recipient_phone is required when creating a package.');
    }
    payload['recipient_phone'] = phone;
    final recipientName = package.recipientName?.trim();
    if (recipientName != null && recipientName.isNotEmpty) {
      payload['recipient_name'] = recipientName;
    }
    final row = await _client.from('packages').insert(payload).select().single();
    return _packageFromRow(Map<String, dynamic>.from(row));
  }

  Future<Map<String, dynamic>> createDeal({
    required String tripId,
    required String packageId,
    required Money amount,
  }) async {
    final row = await _client.from('chats_and_deals').insert({
      'trip_id': tripId,
      'package_id': packageId,
      'final_agreed_price_minor': amount.minorUnits,
    }).select().single();
    return Map<String, dynamic>.from(row);
  }

  Future<void> sendMessage({
    required String dealId,
    required String senderId,
    required String text,
  }) async {
    await _client.from('messages').insert({
      'deal_id': dealId,
      'sender_id': senderId,
      'message_text': text,
    });
  }

  /// Live matching uses the PostGIS RPC — never a client-side corridor filter.
  Future<List<PackageModel>> matchPackagesWithinCorridor({
    required String tripId,
    double bufferDistanceMeters = 3000,
  }) async {
    final rows = await _client.rpc(
      'match_packages_within_corridor',
      params: {
        'traveler_trip_id': tripId,
        'buffer_distance_meters': bufferDistanceMeters,
      },
    );
    return (rows as List<dynamic>).map((row) {
      final data = Map<String, dynamic>.from(row as Map);
      final pickup = GeoPoint(
        (data['pickup_lat'] as num).toDouble(),
        (data['pickup_lng'] as num).toDouble(),
      );
      // Friends-beta match RPC (202608120002) returns dropoff_lat/lng + weight_kg.
      // Prefer real coords; only synthesize a distinct marker if the RPC row is
      // missing dropoff (older backends).
      final dropLat = (data['dropoff_lat'] as num?)?.toDouble();
      final dropLng = (data['dropoff_lng'] as num?)?.toDouble();
      final dropoff = (dropLat != null && dropLng != null)
          ? GeoPoint(dropLat, dropLng)
          : GeoPoint(pickup.latitude + 0.02, pickup.longitude + 0.02);
      if (dropoff.isSameAs(pickup)) {
        throw FormatException(
          'match_packages_within_corridor returned identical pickup/dropoff for package ${data['package_id']}',
        );
      }
      return PackageModel(
        id: _string(data, 'package_id'),
        senderId: _string(data, 'sender_id'),
        itemDescription: _string(data, 'item_description'),
        reward: Money.fromMinorUnits((data['proposed_reward_minor'] as num).toInt()),
        isPremium: data['is_premium'] as bool? ?? false,
        status: PackageStatus.pending,
        pickup: pickup,
        dropoff: dropoff,
        pickupRadiusMeters: (data['pickup_radius_meters'] as num).toInt(),
        distanceFromCorridor: (data['distance_from_corridor'] as num).toDouble(),
        isNearMiss: data['is_near_miss'] as bool? ?? false,
        routeInfo: 'Matched via corridor RPC',
        eta: DateTime.now().toUtc().add(const Duration(hours: 6)),
        itemType: data['item_type'] as String? ?? 'Parcel',
        weightKg: (data['weight_kg'] as num?)?.toDouble(),
      );
    }).toList(growable: false);
  }

  Future<Map<String, dynamic>> lockDeal({
    required String dealId,
    required Money amount,
    required String inspectionPhotoUrl,
    required String idempotencyKey,
  }) async =>
      Map<String, dynamic>.from(await _client.rpc('lock_deal_with_inspection', params: {
        'p_deal_id': dealId,
        'p_amount_minor': amount.minorUnits,
        'p_inspection_photo_url': inspectionPhotoUrl,
        'p_idempotency_key': idempotencyKey,
      }));

  Future<String> issueDeliveryOtp(String dealId) async =>
      await _client.rpc('issue_delivery_otp', params: {'p_deal_id': dealId}) as String;

  Future<Map<String, dynamic>> releaseWallet({
    required String dealId,
    required String otp,
    required String idempotencyKey,
  }) async =>
      Map<String, dynamic>.from(await _client.rpc('wallet_release', params: {
        'p_deal_id': dealId,
        'p_delivery_otp': otp,
        'p_idempotency_key': idempotencyKey,
      }));

  Future<Map<String, dynamic>> refundWallet({
    required String dealId,
    required String idempotencyKey,
  }) async =>
      Map<String, dynamic>.from(await _client.rpc('wallet_refund', params: {
        'p_deal_id': dealId,
        'p_idempotency_key': idempotencyKey,
      }));

  Future<List<Map<String, dynamic>>> fetchProfilesForAdmin() async {
    final rows = await _client
        .from('profiles')
        .select('id, phone_number, full_name, role, nid_status, nid_photo_url, created_at')
        .order('created_at', ascending: false);
    return (rows as List<dynamic>)
        .map((row) => Map<String, dynamic>.from(row as Map))
        .toList(growable: false);
  }

  Future<Map<String, dynamic>> adminSetNidStatus({
    required String profileId,
    required String status,
  }) async =>
      Map<String, dynamic>.from(await _client.rpc('admin_set_nid_status', params: {
        'p_profile_id': profileId,
        'p_status': status,
      }));

  /// Uploads to private Storage buckets created by the MVP BD contract migration.
  /// NID paths: `{auth.uid()}/{fileName}`.
  /// Inspection paths: `{auth.uid()}/{dealId}/{fileName}` when [dealId] is set.
  Future<String> uploadEvidenceImage({
    required String folder,
    required String fileName,
    required Uint8List bytes,
    String? dealId,
    String contentType = 'image/jpeg',
  }) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) throw StateError('No authenticated Supabase user.');
    final bucket = switch (folder) {
      'nid' => nidPhotosBucket,
      'inspection' => parcelInspectionsBucket,
      _ => throw ArgumentError.value(folder, 'folder', 'must be nid or inspection'),
    };
    final path = folder == 'inspection' && dealId != null && dealId.trim().isNotEmpty
        ? '$userId/${dealId.trim()}/$fileName'
        : '$userId/$fileName';
    await _client.storage.from(bucket).uploadBinary(
          path,
          bytes,
          fileOptions: FileOptions(contentType: contentType, upsert: true),
        );
    // Buckets are private; persist a time-limited signed URL for RPC/profile use.
    final signed = await _client.storage.from(bucket).createSignedUrl(path, 60 * 60 * 24 * 7);
    return signed;
  }

  Future<void> updateOwnNidPhoto(String photoUrl) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) throw StateError('No authenticated Supabase user.');
    await _client.from('profiles').update({'nid_photo_url': photoUrl, 'nid_status': 'pending'}).eq('id', userId);
  }

  /// Staging-only funding. Not a payment provider — members cannot call this successfully.
  Future<Map<String, dynamic>> adminCreditWallet({
    required String profileId,
    required int amountMinor,
    required String idempotencyKey,
    String? note,
  }) async =>
      Map<String, dynamic>.from(await _client.rpc('admin_credit_wallet', params: {
        'p_profile_id': profileId,
        'p_amount_minor': amountMinor,
        'p_idempotency_key': idempotencyKey,
        if (note != null && note.trim().isNotEmpty) 'p_note': note.trim(),
      }));
}

class BackendRepositoryFactory {
  static SupabaseBackendRepository? create(AppConfig config) => config.isDemo
      ? null
      : SupabaseBackendRepository(Supabase.instance.client);
}

String _string(Map<String, dynamic> map, String key) {
  final value = map[key];
  if (value is! String || value.isEmpty) throw FormatException('Missing $key');
  return value;
}

TripModel _tripFromRow(Map<String, dynamic> row) {
  final parsed = TripModel.fromJson({
    ...row,
    'traveler_name': row['traveler_name'] ?? 'Verified traveler',
    'traveler_rating': row['traveler_rating'] ?? 0,
    'status': row['status'] ?? 'scheduled',
  });
  return parsed;
}

PackageModel _packageFromRow(Map<String, dynamic> row) {
  final pickup = _point(row['pickup_location']);
  final dropoff = _point(row['dropoff_location']);
  return PackageModel(
    id: _string(row, 'id'),
    senderId: _string(row, 'sender_id'),
    itemDescription: _string(row, 'item_description'),
    reward: Money.fromMinorUnits((row['proposed_reward_minor'] as num).toInt()),
    isPremium: row['is_premium'] as bool? ?? false,
    status: PackageStatusWire.fromWire(_string(row, 'status')),
    pickup: pickup,
    dropoff: dropoff,
    pickupRadiusMeters: (row['pickup_radius_meters'] as num).toInt(),
    distanceFromCorridor: 0,
    isNearMiss: false,
    routeInfo: 'Route details available after matching.',
    eta: DateTime.parse(_string(row, 'created_at')),
    itemType: row['item_type'] as String? ?? 'Parcel',
    recipientPhone: (row['recipient_phone'] as String?)?.trim(),
    recipientName: (row['recipient_name'] as String?)?.trim(),
    weightKg: (row['weight_kg'] as num?)?.toDouble(),
  );
}

DealModel _dealFromRow(Map<String, dynamic> row) => DealModel(
      id: _string(row, 'id'),
      tripId: _string(row, 'trip_id'),
      packageId: _string(row, 'package_id'),
      travelerId: _string(Map<String, dynamic>.from(row['trips'] as Map), 'traveler_id'),
      senderId: _string(Map<String, dynamic>.from(row['packages'] as Map), 'sender_id'),
      agreedPrice: Money.fromMinorUnits((row['final_agreed_price_minor'] as num).toInt()),
      dealLocked: row['deal_locked'] as bool,
      openBoxVerified: row['open_box_verified'] as bool,
      status: DealStatusWire.fromWire(_string(row, 'status')),
      packageItem: _string(Map<String, dynamic>.from(row['packages'] as Map), 'item_description'),
      routeInfo: 'Corridor route',
    );

GeoPoint _point(dynamic value) {
  if (value is Map && value['coordinates'] is List) {
    final values = value['coordinates'] as List<dynamic>;
    return GeoPoint((values[1] as num).toDouble(), (values[0] as num).toDouble());
  }
  if (value is String) {
    final match = RegExp(r'POINT\(([-.0-9]+) ([-.0-9]+)\)').firstMatch(value);
    if (match != null) {
      return GeoPoint(double.parse(match.group(2)!), double.parse(match.group(1)!));
    }
  }
  throw const FormatException('location must be GeoJSON or WKT POINT.');
}
