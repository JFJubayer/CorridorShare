import 'package:corridorshare/features/reviews/data/datasources/review_datasource.dart';
import 'package:corridorshare/features/reviews/data/models/review_dto.dart';

class InMemoryReviewDataSource implements ReviewDataSource {
  InMemoryReviewDataSource({List<ReviewDto>? initialReviews})
      : _reviews = initialReviews != null ? List<ReviewDto>.from(initialReviews) : <ReviewDto>[];

  final List<ReviewDto> _reviews;

  @override
  Future<ReviewDto> createReview(ReviewDto review) async {
    _reviews.insert(0, review);
    return review;
  }

  @override
  Future<List<ReviewDto>> getReviewsForUser(String userId) async {
    return _reviews.where((r) => r.targetUserId == userId).toList();
  }

  @override
  Future<double> getAverageRatingForUser(String userId) async {
    final userReviews = _reviews.where((r) => r.targetUserId == userId).toList();
    if (userReviews.isEmpty) return 0.0;
    final sum = userReviews.fold<double>(0.0, (acc, r) => acc + r.rating);
    return sum / userReviews.length;
  }
}
