import 'package:corridorshare/core/errors/failure.dart';
import 'package:corridorshare/core/utils/result.dart';
import 'package:corridorshare/features/reviews/domain/entities/review.dart';
import 'package:corridorshare/features/reviews/domain/repositories/review_repository.dart';

class CreateReview {
  const CreateReview(this._repository);

  final ReviewRepository _repository;

  Future<Result<Review>> call(Review review) async {
    if (review.rating < 1 || review.rating > 5) {
      return const Err<Review>(
        ValidationFailure('Rating must be between 1 and 5 stars'),
      );
    }
    if (review.comment.trim().isEmpty) {
      return const Err<Review>(
        ValidationFailure('Review feedback comment cannot be empty'),
      );
    }
    if (review.reviewerId == review.targetUserId) {
      return const Err<Review>(
        ValidationFailure('Users cannot review themselves'),
      );
    }
    return _repository.createReview(review);
  }
}

class GetReviewsForUser {
  const GetReviewsForUser(this._repository);

  final ReviewRepository _repository;

  Future<Result<List<Review>>> call(String userId) {
    return _repository.getReviewsForUser(userId);
  }
}

class GetAverageRating {
  const GetAverageRating(this._repository);

  final ReviewRepository _repository;

  Future<Result<double>> call(String userId) {
    return _repository.getAverageRatingForUser(userId);
  }
}
