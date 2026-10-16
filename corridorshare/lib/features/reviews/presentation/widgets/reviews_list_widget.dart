import 'package:corridorshare/features/reviews/presentation/providers/review_providers.dart';
import 'package:corridorshare/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class ReviewsListWidget extends ConsumerWidget {
  const ReviewsListWidget({
    required this.userId,
    super.key,
  });

  final String userId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final reviewsAsync = ref.watch(userReviewsProvider(userId));
    final avgRatingAsync = ref.watch(userAverageRatingProvider(userId));
    final dateFormat = DateFormat('d MMM yyyy');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Text(
              l10n.reviewsTitle,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            avgRatingAsync.when(
              data: (avg) {
                if (avg == 0.0) return const SizedBox.shrink();
                return Row(
                  children: <Widget>[
                    const Icon(Icons.star, color: Colors.amber, size: 20),
                    const SizedBox(width: 4),
                    Text(
                      avg.toStringAsFixed(1),
                      key: const Key('userAverageRatingDisplay'),
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                );
              },
              loading: () => const SizedBox.shrink(),
              error: (_, _) => const SizedBox.shrink(),
            ),
          ],
        ),
        const SizedBox(height: 12),
        reviewsAsync.when(
          data: (reviews) {
            if (reviews.isEmpty) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Text(
                  l10n.reviewsNoReviews,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              );
            }

            return ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: reviews.length,
              separatorBuilder: (_, _) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final rev = reviews[index];
                return Card(
                  elevation: 0,
                  color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            Text(
                              rev.reviewerName,
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const Spacer(),
                            Row(
                              children: List.generate(
                                rev.rating,
                                (_) => const Icon(
                                  Icons.star,
                                  color: Colors.amber,
                                  size: 16,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          rev.comment,
                          style: theme.textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          dateFormat.format(rev.createdAt),
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
          loading: () => const Center(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: CircularProgressIndicator(),
            ),
          ),
          error: (err, _) => Text(err.toString()),
        ),
      ],
    );
  }
}
