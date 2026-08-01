import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/config/app_config.dart';
import '../../core/money/money.dart';
import '../../models/deal_model.dart';
import '../../models/package_model.dart';
import '../../models/trip_model.dart';

/// Live data adapter. Financial and OTP mutations use protected database RPCs,
/// never direct table updates from the client.
class SupabaseBackendRepository {
  SupabaseBackendRepository(this._client);

  final SupabaseClient _client;

  Future<Map<String, dynamic>> fetchCurrentProfile() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) throw StateError('No authenticated Supabase user.');
    final row = await _client.from('profiles').select('id, nid_status').eq('id', userId).single();
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
      );
    }).toList(growable: false);
  }

  Future<TripModel> createTrip(TripModel trip) async {
    final row = await _client.from('trips').insert({
        'traveler_id': trip.travelerId,
        'departure_city': trip.departureCity,
        'destination_city': trip.destinationCity,
        'route_path': 'LINESTRING(90.4125 23.8103, 90.4203 24.7471)',
        'travel_time': trip.travelTime.toUtc().toIso8601String(),
        'weight_capacity_kg': trip.weightCapacityKg,
    }).select().single();
    return _tripFromRow(Map<String, dynamic>.from(row));
  }

  Future<PackageModel> createPackage(PackageModel package) async {
    final row = await _client.from('packages').insert({
        'sender_id': package.senderId,
        'pickup_location': 'POINT(${package.pickup.longitude} ${package.pickup.latitude})',
        'dropoff_location': 'POINT(${package.pickup.longitude} ${package.pickup.latitude})',
        'pickup_radius_meters': package.pickupRadiusMeters,
        'item_description': package.itemDescription,
        'item_type': package.itemType,
        'proposed_reward_minor': package.reward.minorUnits,
        'is_premium': package.isPremium,
    }).select().single();
    return _packageFromRow(Map<String, dynamic>.from(row));
  }

  Future<Map<String, dynamic>> createDeal({required String tripId, required String packageId, required Money amount}) async {
    final row = await _client.from('chats_and_deals').insert({
        'trip_id': tripId,
        'package_id': packageId,
        'final_agreed_price_minor': amount.minorUnits,
    }).select().single();
    return Map<String, dynamic>.from(row);
  }

  Future<void> sendMessage({required String dealId, required String senderId, required String text}) async {
    await _client.from('messages').insert({
        'deal_id': dealId,
        'sender_id': senderId,
        'message_text': text,
    });
  }

  Future<Map<String, dynamic>> lockDeal({
    required String dealId,
    required Money amount,
    required String inspectionPhotoUrl,
    required String idempotencyKey,
  }) async => Map<String, dynamic>.from(await _client.rpc('lock_deal_with_inspection', params: {
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
  }) async => Map<String, dynamic>.from(await _client.rpc('wallet_release', params: {
        'p_deal_id': dealId,
        'p_delivery_otp': otp,
        'p_idempotency_key': idempotencyKey,
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

TripModel _tripFromRow(Map<String, dynamic> row) => TripModel(
      id: _string(row, 'id'),
      travelerId: _string(row, 'traveler_id'),
      departureCity: _string(row, 'departure_city'),
      destinationCity: _string(row, 'destination_city'),
      travelTime: DateTime.parse(_string(row, 'travel_time')),
      weightCapacityKg: (row['weight_capacity_kg'] as num).toDouble(),
      status: TripStatusLabel.fromWire(_string(row, 'status')),
      travelerName: 'Verified traveler',
      travelerRating: 0,
    );

PackageModel _packageFromRow(Map<String, dynamic> row) => PackageModel(
      id: _string(row, 'id'),
      senderId: _string(row, 'sender_id'),
      itemDescription: _string(row, 'item_description'),
      reward: Money.fromMinorUnits((row['proposed_reward_minor'] as num).toInt()),
      isPremium: row['is_premium'] as bool? ?? false,
      status: PackageStatusWire.fromWire(_string(row, 'status')),
      pickup: _point(row['pickup_location']),
      pickupRadiusMeters: (row['pickup_radius_meters'] as num).toInt(),
      distanceFromCorridor: 0,
      isNearMiss: false,
      routeInfo: 'Route details available after matching.',
      eta: DateTime.parse(_string(row, 'created_at')),
      itemType: row['item_type'] as String? ?? 'Parcel',
    );

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
  throw const FormatException('pickup_location must be GeoJSON or WKT POINT.');
}
