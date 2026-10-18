import 'package:corridorshare/core/router/app_router.dart';
import 'package:corridorshare/core/theme/app_colors.dart';
import 'package:corridorshare/features/auth/domain/entities/auth_user.dart';
import 'package:corridorshare/features/auth/presentation/providers/auth_providers.dart';
import 'package:corridorshare/features/reviews/presentation/widgets/reviews_list_widget.dart';
import 'package:corridorshare/features/wallet/presentation/widgets/wallet_card.dart';
import 'package:corridorshare/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final AuthUser? user = ref.watch(currentUserProvider);
    final String activeUserId = user?.id ?? '';
    final bool isSignedIn = user != null;

    final String displayName = user != null && user.name.isNotEmpty
        ? user.name
        : (user != null && user.email.isNotEmpty
            ? user.email.split('@').first
            : l10n.profileNamePlaceholder);

    final String displayContact = user != null
        ? (user.phone.isNotEmpty ? user.phone : user.email)
        : '';

    final String initials = displayName.trim().isNotEmpty
        ? displayName
            .trim()
            .split(' ')
            .map((String s) => s.isNotEmpty ? s[0] : '')
            .take(2)
            .join()
            .toUpperCase()
        : 'CS';

    final bool isVerified = user?.verified ?? false;

    return Scaffold(
      backgroundColor: AppColors.warmIvory,
      appBar: AppBar(
        backgroundColor: AppColors.warmIvory,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        title: Text(
          l10n.tabProfile,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.5,
            color: AppColors.darkCharcoal,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: <Widget>[
          // User Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.cardBorder, width: 1.2),
            ),
            child: Row(
              children: <Widget>[
                CircleAvatar(
                  radius: 28,
                  backgroundColor: AppColors.darkCharcoal,
                  child: Text(
                    initials.isEmpty ? 'CS' : initials,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      color: AppColors.limeAccent,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        displayName,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: AppColors.darkCharcoal,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        displayContact,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.ticketMutedText,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: isVerified
                              ? AppColors.limeAccent.withValues(alpha: 0.35)
                              : AppColors.pillInactive,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: AppColors.cardBorder,
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Icon(
                              isVerified ? Icons.verified : Icons.info_outline,
                              size: 14,
                              color: isVerified
                                  ? AppColors.darkCharcoal
                                  : AppColors.ticketMutedText,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              isVerified
                                  ? l10n.verifiedPeerBadge
                                  : l10n.profileUnverified,
                              style: TextStyle(
                                color: isVerified
                                    ? AppColors.darkCharcoal
                                    : AppColors.ticketMutedText,
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Demo Wallet Section
          WalletCard(userId: activeUserId),
          const SizedBox(height: 20),

          // Ratings & Reviews Section
          ReviewsListWidget(userId: activeUserId),
          const SizedBox(height: 20),

          // Settings & Actions Group
          Material(
            color: Colors.white,
            clipBehavior: Clip.antiAlias,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: const BorderSide(color: AppColors.cardBorder, width: 1.2),
            ),
            child: Column(
              children: <Widget>[
                // Admin Dashboard Tile
                ListTile(
                  key: const Key('adminDashboardTile'),
                  leading: Container(
                    width: 38,
                    height: 38,
                    decoration: const BoxDecoration(
                      color: AppColors.bannerBg,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.admin_panel_settings_outlined,
                      color: AppColors.darkCharcoal,
                      size: 20,
                    ),
                  ),
                  title: Text(
                    l10n.adminDashboardTitle,
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      color: AppColors.darkCharcoal,
                    ),
                  ),
                  subtitle: Text(
                    l10n.adminDashboardSubtitle,
                    style: const TextStyle(
                      color: AppColors.ticketMutedText,
                      fontSize: 12,
                    ),
                  ),
                  trailing: const Icon(
                    Icons.chevron_right,
                    color: AppColors.ticketMutedText,
                  ),
                  onTap: () => context.push(AppRoutes.admin),
                ),
                const Divider(height: 1, color: AppColors.cardBorder),

                // Language Picker
                ListTile(
                  key: const Key('languagePickerTile'),
                  leading: Container(
                    width: 38,
                    height: 38,
                    decoration: const BoxDecoration(
                      color: AppColors.bannerBg,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.language,
                      color: AppColors.darkCharcoal,
                      size: 20,
                    ),
                  ),
                  title: Text(
                    '${l10n.languageEnglish} / ${l10n.languageBangla}',
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      color: AppColors.darkCharcoal,
                    ),
                  ),
                  subtitle: const Text(
                    'English / বাংলা',
                    style: TextStyle(
                      color: AppColors.ticketMutedText,
                      fontSize: 12,
                    ),
                  ),
                  trailing: const Icon(
                    Icons.chevron_right,
                    color: AppColors.ticketMutedText,
                  ),
                  onTap: () => _showLanguagePicker(context, ref),
                ),
                const Divider(height: 1, color: AppColors.cardBorder),

                // Sign In / Out
                if (isSignedIn)
                  ListTile(
                    key: const Key('signOutTile'),
                    leading: Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.logout,
                        color: AppColors.danger,
                        size: 20,
                      ),
                    ),
                    title: Text(
                      l10n.logout,
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        color: AppColors.danger,
                      ),
                    ),
                    trailing: const Icon(
                      Icons.chevron_right,
                      color: AppColors.ticketMutedText,
                    ),
                    onTap: () => _confirmSignOut(context, ref, l10n),
                  )
                else
                  ListTile(
                    key: const Key('signInTile'),
                    leading: Container(
                      width: 38,
                      height: 38,
                      decoration: const BoxDecoration(
                        color: AppColors.bannerBg,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.login,
                        color: AppColors.darkCharcoal,
                        size: 20,
                      ),
                    ),
                    title: Text(
                      l10n.signIn,
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        color: AppColors.darkCharcoal,
                      ),
                    ),
                    trailing: const Icon(
                      Icons.chevron_right,
                      color: AppColors.ticketMutedText,
                    ),
                    onTap: () => context.go(AppRoutes.auth),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Future<void> _confirmSignOut(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
  ) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(l10n.signOutConfirmTitle),
          content: Text(l10n.signOutConfirmMessage),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(l10n.commonCancel),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: FilledButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.error,
              ),
              child: Text(l10n.logout),
            ),
          ],
        );
      },
    );
    if (confirmed == true) {
      await ref.read(authControllerProvider.notifier).signOut();
    }
  }

  Future<void> _showLanguagePicker(BuildContext context, WidgetRef ref) async {
    final Locale? picked = await showDialog<Locale>(
      context: context,
      builder: (BuildContext context) {
        return SimpleDialog(
          children: <Widget>[
            SimpleDialogOption(
              onPressed: () => Navigator.of(context).pop(const Locale('en')),
              child: const Text('English'),
            ),
            SimpleDialogOption(
              onPressed: () => Navigator.of(context).pop(const Locale('bn')),
              child: const Text('বাংলা'),
            ),
          ],
        );
      },
    );
    if (picked != null) {
      ref.read(localeControllerProvider.notifier).setLocale(picked);
    }
  }
}