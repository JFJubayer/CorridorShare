import 'package:corridorshare/core/di/injection.dart';
import 'package:corridorshare/features/reviews/domain/entities/review.dart';
import 'package:corridorshare/features/reviews/domain/usecases/review_usecases.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

export 'package:corridorshare/core/di/injection.dart'
    show reviewDataSourceProvider, reviewRepositoryProvider;

final createReviewUseCaseProvider = Provider<CreateReview>((ref) {
  return CreateReview(ref.watch(reviewRepositoryProvider));
});

final getReviewsForUserUseCaseProvider = Provider<GetReviewsForUser>((ref) {
  return GetReviewsForUser(ref.watch(reviewRepositoryProvider));
});

final getAverageRatingUseCaseProvider = Provider<GetAverageRating>((ref) {
  return GetAverageRating(ref.watch(reviewRepositoryProvider));
});

final userReviewsProvider =
    FutureProvider.family<List<Review>, String>((ref, userId) async {
  final result = await ref.watch(getReviewsForUserUseCaseProvider)(userId);
  return result.fold(
    (reviews) => reviews,
    (failure) => throw failure,
  );
});

final userAverageRatingProvider =
    FutureProvider.family<double, String>((ref, userId) async {
  final result = await ref.watch(getAverageRatingUseCaseProvider)(userId);
  return result.fold(
    (rating) => rating,
    (failure) => throw failure,
  );
});

class ReviewActionController extends StateNotifier<AsyncValue<void>> {
  ReviewActionController(this._ref) : super(const AsyncValue<void>.data(null));

  final Ref _ref;

  Future<bool> createReview(Review review) async {
    state = const AsyncValue<void>.loading();
    final result = await _ref.read(createReviewUseCaseProvider)(review);
    return result.fold(
      (_) {
        state = const AsyncValue<void>.data(null);
        _ref.invalidate(userReviewsProvider(review.targetUserId));
        _ref.invalidate(userAverageRatingProvider(review.targetUserId));
        return true;
      },
      (failure) {
        state = AsyncValue<void>.error(failure, StackTrace.current);
        return false;
      },
    );
  }
}

final reviewActionControllerProvider =
    StateNotifierProvider<ReviewActionController, AsyncValue<void>>((ref) {
  return ReviewActionController(ref);
});
