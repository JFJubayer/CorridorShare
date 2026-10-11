import 'package:corridorshare/features/auth/presentation/providers/auth_providers.dart';
import 'package:corridorshare/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Profile tab: shows the signed-in user, lets the user pick a language and
/// log out. The wallet and verification UIs land in later increments.
class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final AuthState auth = ref.watch(authControllerProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.tabProfile)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: <Widget>[
          _UserCard(auth: auth),
          const SizedBox(height: 16),
          Text(l10n.profileRating, style: Theme.of(context).textTheme.titleSmall),
          ListTile(
            leading: const Icon(Icons.star_outline),
            title: Text(auth.user?.ratingAvg.toStringAsFixed(1) ?? '—'),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.language),
            title: Text('${l10n.languageEnglish} / ${l10n.languageBangla}'),
            subtitle: const Text('English / বাংলা'),
            onTap: () => _showLanguagePicker(context, ref),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout),
            title: Text(l10n.logout),
            onTap: auth.isAuthenticated
                ? () => ref.read(authControllerProvider.notifier).signOut()
                : null,
          ),
        ],
      ),
    );
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

class _UserCard extends StatelessWidget {
  const _UserCard({required this.auth});

  final AuthState auth;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final String phone = auth.user?.phone ?? '—';
    final String name = auth.user?.name ?? l10n.profileNamePlaceholder;
    final bool verified = auth.user?.verified ?? false;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(name, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 4),
            Text(phone, style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 8),
            Row(
              children: <Widget>[
                Icon(
                  verified ? Icons.verified : Icons.verified_outlined,
                  size: 16,
                  color: verified
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.outline,
                ),
                const SizedBox(width: 6),
                Text(verified ? l10n.profileVerified : l10n.profileUnverified),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
