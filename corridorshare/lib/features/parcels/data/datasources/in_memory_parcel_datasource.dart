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
        id: 'parcel-match-nila',
        senderId: 'sender-nila',
        senderName: 'Nila Akter',
        title: 'Documents',
        fromDistrict: 'Dhaka',
        fromArea: 'Uttara',
        toDistrict: 'Mymensingh',
        toArea: 'Mymensingh Sadar',
        categoryTags: const <String>['documents'],
        weightKg: 1.2,
        size: 'small',
        deadline: DateTime(2026, 10, 24, 18, 0).toIso8601String(),
        offeredPrice: 350.0,
        status: 'open',
        hasProhibitedItemsDeclaration: true,
        note: 'Sealed document envelope.',
        createdAt: now.subtract(const Duration(hours: 2)).toIso8601String(),
      ),
      ParcelDto(
        id: 'parcel-match-imran',
        senderId: 'sender-imran',
        senderName: 'Imran Khan',
        title: 'Books',
        fromDistrict: 'Dhaka',
        fromArea: 'Banani',
        toDistrict: 'Mymensingh',
        toArea: 'Mymensingh Sadar',
        categoryTags: const <String>['books'],
        weightKg: 2.5,
        size: 'medium',
        deadline: DateTime(2026, 10, 24, 20, 0).toIso8601String(),
        offeredPrice: 380.0,
        status: 'open',
        hasProhibitedItemsDeclaration: true,
        note: 'Textbooks packet.',
        createdAt: now.subtract(const Duration(hours: 3)).toIso8601String(),
      ),
      ParcelDto(
        id: 'parcel-match-mitu',
        senderId: 'sender-mitu',
        senderName: 'Mitu Sultana',
        title: 'Clothes',
        fromDistrict: 'Dhaka',
        fromArea: 'Gulshan',
        toDistrict: 'Mymensingh',
        toArea: 'Muktagacha',
        categoryTags: const <String>['clothes'],
        weightKg: 1.5,
        size: 'medium',
        deadline: DateTime(2026, 10, 25, 18, 0).toIso8601String(),
        offeredPrice: 300.0,
        status: 'open',
        hasProhibitedItemsDeclaration: true,
        note: 'Winter jacket.',
        createdAt: now.subtract(const Duration(hours: 4)).toIso8601String(),
      ),
      ParcelDto(
        id: 'parcel-hidden-oil',
        senderId: 'sender-hasan',
        senderName: 'Hasan Ali',
        title: 'Mustard Oil & Ghee Jar',
        fromDistrict: 'Dhaka',
        fromArea: 'Mirpur',
        toDistrict: 'Mymensingh',
        toArea: 'Choto Bazar',
        categoryTags: const <String>['liquids', 'food'],
        weightKg: 2.0,
        size: 'medium',
        deadline: DateTime(2026, 10, 24, 16, 0).toIso8601String(),
        offeredPrice: 420.0,
        status: 'open',
        hasProhibitedItemsDeclaration: true,
        note: 'Glass bottle with homemade oil.',
        createdAt: now.subtract(const Duration(hours: 1)).toIso8601String(),
      ),
      ParcelDto(
        id: 'parcel-hidden-pottery',
        senderId: 'sender-farah',
        senderName: 'Farah Naz',
        title: 'Clay Handicrafts & Crockery',
        fromDistrict: 'Dhaka',
        fromArea: 'Dhanmondi',
        toDistrict: 'Mymensingh',
        toArea: 'Town Hall',
        categoryTags: const <String>['fragile', 'decor'],
        weightKg: 1.8,
        size: 'medium',
        deadline: DateTime(2026, 10, 24, 18, 0).toIso8601String(),
        offeredPrice: 450.0,
        status: 'open',
        hasProhibitedItemsDeclaration: true,
        note: 'Ceramic bowls.',
        createdAt: now.subtract(const Duration(hours: 2)).toIso8601String(),
      ),
      ParcelDto(
        id: 'parcel-carrying-tania',
        senderId: 'sender-tania',
        senderName: 'Tania Rahman',
        title: 'Documents',
        fromDistrict: 'Dhaka',
        fromArea: 'Uttara',
        toDistrict: 'Mymensingh',
        toArea: 'Mymensingh Sadar',
        categoryTags: const <String>['documents'],
        weightKg: 1.2,
        size: 'small',
        deadline: DateTime(2026, 10, 24, 12, 0).toIso8601String(),
        offeredPrice: 300.0,
        status: 'inTransit',
        hasProhibitedItemsDeclaration: true,
        createdAt: now.subtract(const Duration(hours: 5)).toIso8601String(),
      ),
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
      ParcelDto(
        id: 'parcel-sylhet-open',
        senderId: 'sender-sylhet',
        senderName: 'Nabil Hasan',
        title: 'Tea Research Documents',
        fromDistrict: 'Dhaka',
        fromArea: 'Mohakhali',
        toDistrict: 'Sylhet',
        toArea: 'Zindabazar',
        categoryTags: const <String>['documents'],
        weightKg: 0.8,
        size: 'small',
        deadline: DateTime(2026, 10, 26, 18, 0).toIso8601String(),
        offeredPrice: 420.0,
        status: 'open',
        hasProhibitedItemsDeclaration: true,
        note: 'Sealed corporate documents.',
        createdAt: now.subtract(const Duration(hours: 1)).toIso8601String(),
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
      final now = DateTime.now().toIso8601String();
      final created = ParcelDto(
        id: id,
        senderId: 'sender-1',
        senderName: 'Sender',
        title: 'Parcel',
        fromDistrict: 'Dhaka',
        fromArea: 'Uttara',
        toDistrict: 'Mymensingh',
        toArea: 'Mymensingh Sadar',
        categoryTags: const <String>['documents'],
        weightKg: 1.0,
        size: 'small',
        deadline: DateTime.now().add(const Duration(days: 2)).toIso8601String(),
        offeredPrice: 300.0,
        status: status,
        hasProhibitedItemsDeclaration: true,
        createdAt: now,
      );
      _parcels.add(created);
      return created;
    }
    final updated = _parcels[index].copyWith(status: status);
    _parcels[index] = updated;
    return updated;
  }
}
