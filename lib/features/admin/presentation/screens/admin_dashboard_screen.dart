import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../admin_provider.dart';

/// Elite Executive Mission Control & Command Center for ScholarSync App Owner.
class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final admin = context.watch<AdminProvider>();
    final analytics = admin.analytics;

    return RefreshIndicator(
      onRefresh: () => admin.loadAllAdminData(),
      color: AppColors.primary,
      backgroundColor: const Color(0xFF141418),
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        children: [
          // ── 1. Hero Executive Command Header ─────────────────────────────
          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  Color(0xFF0F172A),
                  Color(0xFF070B14),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(AppDimensions.radiusXl),
              border: Border.all(color: AppColors.primary.withValues(alpha: 0.35), width: 1.2),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.08),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.success.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppColors.success.withValues(alpha: 0.4)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 7,
                            height: 7,
                            decoration: const BoxDecoration(
                              color: AppColors.success,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          const Text(
                            'SYSTEM OPERATIONAL',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              color: AppColors.success,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.06),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'Postgres 17 • Active',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.primary.withValues(alpha: 0.4)),
                      ),
                      child: const Icon(Icons.shield_rounded, size: 20, color: AppColors.primary),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  'ScholarSync Mission Control',
                  style: textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Master DBA dashboard to govern colleges, syllabus database, student moderation queue, and dispatch platform push broadcasts.',
                  style: textTheme.bodySmall?.copyWith(
                    color: const Color(0xFF94A3B8),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // ── 2. Live Platform KPIs ─────────────────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Live Platform KPIs',
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.2,
                ),
              ),
              if (analytics.pendingReports > 0 || analytics.pendingNotes > 0)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.warning.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.warning.withValues(alpha: 0.4)),
                  ),
                  child: Text(
                    '${analytics.pendingReports + analytics.pendingNotes} PENDING ACTIONS',
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      color: AppColors.warning,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 14),

          // 6-Card KPI Grid
          LayoutBuilder(
            builder: (context, constraints) {
              final crossAxisCount = constraints.maxWidth >= 600 ? 3 : 2;
              return GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: constraints.maxWidth >= 600 ? 1.35 : 1.15,
                children: [
                  _EliteStatCard(
                    title: 'Total Students',
                    value: '${analytics.totalStudents}',
                    subtitle: '${analytics.activeStudents} active',
                    icon: Icons.people_alt_rounded,
                    gradientColors: const [Color(0xFF0284C7), Color(0xFF0369A1)],
                    accentColor: const Color(0xFF38BDF8),
                    onTap: () => context.go('/admin/students'),
                  ),
                  _EliteStatCard(
                    title: 'Curriculum Subjects',
                    value: '${analytics.totalSubjects}',
                    subtitle: 'Semesters 1–8',
                    icon: Icons.menu_book_rounded,
                    gradientColors: const [Color(0xFF4F46E5), Color(0xFF3730A3)],
                    accentColor: const Color(0xFF818CF8),
                    onTap: () => context.go('/admin/subjects'),
                  ),
                  _EliteStatCard(
                    title: 'Supported Colleges',
                    value: '${analytics.totalColleges}',
                    subtitle: 'Partner Campuses',
                    icon: Icons.account_balance_rounded,
                    gradientColors: const [Color(0xFFD97706), Color(0xFFB45309)],
                    accentColor: const Color(0xFFFBBF24),
                    onTap: () => context.go('/admin/colleges'),
                  ),
                  _EliteStatCard(
                    title: 'Notes in Queue',
                    value: '${analytics.pendingNotes}',
                    subtitle: analytics.pendingNotes > 0 ? 'Requires Review' : 'Up to Date',
                    icon: Icons.folder_open_rounded,
                    gradientColors: analytics.pendingNotes > 0
                        ? const [Color(0xFFEA580C), Color(0xFFC2410C)]
                        : const [Color(0xFF1E293B), Color(0xFF0F172A)],
                    accentColor: analytics.pendingNotes > 0 ? const Color(0xFFFB923C) : const Color(0xFF94A3B8),
                    onTap: () => context.go('/admin/notes'),
                  ),
                  _EliteStatCard(
                    title: 'Moderation Tickets',
                    value: '${analytics.pendingReports}',
                    subtitle: analytics.pendingReports > 0 ? 'Action Needed' : 'Zero Violations',
                    icon: Icons.gavel_rounded,
                    gradientColors: analytics.pendingReports > 0
                        ? const [Color(0xFFDC2626), Color(0xFF991B1B)]
                        : const [Color(0xFF1E293B), Color(0xFF0F172A)],
                    accentColor: analytics.pendingReports > 0 ? const Color(0xFFF87171) : const Color(0xFF94A3B8),
                    onTap: () => context.go('/admin/moderation'),
                  ),
                  _EliteStatCard(
                    title: 'App Broadcasts',
                    value: '${analytics.totalAnnouncements}',
                    subtitle: 'FCM Push Alerts',
                    icon: Icons.campaign_rounded,
                    gradientColors: const [Color(0xFF059669), Color(0xFF047857)],
                    accentColor: const Color(0xFF34D399),
                    onTap: () => context.go('/admin/announcements'),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 28),

          // ── 3. Quick Action Launchpad ─────────────────────────────────────
          Text(
            'Quick Action Launchpad',
            style: textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              letterSpacing: -0.2,
            ),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _QuickActionChip(
                icon: Icons.add_circle_outline_rounded,
                label: 'Add Subject',
                color: AppColors.secondary,
                onTap: () => context.go('/admin/subjects'),
              ),
              _QuickActionChip(
                icon: Icons.campaign_rounded,
                label: 'Send Broadcast',
                color: AppColors.primary,
                onTap: () => context.go('/admin/announcements'),
              ),
              _QuickActionChip(
                icon: Icons.folder_shared_outlined,
                label: 'Review Notes Queue',
                color: AppColors.warning,
                badgeCount: analytics.pendingNotes,
                onTap: () => context.go('/admin/notes'),
              ),
              _QuickActionChip(
                icon: Icons.gavel_rounded,
                label: 'Moderation Center',
                color: AppColors.error,
                badgeCount: analytics.pendingReports,
                onTap: () => context.go('/admin/moderation'),
              ),
              _QuickActionChip(
                icon: Icons.forum_rounded,
                label: 'Chat Rooms',
                color: const Color(0xFF38BDF8),
                onTap: () => context.go('/admin/chat'),
              ),
              _QuickActionChip(
                icon: Icons.calendar_month_rounded,
                label: 'Calendar & Exams',
                color: const Color(0xFF818CF8),
                onTap: () => context.go('/admin/calendar'),
              ),
              _QuickActionChip(
                icon: Icons.event_available_rounded,
                label: 'Campus Events',
                color: const Color(0xFF10B981),
                onTap: () => context.go('/admin/events'),
              ),
              _QuickActionChip(
                icon: Icons.storefront_rounded,
                label: 'Marketplace',
                color: const Color(0xFF34D399),
                onTap: () => context.go('/admin/marketplace'),
              ),
              _QuickActionChip(
                icon: Icons.groups_2_rounded,
                label: 'Student Clubs',
                color: const Color(0xFFFBBF24),
                onTap: () => context.go('/admin/clubs'),
              ),
              _QuickActionChip(
                icon: Icons.dynamic_feed_rounded,
                label: 'Community Forum',
                color: const Color(0xFFFB923C),
                onTap: () => context.go('/admin/community'),
              ),
              _QuickActionChip(
                icon: Icons.badge_rounded,
                label: 'Student Directory',
                color: AppColors.info,
                onTap: () => context.go('/admin/students'),
              ),
            ],
          ),
          const SizedBox(height: 28),

          // ── 4. Branch Distribution Chart ─────────────────────────────────
          if (analytics.studentsByBranch.isNotEmpty) ...[
            Text(
              'Student Enrollment by Branch',
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                letterSpacing: -0.2,
              ),
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: const Color(0xFF0F1218),
                borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
                border: Border.all(color: const Color(0xFF27272A)),
              ),
              child: Column(
                children: analytics.studentsByBranch.entries.map((entry) {
                  final percent = analytics.totalStudents > 0
                      ? (entry.value / analytics.totalStudents)
                      : 0.0;
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 7),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                entry.key,
                                style: textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '${entry.value} students (${(percent * 100).toStringAsFixed(1)}%)',
                              style: textTheme.labelSmall?.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: LinearProgressIndicator(
                            value: percent,
                            minHeight: 6,
                            backgroundColor: const Color(0xFF1E2430),
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 28),
          ],

          // ── 5. Real-Time Student Signup Stream ────────────────────────────
          Text(
            'Recent Student Signups Pulse',
            style: textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              letterSpacing: -0.2,
            ),
          ),
          const SizedBox(height: 14),
          if (analytics.recentRegistrations.isEmpty)
            Container(
              padding: const EdgeInsets.all(28),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: const Color(0xFF0F1218),
                borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
                border: Border.all(color: const Color(0xFF27272A)),
              ),
              child: Text(
                'No registered students found yet.',
                style: textTheme.bodyMedium?.copyWith(color: const Color(0xFF94A3B8)),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: analytics.recentRegistrations.length,
              separatorBuilder: (context, index) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final student = analytics.recentRegistrations[index];
                final isAdmin = student.role.isAdmin;

                return Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F1218),
                    borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
                    border: Border.all(
                      color: isAdmin
                          ? AppColors.primary.withValues(alpha: 0.3)
                          : const Color(0xFF27272A),
                    ),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 20,
                        backgroundColor: isAdmin
                            ? AppColors.primary.withValues(alpha: 0.2)
                            : const Color(0xFF1E2430),
                        child: Text(
                          student.fullName.isNotEmpty ? student.fullName[0].toUpperCase() : 'S',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: isAdmin ? AppColors.primary : Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              student.fullName,
                              style: textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${student.branch ?? "Branch unset"} • Sem ${student.semester ?? "-"}',
                              style: textTheme.bodySmall?.copyWith(color: const Color(0xFF94A3B8)),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: (isAdmin ? AppColors.primary : const Color(0xFF38BDF8))
                              .withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: (isAdmin ? AppColors.primary : const Color(0xFF38BDF8))
                                .withValues(alpha: 0.3),
                          ),
                        ),
                        child: Text(
                          student.role.displayName.toUpperCase(),
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: isAdmin ? AppColors.primary : const Color(0xFF38BDF8),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}

class _EliteStatCard extends StatelessWidget {
  const _EliteStatCard({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.gradientColors,
    required this.accentColor,
    required this.onTap,
  });

  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final List<Color> gradientColors;
  final Color accentColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFF0F1218),
            borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
            border: Border.all(color: const Color(0xFF27272A), width: 1.0),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.all(7),
                    decoration: BoxDecoration(
                      color: accentColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: accentColor.withValues(alpha: 0.3)),
                    ),
                    child: Icon(icon, size: 18, color: accentColor),
                  ),
                  const Icon(Icons.arrow_forward_ios_rounded, size: 11, color: Color(0xFF64748B)),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    value,
                    style: textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    title,
                    style: textTheme.bodySmall?.copyWith(
                      color: const Color(0xFF94A3B8),
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuickActionChip extends StatelessWidget {
  const _QuickActionChip({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
    this.badgeCount,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  final int? badgeCount;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(30),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: color.withValues(alpha: 0.35)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              if (badgeCount != null && badgeCount! > 0) ...[
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '$badgeCount',
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
