import 'package:corridorshare/core/router/app_router.dart';
import 'package:corridorshare/core/theme/app_colors.dart';
import 'package:corridorshare/features/chats/domain/entities/chat_conversation.dart';
import 'package:corridorshare/features/chats/presentation/providers/chat_providers.dart';
import 'package:corridorshare/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

enum ChatFilterTab { all, unread, deals }

class ChatsPage extends ConsumerStatefulWidget {
  const ChatsPage({super.key});

  @override
  ConsumerState<ChatsPage> createState() => _ChatsPageState();
}

class _ChatsPageState extends ConsumerState<ChatsPage> {
  final TextEditingController _searchController = TextEditingController();
  ChatFilterTab _selectedTab = ChatFilterTab.all;
  String _searchQuery = '';
  String _selectedLanguage = 'EN';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.trim().toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final conversationsAsync = ref.watch(conversationsProvider);

    return Scaffold(
      backgroundColor: AppColors.warmIvory,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async => ref.refresh(conversationsProvider),
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: <Widget>[
              // Top Header Bar with Chats title and Language toggle
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text(
                        l10n.tabChats,
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                          color: AppColors.darkCharcoal,
                          letterSpacing: -0.5,
                        ),
                      ),
                      _LanguageTogglePill(
                        currentLanguage: _selectedLanguage,
                        onChanged: (lang) {
                          setState(() {
                            _selectedLanguage = lang;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),

              // Search Bar
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.warmIvory,
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(
                        color: AppColors.cardBorder,
                        width: 1.2,
                      ),
                    ),
                    child: TextField(
                      controller: _searchController,
                      style: const TextStyle(
                        fontSize: 15,
                        color: AppColors.darkCharcoal,
                      ),
                      decoration: const InputDecoration(
                        hintText: 'Search name or parcel',
                        hintStyle: TextStyle(
                          fontSize: 15,
                          color: AppColors.ticketMutedText,
                          fontWeight: FontWeight.w500,
                        ),
                        prefixIcon: Icon(
                          Icons.search_rounded,
                          color: AppColors.ticketMutedText,
                          size: 22,
                        ),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // Filter Chips Row
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
                  child: conversationsAsync.maybeWhen(
                    data: (conversations) {
                      final unreadCount = conversations
                          .where((c) => c.unreadCount > 0)
                          .fold<int>(0, (sum, c) => sum + c.unreadCount);

                      return Row(
                        children: <Widget>[
                          _FilterChip(
                            label: 'All',
                            isSelected: _selectedTab == ChatFilterTab.all,
                            onTap: () => setState(() => _selectedTab = ChatFilterTab.all),
                          ),
                          const SizedBox(width: 8),
                          _FilterChip(
                            label: unreadCount > 0 ? 'Unread · $unreadCount' : 'Unread',
                            isSelected: _selectedTab == ChatFilterTab.unread,
                            onTap: () => setState(() => _selectedTab = ChatFilterTab.unread),
                          ),
                          const SizedBox(width: 8),
                          _FilterChip(
                            label: 'Deals',
                            isSelected: _selectedTab == ChatFilterTab.deals,
                            onTap: () => setState(() => _selectedTab = ChatFilterTab.deals),
                          ),
                        ],
                      );
                    },
                    orElse: () => Row(
                      children: <Widget>[
                        _FilterChip(
                          label: 'All',
                          isSelected: _selectedTab == ChatFilterTab.all,
                          onTap: () => setState(() => _selectedTab = ChatFilterTab.all),
                        ),
                        const SizedBox(width: 8),
                        _FilterChip(
                          label: 'Unread · 3',
                          isSelected: _selectedTab == ChatFilterTab.unread,
                          onTap: () => setState(() => _selectedTab = ChatFilterTab.unread),
                        ),
                        const SizedBox(width: 8),
                        _FilterChip(
                          label: 'Deals',
                          isSelected: _selectedTab == ChatFilterTab.deals,
                          onTap: () => setState(() => _selectedTab = ChatFilterTab.deals),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Conversations Card Container
              conversationsAsync.when(
                data: (conversations) {
                  var filtered = conversations.where((c) {
                    // Search filtering
                    if (_searchQuery.isNotEmpty) {
                      final matchName =
                          c.counterpartName.toLowerCase().contains(_searchQuery);
                      final matchParcel =
                          c.parcelTitle.toLowerCase().contains(_searchQuery);
                      final matchRoute =
                          '${c.fromDistrict} ${c.toDistrict}'.toLowerCase().contains(_searchQuery);
                      if (!matchName && !matchParcel && !matchRoute) {
                        return false;
                      }
                    }

                    // Tab filtering
                    if (_selectedTab == ChatFilterTab.unread) {
                      return c.unreadCount > 0;
                    }
                    if (_selectedTab == ChatFilterTab.deals) {
                      return c.customTagType == 'agreed' ||
                          c.customTagType == 'counter' ||
                          c.customTagType == 'delivered';
                    }
                    return true;
                  }).toList();

                  if (filtered.isEmpty) {
                    return SliverToBoxAdapter(
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                        padding: const EdgeInsets.all(32),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: AppColors.cardBorder,
                            width: 1.2,
                          ),
                        ),
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              const Icon(
                                Icons.chat_bubble_outline_rounded,
                                size: 48,
                                color: AppColors.ticketMutedText,
                              ),
                              const SizedBox(height: 12),
                              Text(
                                l10n.chatsEmpty,
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.ticketMutedText,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }

                  return SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: AppColors.cardBorder,
                            width: 1.2,
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(24),
                          child: ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: filtered.length,
                            separatorBuilder: (context, index) => const Divider(
                              height: 1,
                              thickness: 1,
                              color: AppColors.cardBorder,
                              indent: 76,
                              endIndent: 16,
                            ),
                            itemBuilder: (context, index) {
                              final conv = filtered[index];
                              return _ConversationTile(
                                conversation: conv,
                                onTap: () => context.push('${AppRoutes.chats}/${conv.offerId}'),
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  );
                },
                loading: () => const SliverFillRemaining(
                  child: Center(
                    child: CircularProgressIndicator(
                      color: AppColors.darkCharcoal,
                    ),
                  ),
                ),
                error: (err, _) => SliverFillRemaining(
                  child: Center(child: Text(err.toString())),
                ),
              ),

              const SliverToBoxAdapter(
                child: SizedBox(height: 32),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LanguageTogglePill extends StatelessWidget {
  const _LanguageTogglePill({
    required this.currentLanguage,
    required this.onChanged,
  });

  final String currentLanguage;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: AppColors.pillInactive,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          _LangOption(
            text: 'বাংলা',
            isSelected: currentLanguage == 'BN',
            onTap: () => onChanged('BN'),
          ),
          _LangOption(
            text: 'EN',
            isSelected: currentLanguage == 'EN',
            onTap: () => onChanged('EN'),
          ),
        ],
      ),
    );
  }
}

class _LangOption extends StatelessWidget {
  const _LangOption({
    required this.text,
    required this.isSelected,
    required this.onTap,
  });

  final String text;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.darkCharcoal : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
            color: isSelected ? Colors.white : AppColors.ticketMutedText,
          ),
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.limeAccent : AppColors.pillInactive,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
            color: AppColors.darkCharcoal,
          ),
        ),
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

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inDays == 0 && now.day == time.day) {
      return DateFormat('h:mm a').format(time).toLowerCase();
    } else if (difference.inDays <= 1 || (difference.inDays < 2 && now.day != time.day)) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return DateFormat('E').format(time); // Mon, Tue, etc.
    } else {
      return DateFormat('d MMM').format(time); // 12 Oct
    }
  }

  String _getInitials(String name) {
    if (name.isEmpty) return '?';
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.substring(0, name.length >= 2 ? 2 : 1).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final isSystemCS = conversation.counterpartName == 'CorridorShare';
    final initials = isSystemCS ? 'CS' : _getInitials(conversation.counterpartName);

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // Avatar
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: isSystemCS ? AppColors.darkCharcoal : AppColors.limeAccent,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Text(
                initials,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: isSystemCS ? AppColors.limeAccent : AppColors.darkCharcoal,
                ),
              ),
            ),
            const SizedBox(width: 14),

            // Middle & Right info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  // Row 1: Name + Verified Check + Timestamp
                  Row(
                    children: <Widget>[
                      Flexible(
                        child: Text(
                          conversation.counterpartName,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: AppColors.darkCharcoal,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (conversation.isVerified && !isSystemCS) ...<Widget>[
                        const SizedBox(width: 4),
                        const Icon(
                          Icons.check_circle_rounded,
                          size: 16,
                          color: Color(0xFF7CB342),
                        ),
                      ],
                      const Spacer(),
                      Text(
                        _formatTime(conversation.lastMessageTime),
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.ticketMutedText,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),

                  // Row 2: Status pill + Route / Parcel description
                  Row(
                    children: <Widget>[
                      if (conversation.customTag != null &&
                          conversation.customTag!.isNotEmpty) ...<Widget>[
                        _StatusPill(
                          tag: conversation.customTag!,
                          tagType: conversation.customTagType ?? 'default',
                        ),
                        const SizedBox(width: 6),
                      ],
                      Expanded(
                        child: Text(
                          isSystemCS
                              ? 'Support'
                              : (conversation.toDistrict.isNotEmpty
                                  ? '${conversation.parcelTitle} → ${conversation.toDistrict}'
                                  : conversation.parcelTitle),
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: AppColors.ticketMutedText,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),

                  // Row 3: Message preview + Unread badge
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: Text(
                          conversation.lastMessageText,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: conversation.unreadCount > 0
                                ? FontWeight.w700
                                : FontWeight.w500,
                            color: conversation.unreadCount > 0
                                ? AppColors.darkCharcoal
                                : const Color(0xFF3E4740),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (conversation.unreadCount > 0) ...<Widget>[
                        const SizedBox(width: 8),
                        Container(
                          width: 20,
                          height: 20,
                          decoration: const BoxDecoration(
                            color: AppColors.darkCharcoal,
                            shape: BoxShape.circle,
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            '${conversation.unreadCount}',
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({
    required this.tag,
    required this.tagType,
  });

  final String tag;
  final String tagType;

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color fg;

    switch (tagType) {
      case 'agreed':
        bg = const Color(0xFFD6EE5B);
        fg = AppColors.darkCharcoal;
        break;
      case 'counter':
        bg = const Color(0xFFF7E8B8);
        fg = AppColors.darkCharcoal;
        break;
      case 'disputed':
        bg = const Color(0xFFFDE4E4);
        fg = const Color(0xFFD32F2F);
        break;
      case 'delivered':
        bg = const Color(0xFFDBF2D0);
        fg = const Color(0xFF2E7D32);
        break;
      case 'help':
        bg = AppColors.pillInactive;
        fg = AppColors.darkCharcoal;
        break;
      default:
        bg = AppColors.pillInactive;
        fg = AppColors.darkCharcoal;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        tag,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w800,
          color: fg,
        ),
      ),
    );
  }
}
