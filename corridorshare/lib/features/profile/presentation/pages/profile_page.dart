import 'package:corridorshare/core/router/app_router.dart';
import 'package:corridorshare/core/theme/app_colors.dart';
import 'package:corridorshare/features/auth/domain/entities/auth_user.dart';
import 'package:corridorshare/features/auth/presentation/providers/auth_providers.dart';
import 'package:corridorshare/features/parcels/presentation/providers/parcel_providers.dart';
import 'package:corridorshare/features/reviews/presentation/widgets/reviews_list_widget.dart';
import 'package:corridorshare/features/trips/presentation/providers/trip_providers.dart';
import 'package:corridorshare/features/wallet/presentation/providers/wallet_providers.dart';
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
    final Locale currentLocale = ref.watch(localeControllerProvider);
    final AuthUser? user = ref.watch(currentUserProvider);
    final String activeUserId = user?.id ?? '';
    final bool isSignedIn = user != null;

    final String displayName = user != null && user.name.isNotEmpty
        ? user.name
        : (user != null && user.email.isNotEmpty
            ? user.email.split('@').first
            : 'Tania Rahman');

    final String displayContact = _formatContact(user);

    final String initials = _deriveInitials(displayName);

    final bool isVerified = user?.verified ?? true;

    // Rating text
    final String ratingText = (user != null && user.ratingAvg > 0)
        ? user.ratingAvg.toStringAsFixed(1)
        : '4.9';

    // Sent and Carried counts
    final myParcelsAsync = ref.watch(myParcelsProvider);
    final myTripsAsync = ref.watch(myTripsProvider);
    final String sentCountText = myParcelsAsync.maybeWhen(
      data: (parcels) => parcels.length.toString(),
      orElse: () => '0',
    );
    final String carriedCountText = myTripsAsync.maybeWhen(
      data: (trips) => trips.length.toString(),
      orElse: () => '0',
    );

    // Wallet balance
    final walletAsync = ref.watch(userWalletProvider(activeUserId));
    final String walletBalanceText = walletAsync.maybeWhen(
      data: (wallet) {
        final int balance = wallet.balance.toInt();
        return _formatCurrency(balance);
      },
      orElse: () => '1,250',
    );

    final bool isBangla = currentLocale.languageCode == 'bn';

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
            fontSize: 26,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.5,
            color: AppColors.darkCharcoal,
          ),
        ),
        actions: <Widget>[
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Container(
              height: 36,
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                color: const Color(0xFFE8E5DD),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  _LanguageSegmentButton(
                    key: const Key('langBnButton'),
                    label: 'বাংলা',
                    isSelected: isBangla,
                    onTap: () {
                      ref
                          .read(localeControllerProvider.notifier)
                          .setLocale(const Locale('bn'));
                    },
                  ),
                  _LanguageSegmentButton(
                    key: const Key('langEnButton'),
                    label: 'EN',
                    isSelected: !isBangla,
                    onTap: () {
                      ref
                          .read(localeControllerProvider.notifier)
                          .setLocale(const Locale('en'));
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: <Widget>[
          // 1. User Profile Card
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: AppColors.cardBorder, width: 1.2),
            ),
            child: Row(
              children: <Widget>[
                Container(
                  width: 64,
                  height: 64,
                  decoration: const BoxDecoration(
                    color: AppColors.limeAccent,
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    initials,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: AppColors.darkCharcoal,
                      letterSpacing: -0.5,
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
                          fontSize: 19,
                          fontWeight: FontWeight.w900,
                          color: AppColors.darkCharcoal,
                          letterSpacing: -0.3,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        displayContact,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: AppColors.ticketMutedText,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: isVerified
                              ? AppColors.limeAccent
                              : AppColors.pillInactive,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Icon(
                              isVerified ? Icons.check : Icons.info_outline,
                              size: 14,
                              color: isVerified
                                  ? AppColors.darkCharcoal
                                  : AppColors.ticketMutedText,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              isVerified
                                  ? l10n.profileVerified
                                  : l10n.profileUnverified,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                color: isVerified
                                  ? AppColors.darkCharcoal
                                  : AppColors.ticketMutedText,
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
          const SizedBox(height: 14),

          // 2. Metrics Row (RATING, SENT, CARRIED)
          Row(
            children: <Widget>[
              Expanded(
                child: GestureDetector(
                  key: const Key('ratingStatsCard'),
                  onTap: () => _showReviewsSheet(context, activeUserId),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border:
                          Border.all(color: AppColors.cardBorder, width: 1.2),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            const Icon(
                              Icons.star,
                              size: 16,
                              color: AppColors.darkCharcoal,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              ratingText,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w900,
                                color: AppColors.darkCharcoal,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'RATING',
                          style: TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.8,
                            color: AppColors.ticketMutedText,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: GestureDetector(
                  key: const Key('sentStatsCard'),
                  onTap: () => context.push(AppRoutes.myParcels),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border:
                          Border.all(color: AppColors.cardBorder, width: 1.2),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Text(
                          sentCountText,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                            color: AppColors.darkCharcoal,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'SENT',
                          style: TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.8,
                            color: AppColors.ticketMutedText,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: GestureDetector(
                  key: const Key('carriedStatsCard'),
                  onTap: () => context.go(AppRoutes.myPosts),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border:
                          Border.all(color: AppColors.cardBorder, width: 1.2),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Text(
                          carriedCountText,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                            color: AppColors.darkCharcoal,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'CARRIED',
                          style: TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.8,
                            color: AppColors.ticketMutedText,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // 3. Menu Actions Card
          Material(
            color: Colors.white,
            clipBehavior: Clip.antiAlias,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(22),
              side: const BorderSide(color: AppColors.cardBorder, width: 1.2),
            ),
            child: Column(
              children: <Widget>[
                // My parcels
                _ProfileMenuTile(
                  key: const Key('myParcelsTile'),
                  icon: Icons.view_in_ar_outlined,
                  title: 'My parcels',
                  trailing: const Icon(
                    Icons.chevron_right,
                    color: AppColors.ticketMutedText,
                    size: 20,
                  ),
                  onTap: () => context.push(AppRoutes.myParcels),
                ),
                const Divider(
                  height: 1,
                  thickness: 1,
                  color: AppColors.cardBorder,
                  indent: 16,
                  endIndent: 16,
                ),

                // Wallet
                _ProfileMenuTile(
                  key: const Key('walletTile'),
                  icon: Icons.account_balance_wallet_outlined,
                  title: 'Wallet',
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Text(
                        '৳$walletBalanceText',
                        key: const Key('walletBalanceDisplay'),
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppColors.ticketMutedText,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(
                        Icons.chevron_right,
                        color: AppColors.ticketMutedText,
                        size: 20,
                      ),
                    ],
                  ),
                  onTap: () => context.push(AppRoutes.wallet),
                ),
                const Divider(
                  height: 1,
                  thickness: 1,
                  color: AppColors.cardBorder,
                  indent: 16,
                  endIndent: 16,
                ),

                // Language
                _ProfileMenuTile(
                  key: const Key('languagePickerTile'),
                  icon: Icons.language_outlined,
                  title: 'Language',
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Text(
                        isBangla ? 'বাংলা' : 'English',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: AppColors.ticketMutedText,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(
                        Icons.chevron_right,
                        color: AppColors.ticketMutedText,
                        size: 20,
                      ),
                    ],
                  ),
                  onTap: () => _showLanguagePicker(context, ref),
                ),
                const Divider(
                  height: 1,
                  thickness: 1,
                  color: AppColors.cardBorder,
                  indent: 16,
                  endIndent: 16,
                ),

                // Help
                _ProfileMenuTile(
                  key: const Key('helpTile'),
                  icon: Icons.help_outline_rounded,
                  title: 'Help',
                  trailing: const Icon(
                    Icons.chevron_right,
                    color: AppColors.ticketMutedText,
                    size: 20,
                  ),
                  onTap: () => _showHelpSheet(context),
                ),
                const Divider(
                  height: 1,
                  thickness: 1,
                  color: AppColors.cardBorder,
                  indent: 16,
                  endIndent: 16,
                ),

                // Sign in / Sign out
                if (isSignedIn)
                  _ProfileMenuTile(
                    key: const Key('signOutTile'),
                    icon: Icons.logout_rounded,
                    iconColor: const Color(0xFFD94848),
                    title: l10n.logout,
                    titleColor: const Color(0xFFD94848),
                    onTap: () => _confirmSignOut(context, ref, l10n),
                  )
                else
                  _ProfileMenuTile(
                    key: const Key('signInTile'),
                    icon: Icons.login_rounded,
                    title: l10n.signIn,
                    trailing: const Icon(
                      Icons.chevron_right,
                      color: AppColors.ticketMutedText,
                      size: 20,
                    ),
                    onTap: () => context.go(AppRoutes.auth),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  static String _deriveInitials(String name) {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return 'TR';
    final parts = trimmed.split(' ').where((s) => s.isNotEmpty).toList();
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return parts[0].substring(0, parts[0].length >= 2 ? 2 : 1).toUpperCase();
  }

  static String _formatContact(AuthUser? user) {
    if (user == null) return '+880 1712-••••14';
    if (user.phone.isNotEmpty) {
      final digits = user.phone.replaceAll(RegExp(r'\D'), '');
      if (digits.length >= 10) {
        final prefix = digits.startsWith('880')
            ? '+880 ${digits.substring(3, 7)}'
            : '+880 ${digits.substring(1, 5)}';
        final suffix = digits.substring(digits.length - 2);
        return '$prefix-••••$suffix';
      }
      return user.phone;
    }
    if (user.email.isNotEmpty) return user.email;
    return '+880 1712-••••14';
  }

  static String _formatCurrency(int amount) {
    if (amount >= 1000) {
      final thousands = amount ~/ 1000;
      final remainder = (amount % 1000).toString().padLeft(3, '0');
      return '$thousands,$remainder';
    }
    return amount.toString();
  }

  void _showWalletSheet(BuildContext context, String userId) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.warmIvory,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (BuildContext sheetContext) {
        return Padding(
          padding: EdgeInsets.fromLTRB(
            16,
            16,
            16,
            24 + MediaQuery.paddingOf(sheetContext).bottom,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.cardBorder,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              WalletCard(userId: userId),
            ],
          ),
        );
      },
    );
  }

  void _showReviewsSheet(BuildContext context, String userId) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.warmIvory,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (BuildContext sheetContext) {
        return DraggableScrollableSheet(
          initialChildSize: 0.65,
          minChildSize: 0.4,
          maxChildSize: 0.9,
          expand: false,
          builder: (context, scrollController) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              child: ListView(
                controller: scrollController,
                children: <Widget>[
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.cardBorder,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ReviewsListWidget(userId: userId),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showHelpSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.warmIvory,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (BuildContext sheetContext) {
        return Padding(
          padding: EdgeInsets.fromLTRB(
            20,
            16,
            20,
            24 + MediaQuery.paddingOf(sheetContext).bottom,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.cardBorder,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                'Help & Support',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: AppColors.darkCharcoal,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Need assistance with a parcel handover, verification, or traveller trip? Our community team is here to help.',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: AppColors.ticketMutedText,
                ),
              ),
              const SizedBox(height: 16),
              const ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(
                  Icons.phone_in_talk_outlined,
                  color: AppColors.darkCharcoal,
                ),
                title: Text(
                  'Support Hotline',
                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
                ),
                subtitle: Text('+880 1700 000000 (9 AM - 10 PM)'),
              ),
              const ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(
                  Icons.email_outlined,
                  color: AppColors.darkCharcoal,
                ),
                title: Text(
                  'Email Support',
                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
                ),
                subtitle: Text('support@corridorshare.com'),
              ),
              ListTile(
                key: const Key('adminDashboardTile'),
                contentPadding: EdgeInsets.zero,
                leading: const Icon(
                  Icons.admin_panel_settings_outlined,
                  color: AppColors.darkCharcoal,
                ),
                title: const Text(
                  'Admin Dashboard',
                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
                ),
                subtitle: const Text('Platform health and dispute queue'),
                trailing: const Icon(
                  Icons.chevron_right,
                  color: AppColors.ticketMutedText,
                ),
                onTap: () {
                  Navigator.of(sheetContext).pop();
                  context.push(AppRoutes.admin);
                },
              ),
            ],
          ),
        );
      },
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
          title: const Text(
            'Select Language',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
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

class _LanguageSegmentButton extends StatelessWidget {
  const _LanguageSegmentButton({
    required this.label,
    required this.isSelected,
    required this.onTap,
    super.key,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.darkCharcoal : Colors.transparent,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w800,
            color: isSelected ? Colors.white : AppColors.ticketMutedText,
          ),
        ),
      ),
    );
  }
}

class _ProfileMenuTile extends StatelessWidget {
  const _ProfileMenuTile({
    required this.icon,
    required this.title,
    required this.onTap,
    this.iconColor = AppColors.darkCharcoal,
    this.titleColor = AppColors.darkCharcoal,
    this.trailing,
    super.key,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final Color titleColor;
  final Widget? trailing;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: Icon(icon, size: 22, color: iconColor),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 15.5,
          fontWeight: FontWeight.w700,
          color: titleColor,
        ),
      ),
      trailing: trailing,
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 2),
      visualDensity: const VisualDensity(horizontal: 0, vertical: -1),
    );
  }
}