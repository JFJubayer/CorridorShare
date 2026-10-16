import 'package:corridorshare/core/utils/result.dart';
import 'package:corridorshare/features/reviews/domain/entities/review.dart';

abstract class ReviewRepository {
  Future<Result<Review>> createReview(Review review);

  Future<Result<List<Review>>> getReviewsForUser(String userId);

  Future<Result<double>> getAverageRatingForUser(String userId);
}
