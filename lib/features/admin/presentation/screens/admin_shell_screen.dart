import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../profile/presentation/profile_provider.dart';
import '../admin_provider.dart';

/// Responsive Application Owner & Master Admin console shell for ScholarSync.
class AdminShellScreen extends StatefulWidget {
  const AdminShellScreen({
    super.key,
    required this.child,
    required this.currentPath,
  });

  final Widget child;
  final String currentPath;

  @override
  State<AdminShellScreen> createState() => _AdminShellScreenState();
}

class _AdminShellScreenState extends State<AdminShellScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminProvider>().loadAllAdminData();
    });
  }

  int _calculateSelectedIndex(String path) {
    if (path.startsWith('/admin/subjects')) return 1;
    if (path.startsWith('/admin/colleges')) return 2;
    if (path.startsWith('/admin/notes')) return 3;
    if (path.startsWith('/admin/moderation')) return 4;
    if (path.startsWith('/admin/chat')) return 5;
    if (path.startsWith('/admin/calendar')) return 6;
    if (path.startsWith('/admin/events')) return 7;
    if (path.startsWith('/admin/marketplace')) return 8;
    if (path.startsWith('/admin/clubs')) return 9;
    if (path.startsWith('/admin/community')) return 10;
    if (path.startsWith('/admin/announcements')) return 11;
    if (path.startsWith('/admin/students')) return 12;
    return 0;
  }

  void _onDestinationSelected(int index) {
    switch (index) {
      case 0:
        context.go('/admin');
        break;
      case 1:
        context.go('/admin/subjects');
        break;
      case 2:
        context.go('/admin/colleges');
        break;
      case 3:
        context.go('/admin/notes');
        break;
      case 4:
        context.go('/admin/moderation');
        break;
      case 5:
        context.go('/admin/chat');
        break;
      case 6:
        context.go('/admin/calendar');
        break;
      case 7:
        context.go('/admin/events');
        break;
      case 8:
        context.go('/admin/marketplace');
        break;
      case 9:
        context.go('/admin/clubs');
        break;
      case 10:
        context.go('/admin/community');
        break;
      case 11:
        context.go('/admin/announcements');
        break;
      case 12:
        context.go('/admin/students');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final profile = context.watch<ProfileProvider>().profile;
    final admin = context.watch<AdminProvider>();
    final selectedIndex = _calculateSelectedIndex(widget.currentPath);

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWideScreen = constraints.maxWidth >= 800;

        if (isWideScreen) {
          // Desktop / Tablet Layout with Left Navigation Rail
          return Scaffold(
            backgroundColor: colorScheme.surface,
            body: Row(
              children: [
                NavigationRail(
                  selectedIndex: selectedIndex,
                  onDestinationSelected: _onDestinationSelected,
                  backgroundColor: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                  extended: constraints.maxWidth >= 1100,
                  minExtendedWidth: 220,
                  leading: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
                          ),
                          child: const Icon(Icons.shield_rounded, size: 20, color: AppColors.textPrimary),
                        ),
                        if (constraints.maxWidth >= 1100) ...[
                          const SizedBox(width: 10),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'ScholarSync',
                                style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppColors.secondary.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  'MASTER ADMIN',
                                  style: textTheme.labelSmall?.copyWith(
                                    fontSize: 9,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.secondary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                  trailing: Expanded(
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 20),
                        child: IconButton.outlined(
                          tooltip: 'Switch to Student View',
                          icon: const Icon(Icons.exit_to_app_rounded),
                          onPressed: () => context.go('/home'),
                        ),
                      ),
                    ),
                  ),
                  destinations: [
                    const NavigationRailDestination(
                      icon: Icon(Icons.dashboard_outlined),
                      selectedIcon: Icon(Icons.dashboard_rounded),
                      label: Text('Overview'),
                    ),
                    const NavigationRailDestination(
                      icon: Icon(Icons.menu_book_outlined),
                      selectedIcon: Icon(Icons.menu_book_rounded),
                      label: Text('Curriculum'),
                    ),
                    const NavigationRailDestination(
                      icon: Icon(Icons.account_balance_outlined),
                      selectedIcon: Icon(Icons.account_balance_rounded),
                      label: Text('Colleges'),
                    ),
                    NavigationRailDestination(
                      icon: Badge(
                        isLabelVisible: admin.analytics.pendingNotes > 0,
                        label: Text('${admin.analytics.pendingNotes}'),
                        child: const Icon(Icons.folder_open_outlined),
                      ),
                      selectedIcon: const Icon(Icons.folder_rounded),
                      label: const Text('Study Notes'),
                    ),
                    NavigationRailDestination(
                      icon: Badge(
                        isLabelVisible: admin.analytics.pendingReports > 0,
                        label: Text('${admin.analytics.pendingReports}'),
                        child: const Icon(Icons.gavel_outlined),
                      ),
                      selectedIcon: const Icon(Icons.gavel_rounded),
                      label: const Text('Moderation'),
                    ),
                    const NavigationRailDestination(
                      icon: Icon(Icons.forum_outlined),
                      selectedIcon: Icon(Icons.forum_rounded),
                      label: Text('Chat Rooms'),
                    ),
                    const NavigationRailDestination(
                      icon: Icon(Icons.calendar_month_outlined),
                      selectedIcon: Icon(Icons.calendar_month_rounded),
                      label: Text('Calendar'),
                    ),
                    const NavigationRailDestination(
                      icon: Icon(Icons.event_available_outlined),
                      selectedIcon: Icon(Icons.event_available_rounded),
                      label: Text('Events'),
                    ),
                    const NavigationRailDestination(
                      icon: Icon(Icons.storefront_outlined),
                      selectedIcon: Icon(Icons.storefront_rounded),
                      label: Text('Marketplace'),
                    ),
                    const NavigationRailDestination(
                      icon: Icon(Icons.groups_2_outlined),
                      selectedIcon: Icon(Icons.groups_2_rounded),
                      label: Text('Clubs'),
                    ),
                    const NavigationRailDestination(
                      icon: Icon(Icons.dynamic_feed_outlined),
                      selectedIcon: Icon(Icons.dynamic_feed_rounded),
                      label: Text('Community'),
                    ),
                    const NavigationRailDestination(
                      icon: Icon(Icons.campaign_outlined),
                      selectedIcon: Icon(Icons.campaign_rounded),
                      label: Text('Broadcasts'),
                    ),
                    const NavigationRailDestination(
                      icon: Icon(Icons.people_outline_rounded),
                      selectedIcon: Icon(Icons.people_rounded),
                      label: Text('Students'),
                    ),
                  ],
                ),
                const VerticalDivider(thickness: 1, width: 1),
                Expanded(child: widget.child),
              ],
            ),
          );
        }

        // Mobile Layout with Top AppBar & Drawer + Bottom Navigation
        return Scaffold(
          backgroundColor: colorScheme.surface,
          appBar: AppBar(
            backgroundColor: colorScheme.surface,
            elevation: 0,
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
                  ),
                  child: const Icon(Icons.shield_rounded, size: 18, color: AppColors.textPrimary),
                ),
                const SizedBox(width: 8),
                Text(
                  'ScholarSync Admin',
                  style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            actions: [
              TextButton.icon(
                icon: const Icon(Icons.arrow_back_rounded, size: 16),
                label: const Text('Student View'),
                style: TextButton.styleFrom(
                  foregroundColor: colorScheme.primary,
                  textStyle: textTheme.labelMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                onPressed: () => context.go('/home'),
              ),
              const SizedBox(width: 8),
            ],
          ),
          drawer: Drawer(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                UserAccountsDrawerHeader(
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest,
                  ),
                  accountName: Text(
                    profile?.fullName ?? 'App Owner',
                    style: textTheme.titleMedium?.copyWith(
                      color: colorScheme.onSurface,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  accountEmail: Text(
                    profile?.email ?? 'admin@scholarsync.com',
                    style: textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
                  ),
                  currentAccountPicture: CircleAvatar(
                    backgroundColor: AppColors.primary,
                    child: Text(
                      (profile?.fullName.isNotEmpty ?? false) ? profile!.fullName[0].toUpperCase() : 'A',
                      style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                    ),
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.dashboard_rounded),
                  title: const Text('Mission Control Overview'),
                  selected: selectedIndex == 0,
                  onTap: () {
                    Navigator.pop(context);
                    context.go('/admin');
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.menu_book_rounded),
                  title: const Text('Curriculum & Subjects'),
                  selected: selectedIndex == 1,
                  onTap: () {
                    Navigator.pop(context);
                    context.go('/admin/subjects');
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.account_balance_rounded),
                  title: const Text('Supported Colleges'),
                  selected: selectedIndex == 2,
                  onTap: () {
                    Navigator.pop(context);
                    context.go('/admin/colleges');
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.folder_open_rounded),
                  title: const Text('Notes & Study Material Queue'),
                  selected: selectedIndex == 3,
                  trailing: admin.analytics.pendingNotes > 0
                      ? Badge.count(count: admin.analytics.pendingNotes)
                      : null,
                  onTap: () {
                    Navigator.pop(context);
                    context.go('/admin/notes');
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.gavel_rounded),
                  title: const Text('Unified Moderation Center'),
                  selected: selectedIndex == 4,
                  trailing: admin.analytics.pendingReports > 0
                      ? Badge.count(count: admin.analytics.pendingReports)
                      : null,
                  onTap: () {
                    Navigator.pop(context);
                    context.go('/admin/moderation');
                  },
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.forum_rounded, color: AppColors.secondary),
                  title: const Text('Chat Management Studio'),
                  selected: selectedIndex == 5,
                  onTap: () {
                    Navigator.pop(context);
                    context.go('/admin/chat');
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.calendar_month_rounded, color: AppColors.primary),
                  title: const Text('Academic Calendar & Dates'),
                  selected: selectedIndex == 6,
                  onTap: () {
                    Navigator.pop(context);
                    context.go('/admin/calendar');
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.event_available_rounded, color: Color(0xFF818CF8)),
                  title: const Text('Campus Events & Hackathons'),
                  selected: selectedIndex == 7,
                  onTap: () {
                    Navigator.pop(context);
                    context.go('/admin/events');
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.storefront_rounded, color: Color(0xFF34D399)),
                  title: const Text('Marketplace Oversight'),
                  selected: selectedIndex == 8,
                  onTap: () {
                    Navigator.pop(context);
                    context.go('/admin/marketplace');
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.groups_2_rounded, color: Color(0xFFFBBF24)),
                  title: const Text('Student Clubs & Societies'),
                  selected: selectedIndex == 9,
                  onTap: () {
                    Navigator.pop(context);
                    context.go('/admin/clubs');
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.dynamic_feed_rounded, color: Color(0xFFFB923C)),
                  title: const Text('Community Forum & Q&A'),
                  selected: selectedIndex == 10,
                  onTap: () {
                    Navigator.pop(context);
                    context.go('/admin/community');
                  },
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.campaign_rounded),
                  title: const Text('Push Broadcast Alerts'),
                  selected: selectedIndex == 11,
                  onTap: () {
                    Navigator.pop(context);
                    context.go('/admin/announcements');
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.people_rounded),
                  title: const Text('Student Directory'),
                  selected: selectedIndex == 12,
                  onTap: () {
                    Navigator.pop(context);
                    context.go('/admin/students');
                  },
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.exit_to_app_rounded, color: AppColors.primary),
                  title: const Text('Switch to Student View'),
                  onTap: () {
                    Navigator.pop(context);
                    context.go('/home');
                  },
                ),
              ],
            ),
          ),
          body: widget.child,
          bottomNavigationBar: NavigationBar(
            selectedIndex: selectedIndex > 4 ? 0 : selectedIndex,
            onDestinationSelected: _onDestinationSelected,
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.dashboard_outlined),
                selectedIcon: Icon(Icons.dashboard_rounded),
                label: 'Overview',
              ),
              NavigationDestination(
                icon: Icon(Icons.menu_book_outlined),
                selectedIcon: Icon(Icons.menu_book_rounded),
                label: 'Curriculum',
              ),
              NavigationDestination(
                icon: Icon(Icons.account_balance_outlined),
                selectedIcon: Icon(Icons.account_balance_rounded),
                label: 'Colleges',
              ),
              NavigationDestination(
                icon: Icon(Icons.folder_open_outlined),
                selectedIcon: Icon(Icons.folder_rounded),
                label: 'Notes',
              ),
              NavigationDestination(
                icon: Icon(Icons.gavel_outlined),
                selectedIcon: Icon(Icons.gavel_rounded),
                label: 'Moderate',
              ),
            ],
          ),
        );
      },
    );
  }
}
