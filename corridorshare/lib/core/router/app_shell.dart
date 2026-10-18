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
      branchIndex: 2, // Chats
      labelKey: 'chat',
      defaultLabel: 'Chat',
      icon: Icons.textsms_outlined,
      activeIcon: Icons.textsms,
    ),
    _NavItemConfig(
      branchIndex: 1, // My Posts
      labelKey: 'me',
      defaultLabel: 'Me',
      icon: Icons.grid_view_rounded,
      activeIcon: Icons.grid_view_rounded,
    ),
    _NavItemConfig(
      branchIndex: 0, // Explore (Home)
      labelKey: 'explore',
      defaultLabel: 'Explore',
      icon: Icons.explore_outlined,
      activeIcon: Icons.explore,
    ),
    _NavItemConfig(
      branchIndex: 3, // Profile
      labelKey: 'profile',
      defaultLabel: 'Profile',
      icon: Icons.person_outline_rounded,
      activeIcon: Icons.person,
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
        color: AppColors.warmIvory,
        padding: EdgeInsets.fromLTRB(16, 0, 16, 12 + bottomInset),
        child: Container(
          height: 68,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(34),
            border: Border.all(color: AppColors.cardBorder, width: 1.2),
            boxShadow: const <BoxShadow>[
              BoxShadow(
                color: Color(0x14122017),
                blurRadius: 18,
                offset: Offset(0, 6),
              ),
            ],
          ),
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
      case 'chat':
        return l10n.tabChats == 'Chats' ? 'Chat' : l10n.tabChats;
      case 'me':
        return l10n.tabMyPosts == 'My posts' ? 'Me' : l10n.tabMyPosts;
      case 'explore':
        return l10n.tabHome == 'Home' ? 'Explore' : l10n.tabHome;
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
      borderRadius: BorderRadius.circular(34),
      splashColor: AppColors.limeAccent.withValues(alpha: 0.2),
      highlightColor: Colors.transparent,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            // Icon with soft lime pastel backdrop glow when selected (matching reference image)
            SizedBox(
              width: 32,
              height: 28,
              child: Stack(
                alignment: Alignment.center,
                clipBehavior: Clip.none,
                children: <Widget>[
                  if (isSelected)
                    Positioned(
                      top: 1,
                      left: 1,
                      child: Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          color: AppColors.limeAccent.withValues(alpha: 0.5),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  Icon(
                    icon,
                    size: 24,
                    color: isSelected ? activeColor : inactiveColor,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 3),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 150),
              style: TextStyle(
                fontSize: 12,
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

