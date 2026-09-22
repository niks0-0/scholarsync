import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../../core/routing/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../attendance/presentation/attendance_provider.dart';
import '../../../auth/auth_provider.dart';
import '../../../dashboard/presentation/widgets/greeting_header_card.dart';
import '../../../attendance/presentation/widgets/smart_insights_sheet.dart';
import '../../../leaderboard/domain/models/leaderboard_models.dart';
import '../../../leaderboard/presentation/leaderboard_provider.dart';

/// ScholarSync Home — Focus Wheel radial nav + Bento Grid tiles.
/// Phone-first. AMOLED-optimized. Student-autonomous.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = context.read<AuthProvider>().currentUser;
      if (user != null) {
        context.read<AttendanceProvider>().loadAttendance(user.uid);
      }
    });
  }

  void _openInsights() {
    HapticFeedback.mediumImpact();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => SmartInsightsSheet(
        subjects: context.read<AttendanceProvider>().subjects,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final attendance = context.watch<AttendanceProvider>();
    final bg = isDark ? AppColors.darkBackground : AppColors.background;

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            final user = context.read<AuthProvider>().currentUser;
            if (user != null) {
              await context.read<AttendanceProvider>().loadAttendance(user.uid);
            }
          },
          color: AppColors.primary,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              // ── Greeting Header ───────────────────────────────────────────
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(16, 8, 16, 0),
                  child: GreetingHeaderCard(),
                ),
              ),

              // ── Focus Hero Carousel (Rotating Card Cycle) ────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: _FocusCardCarousel(
                    attendance: attendance,
                    onOpenInsights: _openInsights,
                    isDark: isDark,
                  ),
                ),
              ),

              // ── Section Label ─────────────────────────────────────────────
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
                sliver: SliverToBoxAdapter(
                  child: Row(
                    children: [
                      Text(
                        'Overview',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w800,
                              color: isDark
                                  ? AppColors.darkTextSecondary
                                  : AppColors.textSecondary,
                              letterSpacing: 0.6,
                              fontSize: 11,
                            ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Divider(
                          color: isDark
                              ? AppColors.darkBorder
                              : AppColors.border,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // ── Bento Grid ────────────────────────────────────────────────
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                sliver: SliverToBoxAdapter(
                  child: _BentoGrid(
                    attendance: attendance,
                    isDark: isDark,
                    onOpenInsights: _openInsights,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Focus Card Carousel (Swipeable 3D Deck) ──────────────────────────────────

class _FocusCardCarousel extends StatefulWidget {
  const _FocusCardCarousel({
    required this.attendance,
    required this.onOpenInsights,
    required this.isDark,
  });

  final AttendanceProvider attendance;
  final VoidCallback onOpenInsights;
  final bool isDark;

  @override
  State<_FocusCardCarousel> createState() => _FocusCardCarouselState();
}

class _FocusCardCarouselState extends State<_FocusCardCarousel> {
  late final PageController _pageController;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.90);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Color get _attendanceColor {
    final pct = widget.attendance.overallPercentage;
    if (pct >= 75) return AppColors.success;
    if (pct >= 60) return AppColors.warning;
    return AppColors.error;
  }

  String get _attendanceStatus {
    final pct = widget.attendance.overallPercentage;
    if (pct >= 75) return 'On Track';
    if (pct >= 60) return 'Needs Attention';
    return 'Critical';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDark;
    final leaderboard = context.watch<LeaderboardProvider>();
    final myRank = leaderboard.currentUserEntry;
    final top1 = leaderboard.entries.isNotEmpty ? leaderboard.entries.first : null;

    final cards = [
      // ── Card 1: Attendance & Smart Insights ───────────────────────────────
      _buildAttendanceCard(context, isDark),

      // ── Card 2: Today's Timetable & Schedule ──────────────────────────────
      _buildTimetableCard(context, isDark),

      // ── Card 3: Academic Leaderboard & Streaks ────────────────────────────
      _buildLeaderboardCard(context, isDark, myRank, top1),

      // ── Card 4: Study Notes & PYQs ────────────────────────────────────────
      _buildNotesCard(context, isDark),

      // ── Card 5: Campus Community Lounge ───────────────────────────────────
      _buildCommunityCard(context, isDark),
    ];

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: 184,
          child: PageView.builder(
            controller: _pageController,
            itemCount: cards.length,
            onPageChanged: (index) {
              HapticFeedback.selectionClick();
              setState(() => _currentPage = index);
            },
            itemBuilder: (context, index) {
              return AnimatedBuilder(
                animation: _pageController,
                builder: (context, child) {
                  double scale = 1.0;
                  double opacity = 1.0;
                  try {
                    if (_pageController.hasClients &&
                        _pageController.position.haveDimensions) {
                      final page =
                          _pageController.page ?? _currentPage.toDouble();
                      final diff = (page - index).abs();
                      scale = (1 - (diff * 0.08)).clamp(0.92, 1.0);
                      opacity = (1 - (diff * 0.3)).clamp(0.65, 1.0);
                    }
                  } catch (_) {}
                  return Transform.scale(
                    scale: scale,
                    child: Opacity(
                      opacity: opacity,
                      child: child,
                    ),
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: cards[index],
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 10),
        // ── Animated Smooth Dot Indicators ──────────────────────────────────
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(cards.length, (i) {
            final isSelected = _currentPage == i;
            return GestureDetector(
              onTap: () {
                _pageController.animateToPage(
                  i,
                  duration: const Duration(milliseconds: 320),
                  curve: Curves.easeOutCubic,
                );
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                margin: const EdgeInsets.symmetric(horizontal: 3),
                height: 5,
                width: isSelected ? 22 : 6,
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primary
                      : (isDark ? Colors.white24 : Colors.black12),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }

  // ── Card 1: Attendance & Smart Insights ───────────────────────────────────
  Widget _buildAttendanceCard(BuildContext context, bool isDark) {
    final pct = widget.attendance.overallPercentage;
    final total = widget.attendance.totalClasses;
    final attended = widget.attendance.totalAttended;
    final bunks = widget.attendance.subjects.fold<int>(0, (sum, s) => sum + s.safeBunksCount);
    final attColor = _attendanceColor;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => context.push(AppRoutes.attendance),
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDark
                  ? [
                      attColor.withValues(alpha: 0.18),
                      AppColors.darkSurface,
                    ]
                  : [
                      attColor.withValues(alpha: 0.12),
                      Colors.white,
                    ],
            ),
            border: Border.all(
              color: attColor.withValues(alpha: isDark ? 0.4 : 0.25),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: attColor.withValues(alpha: isDark ? 0.15 : 0.08),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              // Radial Gauge
              SizedBox(
                width: 82,
                height: 82,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    CircularProgressIndicator(
                      value: (pct / 100).clamp(0.0, 1.0),
                      strokeWidth: 8,
                      backgroundColor: attColor.withValues(alpha: 0.18),
                      valueColor: AlwaysStoppedAnimation<Color>(attColor),
                      strokeCap: StrokeCap.round,
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '${pct.toStringAsFixed(0)}%',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                            color: attColor,
                            letterSpacing: -0.5,
                          ),
                        ),
                        Text(
                          'ATT',
                          style: TextStyle(
                            fontSize: 8.5,
                            fontWeight: FontWeight.w800,
                            color: attColor.withValues(alpha: 0.85),
                            letterSpacing: 0.8,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              // Attendance Details & Quick Action
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: attColor.withValues(alpha: 0.16),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            _attendanceStatus,
                            style: TextStyle(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w800,
                              color: attColor,
                            ),
                          ),
                        ),
                        const Spacer(),
                        InkWell(
                          onTap: widget.onOpenInsights,
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  AppColors.primary,
                                  AppColors.accent,
                                ],
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.bolt_rounded,
                                    size: 13, color: Colors.white),
                                SizedBox(width: 3),
                                Text(
                                  'Insights',
                                  style: TextStyle(
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '$attended of $total classes attended',
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                        color: isDark ? Colors.white : AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      bunks > 0
                          ? '🎉 $bunks safe bunks remaining'
                          : (widget.attendance.atRiskCount > 0
                              ? '⚠️ ${widget.attendance.atRiskCount} subject(s) below target'
                              : '🎯 Attendance right on target'),
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: bunks > 0
                            ? AppColors.success
                            : (widget.attendance.atRiskCount > 0
                                ? AppColors.error
                                : (isDark
                                    ? AppColors.darkTextSecondary
                                    : AppColors.textSecondary)),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Text(
                          'View detailed breakdown',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(
                          Icons.arrow_forward_rounded,
                          size: 13,
                          color: AppColors.primary,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Card 2: Today's Timetable & Schedule ──────────────────────────────────
  Widget _buildTimetableCard(BuildContext context, bool isDark) {
    const amber = Color(0xFFF59E0B);
    final now = DateTime.now();
    final dayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final currentDay = dayNames[now.weekday - 1];

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => context.push(AppRoutes.timetable),
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDark
                  ? [
                      amber.withValues(alpha: 0.18),
                      AppColors.darkSurface,
                    ]
                  : [
                      amber.withValues(alpha: 0.12),
                      Colors.white,
                    ],
            ),
            border: Border.all(
              color: amber.withValues(alpha: isDark ? 0.4 : 0.25),
              width: 1.5,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: amber.withValues(alpha: 0.18),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.schedule_rounded,
                  color: amber,
                  size: 32,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: amber.withValues(alpha: 0.16),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '$currentDay Schedule',
                            style: const TextStyle(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w800,
                              color: amber,
                            ),
                          ),
                        ),
                        const Spacer(),
                        const Text(
                          'Live Timetable',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: amber,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Manage classes & slots',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: isDark ? Colors.white : AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Autonomous slot planner & cancellation alerts',
                      style: TextStyle(
                        fontSize: 11,
                        color: isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.textSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    const Row(
                      children: [
                        Text(
                          'Open weekly calendar',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: amber,
                          ),
                        ),
                        SizedBox(width: 4),
                        Icon(
                          Icons.arrow_forward_rounded,
                          size: 13,
                          color: amber,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Card 3: Academic Leaderboard & Streaks ─────────────────────────────────
  Widget _buildLeaderboardCard(
    BuildContext context,
    bool isDark,
    LeaderboardEntry? myRank,
    LeaderboardEntry? top1,
  ) {
    const gold = Color(0xFFEAB308);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => context.push(AppRoutes.leaderboard),
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDark
                  ? [
                      gold.withValues(alpha: 0.18),
                      AppColors.darkSurface,
                    ]
                  : [
                      gold.withValues(alpha: 0.12),
                      Colors.white,
                    ],
            ),
            border: Border.all(
              color: gold.withValues(alpha: isDark ? 0.4 : 0.25),
              width: 1.5,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: gold.withValues(alpha: 0.18),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.emoji_events_rounded,
                  color: gold,
                  size: 32,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: gold.withValues(alpha: 0.16),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            myRank != null ? 'Rank #${myRank.rank}' : 'Campus Ranks',
                            style: const TextStyle(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w800,
                              color: gold,
                            ),
                          ),
                        ),
                        const Spacer(),
                        Row(
                          children: [
                            const Icon(Icons.local_fire_department_rounded,
                                size: 14, color: AppColors.error),
                            const SizedBox(width: 2),
                            Text(
                              '${myRank?.streakDays ?? 1}d Streak',
                              style: const TextStyle(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w800,
                                color: AppColors.error,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      myRank != null
                          ? '${myRank.score} XP · ${myRank.badgeTitle}'
                          : 'Weekly Academic Podium',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: isDark ? Colors.white : AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      top1 != null
                          ? '🏆 #1 ${top1.displayName} (${top1.score} pts)'
                          : 'Compete for badges & weekly ranks',
                      style: TextStyle(
                        fontSize: 11,
                        color: isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.textSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    const Row(
                      children: [
                        Text(
                          'View podium & standings',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: gold,
                          ),
                        ),
                        SizedBox(width: 4),
                        Icon(
                          Icons.arrow_forward_rounded,
                          size: 13,
                          color: gold,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Card 4: Study Notes & PYQs ────────────────────────────────────────────
  Widget _buildNotesCard(BuildContext context, bool isDark) {
    const indigo = Color(0xFF818CF8);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => context.push(AppRoutes.resources),
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDark
                  ? [
                      indigo.withValues(alpha: 0.18),
                      AppColors.darkSurface,
                    ]
                  : [
                      indigo.withValues(alpha: 0.12),
                      Colors.white,
                    ],
            ),
            border: Border.all(
              color: indigo.withValues(alpha: isDark ? 0.4 : 0.25),
              width: 1.5,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: indigo.withValues(alpha: 0.18),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.menu_book_rounded,
                  color: indigo,
                  size: 32,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: indigo.withValues(alpha: 0.16),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            'Academic Vault',
                            style: TextStyle(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w800,
                              color: indigo,
                            ),
                          ),
                        ),
                        const Spacer(),
                        const Text(
                          'PDFs & Notes',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: indigo,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Notes, PYQs & Syllabi',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: isDark ? Colors.white : AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Exam prep materials & past year solutions',
                      style: TextStyle(
                        fontSize: 11,
                        color: isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.textSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    const Row(
                      children: [
                        Text(
                          'Browse study library',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: indigo,
                          ),
                        ),
                        SizedBox(width: 4),
                        Icon(
                          Icons.arrow_forward_rounded,
                          size: 13,
                          color: indigo,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Card 5: Campus Community Lounge ───────────────────────────────────────
  Widget _buildCommunityCard(BuildContext context, bool isDark) {
    const purple = Color(0xFFA855F7);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => context.push(AppRoutes.community),
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDark
                  ? [
                      purple.withValues(alpha: 0.18),
                      AppColors.darkSurface,
                    ]
                  : [
                      purple.withValues(alpha: 0.12),
                      Colors.white,
                    ],
            ),
            border: Border.all(
              color: purple.withValues(alpha: isDark ? 0.4 : 0.25),
              width: 1.5,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: purple.withValues(alpha: 0.18),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.forum_rounded,
                  color: purple,
                  size: 32,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: purple.withValues(alpha: 0.16),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            'Student Lounge',
                            style: TextStyle(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w800,
                              color: purple,
                            ),
                          ),
                        ),
                        const Spacer(),
                        const Text(
                          'Community',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: purple,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Peer Discussions & Queries',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: isDark ? Colors.white : AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Ask questions, share updates & collaborate',
                      style: TextStyle(
                        fontSize: 11,
                        color: isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.textSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    const Row(
                      children: [
                        Text(
                          'Enter student lounge',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: purple,
                          ),
                        ),
                        SizedBox(width: 4),
                        Icon(
                          Icons.arrow_forward_rounded,
                          size: 13,
                          color: purple,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


// ── Bento Grid ────────────────────────────────────────────────────────────────

class _BentoGrid extends StatelessWidget {
  const _BentoGrid({
    required this.attendance,
    required this.isDark,
    required this.onOpenInsights,
  });
  final AttendanceProvider attendance;
  final bool isDark;
  final VoidCallback onOpenInsights;

  Color get _statusColor {
    final pct = attendance.overallPercentage;
    if (pct >= 75) return AppColors.success;
    if (pct >= 60) return AppColors.warning;
    return AppColors.error;
  }

  String get _statusLabel {
    final pct = attendance.overallPercentage;
    if (pct >= 75) return 'SAFE';
    if (pct >= 60) return 'WARNING';
    return 'DANGER';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Dynamic Smart Attendance Warning / Safe Banner
        if (attendance.atRiskCount > 0) ...[
          InkWell(
            onTap: onOpenInsights,
            borderRadius: BorderRadius.circular(16),
            child: Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: isDark ? 0.15 : 0.10),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppColors.error.withValues(alpha: 0.4),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.error.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.warning_amber_rounded,
                      color: AppColors.error,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${attendance.atRiskCount} Subject${attendance.atRiskCount == 1 ? '' : 's'} At Risk',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: AppColors.error,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Tap to view recovery plan & next class impact',
                          style: TextStyle(
                            fontSize: 11,
                            color: isDark
                                ? AppColors.darkTextSecondary
                                : AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.bolt_rounded,
                    color: AppColors.error,
                    size: 20,
                  ),
                ],
              ),
            ),
          ),
        ],

        // Row 1: Large Attendance tile + Bunks tile
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Large Attendance Tile
            Expanded(
              flex: 3,
              child: _BentoTile(
                isDark: isDark,
                accentColor: _statusColor,
                height: 160,
                onTap: () => context.push(AppRoutes.attendance),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.verified_user_rounded,
                          color: _statusColor,
                          size: 18,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Attendance',
                          style: TextStyle(
                            color: _statusColor,
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 7, vertical: 2),
                          decoration: BoxDecoration(
                            color: _statusColor.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                                color: _statusColor.withValues(alpha: 0.4)),
                          ),
                          child: Text(
                            _statusLabel,
                            style: TextStyle(
                              color: _statusColor,
                              fontSize: 8,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.8,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    // Arc gauge
                    Center(
                      child: _AttendanceArc(
                        percentage: attendance.overallPercentage,
                        color: _statusColor,
                        size: 80,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _StatChip(
                          label: '${attendance.safeCount} Safe',
                          color: AppColors.success,
                          isDark: isDark,
                        ),
                        _StatChip(
                          label: '${attendance.atRiskCount} At Risk',
                          color: attendance.atRiskCount > 0
                              ? AppColors.error
                              : AppColors.darkTextSecondary,
                          isDark: isDark,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 10),
            // Right column: Bunks + Subjects count
            Expanded(
              flex: 2,
              child: Column(
                children: [
                  _BentoTile(
                    isDark: isDark,
                    accentColor: AppColors.warning,
                    height: 75,
                    onTap: () => context.push(AppRoutes.attendance),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.hotel_rounded,
                                color: AppColors.warning, size: 16),
                            const SizedBox(width: 4),
                            Text(
                              'Bunks Left',
                              style: TextStyle(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w700,
                                color: AppColors.warning,
                              ),
                            ),
                          ],
                        ),
                        const Spacer(),
                        Text(
                          _totalSafeBunks(attendance),
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w900,
                            color: AppColors.warning,
                            height: 1,
                          ),
                        ),
                        Text(
                          'classes',
                          style: TextStyle(
                            fontSize: 9,
                            color: AppColors.warning.withValues(alpha: 0.7),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  _BentoTile(
                    isDark: isDark,
                    accentColor: AppColors.secondary,
                    height: 75,
                    onTap: () => context.push(AppRoutes.attendance),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.book_rounded,
                                color: AppColors.secondary, size: 16),
                            const SizedBox(width: 4),
                            Text(
                              'Subjects',
                              style: TextStyle(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w700,
                                color: AppColors.secondary,
                              ),
                            ),
                          ],
                        ),
                        const Spacer(),
                        Text(
                          '${attendance.subjects.length}',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w900,
                            color: AppColors.secondary,
                            height: 1,
                          ),
                        ),
                        Text(
                          'tracked',
                          style: TextStyle(
                            fontSize: 9,
                            color: AppColors.secondary.withValues(alpha: 0.7),
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

        const SizedBox(height: 10),

        // Row 2: Leaderboard & Smart Insights
        Row(
          children: [
            Expanded(
              child: _BentoTile(
                isDark: isDark,
                accentColor: const Color(0xFFF59E0B),
                height: 90,
                onTap: () => context.push(AppRoutes.leaderboard),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.emoji_events_rounded,
                        color: Color(0xFFF59E0B), size: 22),
                    const Spacer(),
                    Text(
                      'Leaderboard',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 13,
                        color: isDark
                            ? AppColors.darkTextPrimary
                            : AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      'Ranks & Badges',
                      style: TextStyle(
                        fontSize: 10,
                        color: isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _BentoTile(
                isDark: isDark,
                accentColor: AppColors.primary,
                height: 90,
                onTap: onOpenInsights,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.bolt_rounded,
                        color: AppColors.primary, size: 22),
                    const Spacer(),
                    Text(
                      'Smart Insights',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 13,
                        color: isDark
                            ? AppColors.darkTextPrimary
                            : AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      'Offline Math Engine',
                      style: TextStyle(
                        fontSize: 10,
                        color: isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 10),

        // Row 3: Timetable + Resources
        Row(
          children: [
            Expanded(
              child: _BentoTile(
                isDark: isDark,
                accentColor: const Color(0xFF10B981),
                height: 90,
                onTap: () => context.push(AppRoutes.timetable),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.schedule_rounded,
                        color: Color(0xFF10B981), size: 22),
                    const Spacer(),
                    Text(
                      'Timetable',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 13,
                        color: isDark
                            ? AppColors.darkTextPrimary
                            : AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      'View schedule',
                      style: TextStyle(
                        fontSize: 10,
                        color: isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _BentoTile(
                isDark: isDark,
                accentColor: const Color(0xFF818CF8),
                height: 90,
                onTap: () => context.go(AppRoutes.resources),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.menu_book_rounded,
                        color: Color(0xFF818CF8), size: 22),
                    const Spacer(),
                    Text(
                      'Resources',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 13,
                        color: isDark
                            ? AppColors.darkTextPrimary
                            : AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      'Notes & materials',
                      style: TextStyle(
                        fontSize: 10,
                        color: isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 10),

        // Row 4: Community + Calendar
        Row(
          children: [
            Expanded(
              child: _BentoTile(
                isDark: isDark,
                accentColor: const Color(0xFFA855F7),
                height: 90,
                onTap: () => context.go(AppRoutes.community),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.forum_rounded,
                        color: Color(0xFFA855F7), size: 22),
                    const Spacer(),
                    Text(
                      'Community',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 13,
                        color: isDark
                            ? AppColors.darkTextPrimary
                            : AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      'Chat & connect',
                      style: TextStyle(
                        fontSize: 10,
                        color: isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _BentoTile(
                isDark: isDark,
                accentColor: const Color(0xFF38BDF8),
                height: 90,
                onTap: () => context.go(AppRoutes.calendar),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.event_rounded,
                        color: Color(0xFF38BDF8), size: 22),
                    const Spacer(),
                    Text(
                      'Calendar',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 13,
                        color: isDark
                            ? AppColors.darkTextPrimary
                            : AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      'Events & exams',
                      style: TextStyle(
                        fontSize: 10,
                        color: isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  String _totalSafeBunks(AttendanceProvider p) {
    final total = p.subjects.fold<int>(0, (s, sub) => s + sub.safeBunksCount);
    return '$total';
  }
}


// ── Bento Tile ────────────────────────────────────────────────────────────────

class _BentoTile extends StatefulWidget {
  const _BentoTile({
    required this.isDark,
    required this.accentColor,
    required this.height,
    required this.child,
    required this.onTap,
  });

  final bool isDark;
  final Color accentColor;
  final double height;
  final Widget child;
  final VoidCallback onTap;

  @override
  State<_BentoTile> createState() => _BentoTileState();
}

class _BentoTileState extends State<_BentoTile> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) {
        HapticFeedback.selectionClick();
        setState(() => _pressed = true);
      },
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.96 : 1.0,
        duration: const Duration(milliseconds: 120),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: widget.height,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: widget.isDark ? AppColors.darkSurface : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: _pressed
                  ? widget.accentColor.withValues(alpha: 0.5)
                  : (widget.isDark
                      ? widget.accentColor.withValues(alpha: 0.15)
                      : widget.accentColor.withValues(alpha: 0.2)),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: widget.accentColor.withValues(alpha: _pressed ? 0.18 : 0.07),
                blurRadius: _pressed ? 16 : 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: widget.child,
        ),
      ),
    );
  }
}

// ── Attendance Arc Gauge ──────────────────────────────────────────────────────

class _AttendanceArc extends StatelessWidget {
  const _AttendanceArc({
    required this.percentage,
    required this.color,
    required this.size,
  });
  final double percentage;
  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return SizedBox(
      width: size,
      height: size * 0.6,
      child: CustomPaint(
        painter: _ArcGaugePainter(
          percentage: percentage,
          color: color,
          isDark: isDark,
        ),
        child: Align(
          alignment: Alignment.bottomCenter,
          child: Text(
            '${percentage.toStringAsFixed(1)}%',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w900,
              color: color,
            ),
          ),
        ),
      ),
    );
  }
}

class _ArcGaugePainter extends CustomPainter {
  const _ArcGaugePainter({
    required this.percentage,
    required this.color,
    required this.isDark,
  });

  final double percentage;
  final Color color;
  final bool isDark;

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height;
    final r = size.width / 2 - 6;
    const stroke = 7.0;

    final bgPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round
      ..color = isDark
          ? AppColors.darkSurfaceVariant
          : AppColors.surfaceVariant;

    final fgPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round
      ..color = color;

    final rect = Rect.fromCircle(center: Offset(cx, cy), radius: r);
    canvas.drawArc(rect, math.pi, math.pi, false, bgPaint);
    canvas.drawArc(
        rect, math.pi, math.pi * (percentage / 100).clamp(0, 1), false, fgPaint);
  }

  @override
  bool shouldRepaint(_ArcGaugePainter old) =>
      old.percentage != percentage || old.color != color;
}

// ── Stat Chip ─────────────────────────────────────────────────────────────────

class _StatChip extends StatelessWidget {
  const _StatChip({required this.label, required this.color, required this.isDark});
  final String label;
  final Color color;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 9.5,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }
}
