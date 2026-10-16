import 'package:corridorshare/features/reviews/data/models/review_dto.dart';

abstract class ReviewDataSource {
  Future<ReviewDto> createReview(ReviewDto review);

  Future<List<ReviewDto>> getReviewsForUser(String userId);

  Future<double> getAverageRatingForUser(String userId);
}
