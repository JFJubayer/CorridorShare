import 'package:corridorshare/core/errors/failure.dart';
import 'package:corridorshare/features/delivery/data/datasources/delivery_datasource.dart';
import 'package:corridorshare/features/delivery/data/models/delivery_dto.dart';

class InMemoryDeliveryDataSource implements DeliveryDataSource {
  InMemoryDeliveryDataSource({List<DeliveryDto>? initialDeliveries, bool seed = false})
      : _deliveries = initialDeliveries != null
            ? List<DeliveryDto>.from(initialDeliveries)
            : (seed ? _seedDeliveries() : <DeliveryDto>[]);

  final List<DeliveryDto> _deliveries;

  static List<DeliveryDto> _seedDeliveries() {
    final now = DateTime.now().toIso8601String();
    return <DeliveryDto>[
      DeliveryDto(
        id: 'delivery-1',
        parcelId: 'parcel-1',
        tripId: 'trip-1',
        senderId: 'sender-1',
        senderName: 'Tanvir Ahmed',
        travellerId: 'traveller-1',
        travellerName: 'Rafiqul Islam',
        parcelTitle: 'Original Academic Transcripts',
        fromDistrict: 'Dhaka',
        toDistrict: 'Chattogram',
        agreedPrice: 450.0,
        status: 'matched',
        verificationPin: '4192',
        createdAt: now,
        updatedAt: now,
      ),
      DeliveryDto(
        id: 'delivery-2',
        parcelId: 'parcel-3',
        tripId: 'trip-1',
        senderId: 'sender-1',
        senderName: 'Tanvir Ahmed',
        travellerId: 'traveller-1',
        travellerName: 'Rafiqul Islam',
        parcelTitle: 'Urgent Legal Documents',
        fromDistrict: 'Dhaka',
        toDistrict: 'Sylhet',
        agreedPrice: 500.0,
        status: 'inTransit',
        verificationPin: '4192',
        createdAt: now,
        updatedAt: now,
      ),
    ];
  }

  @override
  Future<DeliveryDto> getDeliveryById(String id) async {
    final index = _deliveries.indexWhere((d) => d.id == id);
    if (index == -1) {
      throw const NotFoundFailure('Delivery record not found');
    }
    return _deliveries[index];
  }

  @override
  Future<DeliveryDto> getDeliveryByParcelId(String parcelId) async {
    final index = _deliveries.indexWhere((d) => d.parcelId == parcelId);
    if (index == -1) {
      throw const NotFoundFailure('Delivery record for parcel not found');
    }
    return _deliveries[index];
  }

  @override
  Future<List<DeliveryDto>> getDeliveriesForUser(String userId) async {
    return _deliveries
        .where((d) => d.senderId == userId || d.travellerId == userId)
        .toList();
  }

  @override
  Future<List<DeliveryDto>> getAllDeliveries() async {
    return List.unmodifiable(_deliveries);
  }

  @override
  Future<DeliveryDto> createDelivery(DeliveryDto delivery) async {
    _deliveries.insert(0, delivery);
    return delivery;
  }

  @override
  Future<DeliveryDto> confirmPickup({
    required String deliveryId,
    required String photoUrl,
    String? notes,
  }) async {
    final index = _deliveries.indexWhere((d) => d.id == deliveryId);
    if (index == -1) {
      throw const NotFoundFailure('Delivery record not found');
    }
    final now = DateTime.now().toIso8601String();
    final updated = _deliveries[index].copyWith(
      status: 'inTransit',
      pickupPhotoUrl: photoUrl,
      pickupNotes: notes,
      pickedUpAt: now,
      updatedAt: now,
    );
    _deliveries[index] = updated;
    return updated;
  }

  @override
  Future<DeliveryDto> verifyDelivery({
    required String deliveryId,
    required String inputPin,
    String? photoUrl,
  }) async {
    final index = _deliveries.indexWhere((d) => d.id == deliveryId);
    if (index == -1) {
      throw const NotFoundFailure('Delivery record not found');
    }
    final now = DateTime.now().toIso8601String();
    final updated = _deliveries[index].copyWith(
      status: 'delivered',
      deliveredAt: now,
      updatedAt: now,
    );
    _deliveries[index] = updated;
    return updated;
  }

  @override
  Future<DeliveryDto> reportDispute({
    required String deliveryId,
    required String reason,
    required String reporterId,
  }) async {
    final index = _deliveries.indexWhere((d) => d.id == deliveryId);
    if (index == -1) {
      throw const NotFoundFailure('Delivery record not found');
    }
    final now = DateTime.now().toIso8601String();
    final updated = _deliveries[index].copyWith(
      status: 'disputed',
      isDisputed: true,
      disputeReason: reason,
      disputedBy: reporterId,
      disputedAt: now,
      updatedAt: now,
    );
    _deliveries[index] = updated;
    return updated;
  }
}
