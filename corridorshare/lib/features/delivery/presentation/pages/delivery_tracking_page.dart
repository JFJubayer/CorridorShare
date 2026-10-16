import 'package:corridorshare/features/auth/presentation/providers/auth_providers.dart';
import 'package:corridorshare/features/delivery/domain/entities/delivery_status.dart';
import 'package:corridorshare/features/delivery/presentation/providers/delivery_providers.dart';
import 'package:corridorshare/features/delivery/presentation/widgets/delivery_timeline_widget.dart';
import 'package:corridorshare/features/delivery/presentation/widgets/pickup_handover_sheet.dart';
import 'package:corridorshare/features/delivery/presentation/widgets/report_dispute_dialog.dart';
import 'package:corridorshare/features/delivery/presentation/widgets/verify_handover_dialog.dart';
import 'package:corridorshare/features/reviews/presentation/widgets/submit_review_dialog.dart';
import 'package:corridorshare/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DeliveryTrackingPage extends ConsumerStatefulWidget {
  const DeliveryTrackingPage({
    required this.deliveryId,
    super.key,
  });

  final String deliveryId;

  @override
  ConsumerState<DeliveryTrackingPage> createState() =>
      _DeliveryTrackingPageState();
}

class _DeliveryTrackingPageState extends ConsumerState<DeliveryTrackingPage> {
  String get _currentUserId => ref.read(currentUserProvider)?.id ?? '';

  void _openPickupSheet(dynamic delivery) {
    showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (context) => PickupHandoverSheet(delivery: delivery),
    );
  }

  void _openVerifyDialog() {
    showDialog<bool>(
      context: context,
      builder: (context) => VerifyHandoverDialog(deliveryId: widget.deliveryId),
    );
  }

  void _openDisputeDialog() {
    showDialog<bool>(
      context: context,
      builder: (context) => ReportDisputeDialog(
        deliveryId: widget.deliveryId,
        currentUserId: _currentUserId,
      ),
    );
  }

  void _openReviewDialog(dynamic delivery) {
    final isSender = delivery.senderId == _currentUserId;
    final targetId = isSender ? delivery.travellerId : delivery.senderId;
    final targetName = isSender ? delivery.travellerName : delivery.senderName;
    final myName = isSender ? delivery.senderName : delivery.travellerName;

    showDialog<bool>(
      context: context,
      builder: (context) => SubmitReviewDialog(
        deliveryId: delivery.id,
        reviewerId: _currentUserId,
        reviewerName: myName,
        targetUserId: targetId,
        targetUserName: targetName,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final deliveryAsync = ref.watch(deliveryByIdProvider(widget.deliveryId));

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.deliveryTrackingTitle),
      ),
      body: deliveryAsync.when(
        data: (delivery) {
          final isSender = delivery.senderId == _currentUserId;
          final isTraveller = delivery.travellerId == _currentUserId;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                // Corridor & Price Summary Card
                Card(
                  elevation: 0,
                  color: theme.colorScheme.surfaceContainerHighest,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          delivery.parcelTitle,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: <Widget>[
                            const Icon(Icons.route, size: 18),
                            const SizedBox(width: 6),
                            Text(
                              '${delivery.fromDistrict} → ${delivery.toDistrict}',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.primaryContainer,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                '৳ ${delivery.agreedPrice.toStringAsFixed(0)}',
                                style: theme.textTheme.titleSmall?.copyWith(
                                  color: theme.colorScheme.onPrimaryContainer,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const Divider(height: 24),
                        Row(
                          children: <Widget>[
                            Expanded(
                              child: Text(
                                'Sender: ${delivery.senderName}',
                                style: theme.textTheme.bodySmall,
                              ),
                            ),
                            Expanded(
                              child: Text(
                                'Traveller: ${delivery.travellerName}',
                                style: theme.textTheme.bodySmall,
                                textAlign: TextAlign.end,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Interactive Timeline
                DeliveryTimelineWidget(delivery: delivery),
                const SizedBox(height: 16),

                // Recipient / Sender 4-Digit Verification PIN Box
                if (isSender || delivery.status == DeliveryStatus.inTransit) ...<Widget>[
                  Card(
                    elevation: 0,
                    color: Colors.green.shade50,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(color: Colors.green.shade200),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: <Widget>[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Icon(Icons.lock_outline, color: Colors.green.shade800),
                              const SizedBox(width: 8),
                              Text(
                                l10n.recipientHandoverPinLabel,
                                style: TextStyle(
                                  color: Colors.green.shade900,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.green.shade300),
                            ),
                            child: Text(
                              delivery.verificationPin,
                              key: const Key('displayVerificationPin'),
                              style: const TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 8,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            l10n.recipientPinSecurityNotice,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.green.shade800,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // Action Controls for Traveller
                if (isTraveller && !delivery.status.isTerminal) ...<Widget>[
                  if (delivery.status == DeliveryStatus.matched)
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        key: const Key('openPickupSheetButton'),
                        onPressed: () => _openPickupSheet(delivery),
                        icon: const Icon(Icons.handshake),
                        label: Text(l10n.confirmPickupAction),
                      ),
                    ),
                  if (delivery.status == DeliveryStatus.inTransit)
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        key: const Key('openVerifyDialogButton'),
                        style: FilledButton.styleFrom(
                          backgroundColor: Colors.green.shade700,
                        ),
                        onPressed: _openVerifyDialog,
                        icon: const Icon(Icons.check_circle),
                        label: Text(l10n.completeDeliveryAction),
                      ),
                    ),
                  const SizedBox(height: 12),
                ],

                if (delivery.status == DeliveryStatus.delivered) ...<Widget>[
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.tonalIcon(
                      key: const Key('openReviewDialogButton'),
                      onPressed: () => _openReviewDialog(delivery),
                      icon: const Icon(Icons.star, color: Colors.amber),
                      label: Text(l10n.reviewsRateUserTitle),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],

                // Dispute reporting button
                if (!delivery.status.isTerminal)
                  Center(
                    child: TextButton.icon(
                      key: const Key('openDisputeDialogButton'),
                      onPressed: _openDisputeDialog,
                      icon: const Icon(Icons.report_problem, color: Colors.red, size: 18),
                      label: Text(
                        l10n.reportDisputeAction,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(
          child: Text(err.toString()),
        ),
      ),
    );
  }
}
