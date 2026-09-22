import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';

/// Premium Floating Glass Bottom Dock Shell — Phone-first, AMOLED optimized.
class AppShell extends StatelessWidget {
  const AppShell({
    super.key,
    required this.navigationShell,
  });

  final StatefulNavigationShell navigationShell;

  void _onTap(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.sizeOf(context).width >= 600;

    if (isWide) {
      return Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        body: Row(
          children: [
            _WideRail(
              selectedIndex: navigationShell.currentIndex,
              onSelect: _onTap,
            ),
            const VerticalDivider(thickness: 1, width: 1),
            Expanded(child: navigationShell),
          ],
        ),
      );
    }

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      extendBody: true, // content flows under floating dock
      body: navigationShell,
      bottomNavigationBar: _FloatingGlassDock(
        currentIndex: navigationShell.currentIndex,
        onTap: _onTap,
      ),
    );
  }
}

// ── Floating Glass Dock (Phone) ───────────────────────────────────────────────

class _FloatingGlassDock extends StatelessWidget {
  const _FloatingGlassDock({
    required this.currentIndex,
    required this.onTap,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;

  static const _items = [
    _DockItem(icon: Icons.home_rounded, outlinedIcon: Icons.home_outlined, label: 'Home'),
    _DockItem(icon: Icons.calendar_month_rounded, outlinedIcon: Icons.calendar_month_outlined, label: 'Calendar'),
    _DockItem(icon: Icons.forum_rounded, outlinedIcon: Icons.forum_outlined, label: 'Community'),
    _DockItem(icon: Icons.folder_rounded, outlinedIcon: Icons.folder_outlined, label: 'Resources'),
    _DockItem(icon: Icons.person_rounded, outlinedIcon: Icons.person_outline_rounded, label: 'Profile'),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bottom = MediaQuery.paddingOf(context).bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(16, 0, 16, (bottom + 10).clamp(14.0, 36.0)),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
          child: Container(
            height: 64,
            decoration: BoxDecoration(
              color: isDark
                  ? const Color(0xFF0C0C0E).withValues(alpha: 0.85)
                  : Colors.white.withValues(alpha: 0.88),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(
                color: isDark
                    ? AppColors.primary.withValues(alpha: 0.18)
                    : AppColors.border.withValues(alpha: 0.6),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: isDark
                      ? AppColors.primary.withValues(alpha: 0.08)
                      : Colors.black.withValues(alpha: 0.08),
                  blurRadius: 24,
                  spreadRadius: 0,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(_items.length, (i) {
                final item = _items[i];
                final isSelected = currentIndex == i;
                return _DockButton(
                  item: item,
                  isSelected: isSelected,
                  isDark: isDark,
                  onTap: () => onTap(i),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}

class _DockButton extends StatelessWidget {
  const _DockButton({
    required this.item,
    required this.isSelected,
    required this.isDark,
    required this.onTap,
  });

  final _DockItem item;
  final bool isSelected;
  final bool isDark;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 60,
        height: 64,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOutCubic,
              width: isSelected ? 44 : 36,
              height: isSelected ? 32 : 28,
              decoration: isSelected
                  ? BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.3),
                          blurRadius: 10,
                          spreadRadius: 0,
                        ),
                      ],
                    )
                  : null,
              child: Center(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 180),
                  child: Icon(
                    isSelected ? item.icon : item.outlinedIcon,
                    key: ValueKey(isSelected),
                    size: isSelected ? 22 : 20,
                    color: isSelected
                        ? AppColors.primary
                        : (isDark ? AppColors.darkTextSecondary : AppColors.textSecondary),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 3),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 180),
              style: TextStyle(
                fontSize: isSelected ? 10 : 9.5,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected
                    ? AppColors.primary
                    : (isDark ? AppColors.darkTextSecondary : AppColors.textSecondary),
              ),
              child: Text(item.label),
            ),
          ],
        ),
      ),
    );
  }
}

class _DockItem {
  const _DockItem({
    required this.icon,
    required this.outlinedIcon,
    required this.label,
  });
  final IconData icon;
  final IconData outlinedIcon;
  final String label;
}

// ── Wide-Screen Navigation Rail ───────────────────────────────────────────────

class _WideRail extends StatelessWidget {
  const _WideRail({required this.selectedIndex, required this.onSelect});
  final int selectedIndex;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    return NavigationRail(
      selectedIndex: selectedIndex,
      onDestinationSelected: onSelect,
      labelType: NavigationRailLabelType.all,
      selectedIconTheme: const IconThemeData(color: AppColors.primary),
      selectedLabelTextStyle: const TextStyle(
        color: AppColors.primary,
        fontWeight: FontWeight.bold,
      ),
      destinations: const [
        NavigationRailDestination(
          icon: Icon(Icons.home_outlined),
          selectedIcon: Icon(Icons.home_rounded),
          label: Text('Home'),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.calendar_month_outlined),
          selectedIcon: Icon(Icons.calendar_month_rounded),
          label: Text('Calendar'),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.forum_outlined),
          selectedIcon: Icon(Icons.forum_rounded),
          label: Text('Community'),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.folder_outlined),
          selectedIcon: Icon(Icons.folder_rounded),
          label: Text('Resources'),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.person_outline_rounded),
          selectedIcon: Icon(Icons.person_rounded),
          label: Text('Profile'),
        ),
      ],
    );
  }
}
