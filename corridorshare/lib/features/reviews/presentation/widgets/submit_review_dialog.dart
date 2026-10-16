import 'package:corridorshare/features/reviews/domain/entities/review.dart';
import 'package:corridorshare/features/reviews/presentation/providers/review_providers.dart';
import 'package:corridorshare/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SubmitReviewDialog extends ConsumerStatefulWidget {
  const SubmitReviewDialog({
    required this.deliveryId,
    required this.reviewerId,
    required this.reviewerName,
    required this.targetUserId,
    required this.targetUserName,
    super.key,
  });

  final String deliveryId;
  final String reviewerId;
  final String reviewerName;
  final String targetUserId;
  final String targetUserName;

  @override
  ConsumerState<SubmitReviewDialog> createState() => _SubmitReviewDialogState();
}

class _SubmitReviewDialogState extends ConsumerState<SubmitReviewDialog> {
  int _rating = 5;
  final _commentController = TextEditingController();
  String? _errorMessage;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final comment = _commentController.text.trim();
    if (comment.isEmpty) {
      setState(() => _errorMessage = 'Please provide a feedback comment');
      return;
    }

    setState(() => _errorMessage = null);

    final review = Review(
      id: 'rev_${DateTime.now().millisecondsSinceEpoch}',
      deliveryId: widget.deliveryId,
      reviewerId: widget.reviewerId,
      reviewerName: widget.reviewerName,
      targetUserId: widget.targetUserId,
      targetUserName: widget.targetUserName,
      rating: _rating,
      comment: comment,
      createdAt: DateTime.now(),
    );

    final success = await ref
        .read(reviewActionControllerProvider.notifier)
        .createReview(review);

    if (mounted && success) {
      Navigator.of(context).pop(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final actionState = ref.watch(reviewActionControllerProvider);

    return AlertDialog(
      title: Row(
        children: <Widget>[
          const Icon(Icons.star, color: Colors.amber),
          const SizedBox(width: 8),
          Text(l10n.reviewsRateUserTitle),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            '${l10n.reviewsRatingFor}: ${widget.targetUserName}',
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          // Interactive 5 stars
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (index) {
              final starValue = index + 1;
              return IconButton(
                key: Key('starRating_$starValue'),
                icon: Icon(
                  starValue <= _rating ? Icons.star : Icons.star_border,
                  color: Colors.amber,
                  size: 32,
                ),
                onPressed: () => setState(() => _rating = starValue),
              );
            }),
          ),
          const SizedBox(height: 12),
          TextField(
            key: const Key('reviewCommentField'),
            controller: _commentController,
            maxLines: 3,
            decoration: InputDecoration(
              labelText: l10n.reviewsCommentHint,
              border: const OutlineInputBorder(),
              errorText: _errorMessage,
            ),
          ),
        ],
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(l10n.commonCancel),
        ),
        FilledButton(
          key: const Key('submitReviewButton'),
          onPressed: actionState.isLoading ? null : _submit,
          child: actionState.isLoading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(l10n.reviewsSubmitAction),
        ),
      ],
    );
  }
}
