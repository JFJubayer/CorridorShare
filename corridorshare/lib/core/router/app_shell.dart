import 'package:corridorshare/core/theme/app_colors.dart';
import 'package:corridorshare/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class _NavItemConfig {
  const _NavItemConfig({
    required this.branchIndex,
    required this.labelKey,
    required this.defaultLabel,
    required this.icon,
    required this.activeIcon,
  });

  final int branchIndex;
  final String labelKey;
  final String defaultLabel;
  final IconData icon;
  final IconData activeIcon;
}

class AppShell extends StatelessWidget {
  const AppShell({required this.navigationShell, super.key});

  final StatefulNavigationShell navigationShell;

  // The 4 items ordered according to the design: Chat, Me, Explore, Profile
  // Each maps directly to its corresponding branchIndex in StatefulNavigationShell.
  static const List<_NavItemConfig> _navItems = <_NavItemConfig>[
    _NavItemConfig(
      branchIndex: 0, // Home
      labelKey: 'home',
      defaultLabel: 'Home',
      icon: Icons.home_outlined,
      activeIcon: Icons.home_rounded,
    ),
    _NavItemConfig(
      branchIndex: 1, // My Posts
      labelKey: 'my_posts',
      defaultLabel: 'My posts',
      icon: Icons.format_list_bulleted_rounded,
      activeIcon: Icons.format_list_bulleted_rounded,
    ),
    _NavItemConfig(
      branchIndex: 2, // Chats
      labelKey: 'chats',
      defaultLabel: 'Chats',
      icon: Icons.chat_bubble_outline_rounded,
      activeIcon: Icons.chat_bubble_rounded,
    ),
    _NavItemConfig(
      branchIndex: 3, // Profile
      labelKey: 'profile',
      defaultLabel: 'Profile',
      icon: Icons.person_outline_rounded,
      activeIcon: Icons.person_rounded,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: AppColors.warmIvory,
      body: navigationShell,
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: AppColors.warmIvory,
          border: Border(
            top: BorderSide(color: AppColors.cardBorder, width: 1.0),
          ),
        ),
        padding: EdgeInsets.fromLTRB(8, 8, 8, 8 + bottomInset),
        child: SizedBox(
          height: 60,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: _navItems.map((item) {
              final isSelected =
                  navigationShell.currentIndex == item.branchIndex;
              final label = _resolveLabel(item.labelKey, l10n);

              return Expanded(
                child: _MenuTabItem(
                  key: Key('navTab_${item.labelKey}'),
                  label: label,
                  icon: isSelected ? item.activeIcon : item.icon,
                  isSelected: isSelected,
                  onTap: () {
                    navigationShell.goBranch(
                      item.branchIndex,
                      initialLocation:
                          item.branchIndex == navigationShell.currentIndex,
                    );
                  },
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  String _resolveLabel(String labelKey, AppLocalizations l10n) {
    switch (labelKey) {
      case 'home':
        return l10n.tabHome;
      case 'my_posts':
        return l10n.tabMyPosts;
      case 'chats':
        return l10n.tabChats;
      case 'profile':
        return l10n.tabProfile;
      default:
        return '';
    }
  }
}

class _MenuTabItem extends StatelessWidget {
  const _MenuTabItem({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
    super.key,
  });

  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    const activeColor = AppColors.darkCharcoal;
    const inactiveColor = AppColors.ticketMutedText;

    return InkWell(
      onTap: onTap,
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: 58,
              height: 32,
              decoration: BoxDecoration(
                color: isSelected ? AppColors.limeAccent : Colors.transparent,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                icon,
                size: 22,
                color: isSelected ? activeColor : inactiveColor,
              ),
            ),
            const SizedBox(height: 3),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 150),
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                color: isSelected ? activeColor : inactiveColor,
              ),
              child: Text(label),
            ),
          ],
        ),
      ),
    );
  }
}

