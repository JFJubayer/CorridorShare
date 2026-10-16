import 'package:corridorshare/core/constants/bangladesh_districts.dart';
import 'package:corridorshare/core/errors/failure.dart';
import 'package:corridorshare/core/utils/result.dart';
import 'package:corridorshare/features/parcels/domain/entities/parcel.dart';
import 'package:corridorshare/features/parcels/domain/repositories/parcel_repository.dart';

class CreateParcel {
  const CreateParcel(this._repository);

  final ParcelRepository _repository;

  Future<Result<Parcel>> call(Parcel parcel) async {
    if (parcel.senderId.trim().isEmpty) {
      return const Err<Parcel>(
        ValidationFailure('Sender ID is required'),
      );
    }
    if (parcel.title.trim().isEmpty) {
      return const Err<Parcel>(
        ValidationFailure('Parcel description or item name is required'),
      );
    }
    if (!BangladeshDistricts.isValid(parcel.fromDistrict)) {
      return Err<Parcel>(
        ValidationFailure('Invalid origin district: ${parcel.fromDistrict}'),
      );
    }
    if (!BangladeshDistricts.isValid(parcel.toDistrict)) {
      return Err<Parcel>(
        ValidationFailure('Invalid destination district: ${parcel.toDistrict}'),
      );
    }
    if (parcel.fromDistrict.toLowerCase() == parcel.toDistrict.toLowerCase()) {
      return const Err<Parcel>(
        ValidationFailure('Origin and destination districts cannot be the same'),
      );
    }
    if (parcel.weightKg <= 0) {
      return const Err<Parcel>(
        ValidationFailure('Parcel weight must be greater than 0 kg'),
      );
    }
    if (parcel.weightKg > 50) {
      return const Err<Parcel>(
        ValidationFailure('Parcel weight cannot exceed 50 kg'),
      );
    }
    if (parcel.offeredPrice <= 0) {
      return const Err<Parcel>(
        ValidationFailure('Offered price must be greater than 0 BDT'),
      );
    }
    if (!parcel.hasProhibitedItemsDeclaration) {
      return const Err<Parcel>(
        ValidationFailure(
          'You must declare that this parcel does not contain illegal or prohibited items',
        ),
      );
    }

    final now = DateTime.now();
    final todayMidnight = DateTime(now.year, now.month, now.day);
    final deadlineMidnight = DateTime(
      parcel.deadline.year,
      parcel.deadline.month,
      parcel.deadline.day,
    );
    if (deadlineMidnight.isBefore(todayMidnight)) {
      return const Err<Parcel>(
        ValidationFailure('Delivery deadline cannot be in the past'),
      );
    }

    return _repository.createParcel(parcel);
  }
}
