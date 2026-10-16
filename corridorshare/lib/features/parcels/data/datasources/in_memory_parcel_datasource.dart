import 'package:corridorshare/core/errors/failure.dart';
import 'package:corridorshare/features/parcels/data/datasources/parcel_datasource.dart';
import 'package:corridorshare/features/parcels/data/models/parcel_dto.dart';

class InMemoryParcelDataSource implements ParcelDataSource {
  InMemoryParcelDataSource({List<ParcelDto>? initialParcels, bool seed = false})
      : _parcels = initialParcels != null
            ? List<ParcelDto>.from(initialParcels)
            : (seed ? _seedParcels() : <ParcelDto>[]);

  final List<ParcelDto> _parcels;

  static List<ParcelDto> _seedParcels() {
    final now = DateTime.now();
    return <ParcelDto>[
      ParcelDto(
        id: 'parcel-1',
        senderId: 'sender-1',
        senderName: 'Tanvir Ahmed',
        title: 'Original Academic Transcripts',
        fromDistrict: 'Dhaka',
        fromArea: 'Farmgate',
        toDistrict: 'Chattogram',
        toArea: 'Panchlaish',
        categoryTags: const <String>['documents', 'urgent'],
        weightKg: 0.5,
        size: 'small',
        deadline: now.add(const Duration(days: 3)).toIso8601String(),
        offeredPrice: 450.0,
        status: 'open',
        hasProhibitedItemsDeclaration: true,
        note: 'Sealed envelope, urgent delivery for university admission.',
        createdAt: now.subtract(const Duration(hours: 3)).toIso8601String(),
      ),
      ParcelDto(
        id: 'parcel-3',
        senderId: 'sender-1',
        senderName: 'Tanvir Ahmed',
        title: 'Urgent Legal Documents',
        fromDistrict: 'Dhaka',
        fromArea: 'Gulshan',
        toDistrict: 'Sylhet',
        toArea: 'Zindabazar',
        categoryTags: const <String>['documents'],
        weightKg: 0.3,
        size: 'small',
        deadline: now.add(const Duration(days: 2)).toIso8601String(),
        offeredPrice: 500.0,
        status: 'inTransit',
        hasProhibitedItemsDeclaration: true,
        createdAt: now.subtract(const Duration(hours: 5)).toIso8601String(),
      ),
    ];
  }

  @override
  Future<ParcelDto> createParcel(ParcelDto parcel) async {
    _parcels.insert(0, parcel);
    return parcel;
  }

  @override
  Future<List<ParcelDto>> getParcels({
    String? fromDistrict,
    String? toDistrict,
  }) async {
    return _parcels.where((p) {
      if (fromDistrict != null &&
          fromDistrict.isNotEmpty &&
          p.fromDistrict.toLowerCase() != fromDistrict.toLowerCase()) {
        return false;
      }
      if (toDistrict != null &&
          toDistrict.isNotEmpty &&
          p.toDistrict.toLowerCase() != toDistrict.toLowerCase()) {
        return false;
      }
      return true;
    }).toList();
  }

  @override
  Future<List<ParcelDto>> getMyParcels(String senderId) async {
    return _parcels.where((p) => p.senderId == senderId).toList();
  }

  @override
  Future<ParcelDto> getParcelById(String id) async {
    final index = _parcels.indexWhere((p) => p.id == id);
    if (index == -1) {
      throw const NotFoundFailure('Parcel not found');
    }
    return _parcels[index];
  }

  @override
  Future<ParcelDto> updateParcelStatus({
    required String id,
    required String status,
  }) async {
    final index = _parcels.indexWhere((p) => p.id == id);
    if (index == -1) {
      throw const NotFoundFailure('Parcel not found');
    }
    final updated = _parcels[index].copyWith(status: status);
    _parcels[index] = updated;
    return updated;
  }
}
