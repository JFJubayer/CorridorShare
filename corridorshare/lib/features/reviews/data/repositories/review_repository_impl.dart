import 'package:corridorshare/core/errors/failure.dart';
import 'package:corridorshare/core/utils/result.dart';
import 'package:corridorshare/features/reviews/data/datasources/review_datasource.dart';
import 'package:corridorshare/features/reviews/data/models/review_dto.dart';
import 'package:corridorshare/features/reviews/domain/entities/review.dart';
import 'package:corridorshare/features/reviews/domain/repositories/review_repository.dart';

class ReviewRepositoryImpl implements ReviewRepository {
  const ReviewRepositoryImpl(this._dataSource);

  final ReviewDataSource _dataSource;

  @override
  Future<Result<Review>> createReview(Review review) async {
    try {
      final dto = ReviewDto.fromDomain(review);
      final created = await _dataSource.createReview(dto);
      return Ok<Review>(created.toDomain());
    } on Failure catch (f) {
      return Err<Review>(f);
    } catch (e) {
      return Err<Review>(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Result<List<Review>>> getReviewsForUser(String userId) async {
    try {
      final dtos = await _dataSource.getReviewsForUser(userId);
      return Ok<List<Review>>(dtos.map((d) => d.toDomain()).toList());
    } on Failure catch (f) {
      return Err<List<Review>>(f);
    } catch (e) {
      return Err<List<Review>>(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Result<double>> getAverageRatingForUser(String userId) async {
    try {
      final avg = await _dataSource.getAverageRatingForUser(userId);
      return Ok<double>(avg);
    } on Failure catch (f) {
      return Err<double>(f);
    } catch (e) {
      return Err<double>(ServerFailure(e.toString()));
    }
  }
}
