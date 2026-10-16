import 'package:corridorshare/core/utils/result.dart';
import 'package:corridorshare/features/reviews/data/datasources/in_memory_review_datasource.dart';
import 'package:corridorshare/features/reviews/data/models/review_dto.dart';
import 'package:corridorshare/features/reviews/data/repositories/review_repository_impl.dart';
import 'package:corridorshare/features/reviews/domain/entities/review.dart';
import 'package:corridorshare/features/reviews/domain/usecases/review_usecases.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late InMemoryReviewDataSource dataSource;
  late ReviewRepositoryImpl repository;
  late CreateReview createReview;
  late GetReviewsForUser getReviewsForUser;
  late GetAverageRating getAverageRating;

  setUp(() {
    dataSource = InMemoryReviewDataSource(initialReviews: <ReviewDto>[]);
    repository = ReviewRepositoryImpl(dataSource);
    createReview = CreateReview(repository);
    getReviewsForUser = GetReviewsForUser(repository);
    getAverageRating = GetAverageRating(repository);
  });

  group('CreateReview', () {
    test('fails when rating is out of 1-5 range', () async {
      final res = await createReview(
        Review(
          id: 'r1',
          deliveryId: 'd1',
          reviewerId: 'user-a',
          reviewerName: 'User A',
          targetUserId: 'user-b',
          targetUserName: 'User B',
          rating: 6,
          comment: 'Great service!',
          createdAt: DateTime.now(),
        ),
      );
      expect(res, isA<Err>());
    });

    test('fails when comment is blank', () async {
      final res = await createReview(
        Review(
          id: 'r1',
          deliveryId: 'd1',
          reviewerId: 'user-a',
          reviewerName: 'User A',
          targetUserId: 'user-b',
          targetUserName: 'User B',
          rating: 5,
          comment: '   ',
          createdAt: DateTime.now(),
        ),
      );
      expect(res, isA<Err>());
    });

    test('fails when user reviews themselves', () async {
      final res = await createReview(
        Review(
          id: 'r1',
          deliveryId: 'd1',
          reviewerId: 'user-a',
          reviewerName: 'User A',
          targetUserId: 'user-a',
          targetUserName: 'User A',
          rating: 5,
          comment: 'I did great!',
          createdAt: DateTime.now(),
        ),
      );
      expect(res, isA<Err>());
    });

    test('stores valid review and calculates correct average rating', () async {
      await createReview(
        Review(
          id: 'r1',
          deliveryId: 'd1',
          reviewerId: 'user-a',
          reviewerName: 'User A',
          targetUserId: 'user-b',
          targetUserName: 'User B',
          rating: 5,
          comment: 'Delivered quickly and safely.',
          createdAt: DateTime.now(),
        ),
      );

      await createReview(
        Review(
          id: 'r2',
          deliveryId: 'd2',
          reviewerId: 'user-c',
          reviewerName: 'User C',
          targetUserId: 'user-b',
          targetUserName: 'User B',
          rating: 3,
          comment: 'Slightly delayed arrival.',
          createdAt: DateTime.now(),
        ),
      );

      final reviews = await getReviewsForUser('user-b');
      expect(reviews.getOrThrow().length, 2);

      final avg = await getAverageRating('user-b');
      expect(avg.getOrThrow(), 4.0); // (5 + 3) / 2 = 4.0
    });
  });
}
