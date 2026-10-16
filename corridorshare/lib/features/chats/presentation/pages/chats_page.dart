import 'package:corridorshare/core/router/app_router.dart';
import 'package:corridorshare/features/chats/domain/entities/chat_conversation.dart';
import 'package:corridorshare/features/chats/presentation/providers/chat_providers.dart';
import 'package:corridorshare/features/offers/domain/entities/offer_status.dart';
import 'package:corridorshare/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class ChatsPage extends ConsumerWidget {
  const ChatsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final conversationsAsync = ref.watch(conversationsProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.tabChats)),
      body: conversationsAsync.when(
        data: (conversations) {
          if (conversations.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  const Icon(
                    Icons.chat_bubble_outline,
                    size: 64,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    l10n.chatsEmpty,
                    style: theme.textTheme.bodyMedium,
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async => ref.refresh(conversationsProvider),
            child: ListView.separated(
              itemCount: conversations.length,
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final conv = conversations[index];
                return _ConversationTile(
                  conversation: conv,
                  onTap: () => context.push('${AppRoutes.chats}/${conv.offerId}'),
                );
              },
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text(err.toString())),
      ),
    );
  }
}

class _ConversationTile extends StatelessWidget {
  const _ConversationTile({
    required this.conversation,
    required this.onTap,
  });

  final ChatConversation conversation;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final timeFormat = DateFormat('d MMM, h:mm a');

    final isAgreed = conversation.offerStatus == OfferStatus.accepted;

    return ListTile(
      onTap: onTap,
      leading: CircleAvatar(
        backgroundColor: isAgreed
            ? Colors.green.withValues(alpha: 0.2)
            : theme.colorScheme.primaryContainer,
        child: Text(
          conversation.counterpartName.isNotEmpty
              ? conversation.counterpartName[0].toUpperCase()
              : '?',
          style: TextStyle(
            color: isAgreed
                ? Colors.green
                : theme.colorScheme.onPrimaryContainer,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      title: Row(
        children: <Widget>[
          Expanded(
            child: Text(
              conversation.counterpartName,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: isAgreed
                  ? Colors.green.withValues(alpha: 0.15)
                  : theme.colorScheme.secondaryContainer,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              '৳${conversation.price.toStringAsFixed(0)}',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: isAgreed
                    ? Colors.green
                    : theme.colorScheme.onSecondaryContainer,
              ),
            ),
          ),
        ],
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const SizedBox(height: 2),
          Text(
            '${conversation.parcelTitle} • ${conversation.fromDistrict} → ${conversation.toDistrict}',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.primary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            conversation.lastMessageText,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
      trailing: Text(
        timeFormat.format(conversation.lastMessageTime),
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.outline,
          fontSize: 11,
        ),
      ),
    );
  }
}
