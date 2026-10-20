import 'package:corridorshare/core/errors/failure.dart';
import 'package:corridorshare/core/utils/result.dart';
import 'package:corridorshare/features/offers/data/datasources/offer_datasource.dart';
import 'package:corridorshare/features/offers/data/models/offer_dto.dart';
import 'package:corridorshare/features/offers/domain/entities/offer.dart';
import 'package:corridorshare/features/offers/domain/repositories/offer_repository.dart';

class OfferRepositoryImpl implements OfferRepository {
  const OfferRepositoryImpl(this._dataSource);

  final OfferDataSource _dataSource;

  @override
  Future<Result<Offer>> createOffer(Offer offer) async {
    try {
      final dto = OfferDto.fromDomain(offer);
      final created = await _dataSource.createOffer(dto);
      return Ok<Offer>(created.toDomain());
    } on Failure catch (f) {
      return Err<Offer>(f);
    } catch (e) {
      return Err<Offer>(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Result<Offer>> counterOffer({
    required String offerId,
    required double newPrice,
    required String counterByUserId,
  }) async {
    try {
      final updated = await _dataSource.counterOffer(
        offerId: offerId,
        newPrice: newPrice,
        counterByUserId: counterByUserId,
      );
      return Ok<Offer>(updated.toDomain());
    } on Failure catch (f) {
      return Err<Offer>(f);
    } catch (e) {
      return Err<Offer>(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Result<Offer>> acceptOffer(String offerId) async {
    try {
      final updated = await _dataSource.acceptOffer(offerId);
      return Ok<Offer>(updated.toDomain());
    } on Failure catch (f) {
      return Err<Offer>(f);
    } catch (e) {
      return Err<Offer>(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Result<Offer>> rejectOffer(String offerId) async {
    try {
      final updated = await _dataSource.rejectOffer(offerId);
      return Ok<Offer>(updated.toDomain());
    } on Failure catch (f) {
      return Err<Offer>(f);
    } catch (e) {
      return Err<Offer>(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Result<Offer>> getOfferById(String offerId) async {
    try {
      final dto = await _dataSource.getOfferById(offerId);
      return Ok<Offer>(dto.toDomain());
    } on Failure catch (f) {
      return Err<Offer>(f);
    } catch (e) {
      return Err<Offer>(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Result<List<Offer>>> getOffersForUser(String userId) async {
    try {
      final dtos = await _dataSource.getOffersForUser(userId);
      return Ok<List<Offer>>(
        dtos.map((dto) => dto.toDomain()).toList(),
      );
    } on Failure catch (f) {
      return Err<List<Offer>>(f);
    } catch (e) {
      return Err<List<Offer>>(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Result<List<Offer>>> getOffersForParcel(String parcelId) async {
    try {
      final dtos = await _dataSource.getOffersForParcel(parcelId);
      return Ok<List<Offer>>(
        dtos.map((dto) => dto.toDomain()).toList(),
      );
    } on Failure catch (f) {
      return Err<List<Offer>>(f);
    } catch (e) {
      return Err<List<Offer>>(UnknownFailure(e.toString()));
    }
  }
}
