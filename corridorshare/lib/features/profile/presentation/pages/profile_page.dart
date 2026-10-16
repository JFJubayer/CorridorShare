import 'package:corridorshare/core/router/app_router.dart';
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
    final ThemeData theme = Theme.of(context);
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
      appBar: AppBar(title: Text(l10n.tabProfile)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: <Widget>[
          // User Card
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: theme.colorScheme.outlineVariant),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: <Widget>[
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: theme.colorScheme.primaryContainer,
                    child: Text(
                      initials.isEmpty ? 'CS' : initials,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onPrimaryContainer,
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
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          displayContact,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: isVerified
                                ? Colors.green.shade50
                                : Colors.amber.shade50,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              Icon(
                                isVerified ? Icons.verified : Icons.info_outline,
                                size: 14,
                                color: isVerified
                                    ? Colors.green.shade700
                                    : Colors.amber.shade800,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                isVerified
                                    ? l10n.verifiedPeerBadge
                                    : l10n.profileUnverified,
                                style: TextStyle(
                                  color: isVerified
                                      ? Colors.green.shade900
                                      : Colors.amber.shade900,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
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
          ),
          const SizedBox(height: 16),

          // Demo Wallet Section
          WalletCard(userId: activeUserId),
          const SizedBox(height: 20),

          // Ratings & Reviews Section
          ReviewsListWidget(userId: activeUserId),
          const SizedBox(height: 20),

          // Admin Dashboard Tile
          ListTile(
            key: const Key('adminDashboardTile'),
            leading: const Icon(Icons.admin_panel_settings_outlined, color: Colors.indigo),
            title: Text(l10n.adminDashboardTitle),
            subtitle: Text(l10n.adminDashboardSubtitle),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push(AppRoutes.admin),
          ),
          const Divider(),

          // Language Picker
          ListTile(
            key: const Key('languagePickerTile'),
            leading: const Icon(Icons.language),
            title: Text('${l10n.languageEnglish} / ${l10n.languageBangla}'),
            subtitle: const Text('English / বাংলা'),
            onTap: () => _showLanguagePicker(context, ref),
          ),
          const Divider(),

          // Sign In / Out
          if (isSignedIn)
            ListTile(
              key: const Key('signOutTile'),
              leading: Icon(Icons.logout, color: theme.colorScheme.error),
              title: Text(
                l10n.logout,
                style: TextStyle(color: theme.colorScheme.error),
              ),
              onTap: () => _confirmSignOut(context, ref, l10n),
            )
          else
            ListTile(
              key: const Key('signInTile'),
              leading: const Icon(Icons.login),
              title: Text(l10n.signIn),
              onTap: () => context.go(AppRoutes.auth),
            ),
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