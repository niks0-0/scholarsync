import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../auth/auth_provider.dart';
import '../../domain/models/leaderboard_models.dart';
import '../../domain/services/points_engine.dart';
import '../leaderboard_provider.dart';
import '../widgets/leaderboard_podium.dart';
import '../widgets/leaderboard_rank_tile.dart';

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = context.read<AuthProvider>().currentUser;
      context.read<LeaderboardProvider>().loadLeaderboard(currentUid: user?.uid);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final prov = context.watch<LeaderboardProvider>();
    final user = context.watch<AuthProvider>().currentUser;
    final myEntry = prov.currentUserEntry;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.background,
      appBar: AppBar(
        title: const Text('Leaderboard & Ranks'),
        actions: [
          // Timeframe Filter Menu
          PopupMenuButton<TimeframeFilter>(
            icon: const Icon(Icons.calendar_today_rounded, size: 20),
            tooltip: 'Filter Timeframe',
            initialValue: prov.selectedTimeframe,
            onSelected: (t) {
              HapticFeedback.selectionClick();
              prov.setTimeframe(t, currentUid: user?.uid);
            },
            itemBuilder: (context) {
              return TimeframeFilter.values.map((t) {
                return PopupMenuItem<TimeframeFilter>(
                  value: t,
                  child: Row(
                    children: [
                      if (prov.selectedTimeframe == t)
                        const Icon(Icons.check_rounded,
                            size: 16, color: AppColors.primary)
                      else
                        const SizedBox(width: 16),
                      const SizedBox(width: 8),
                      Text(t.label),
                    ],
                  ),
                );
              }).toList();
            },
          ),
          IconButton(
            onPressed: () {
              HapticFeedback.lightImpact();
              prov.loadLeaderboard(currentUid: user?.uid);
            },
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Category Strip
            _buildCategoryCarousel(prov, user?.uid, isDark),

            // Scope Selector & Search Bar
            _buildFilterAndSearchBar(prov, user?.uid, isDark),

            // Main Content Area
            Expanded(
              child: prov.isLoading
                  ? const Center(
                      child: CircularProgressIndicator(color: AppColors.primary),
                    )
                  : RefreshIndicator(
                      onRefresh: () =>
                          prov.loadLeaderboard(currentUid: user?.uid),
                      child: CustomScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        slivers: [
                          // Podium Section (if no search query and at least 3 entries)
                          if (prov.searchQuery.isEmpty &&
                              prov.podiumEntries.length >= 3)
                            SliverToBoxAdapter(
                              child: LeaderboardPodium(
                                podiumEntries: prov.podiumEntries,
                                isDark: isDark,
                              ),
                            ),

                          // Heading for Rank List
                          SliverToBoxAdapter(
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    prov.searchQuery.isEmpty &&
                                            prov.podiumEntries.length >= 3
                                        ? 'RUNNERS UP & CONTENDERS'
                                        : 'ALL RANKINGS',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 0.8,
                                      color: isDark
                                          ? AppColors.darkTextSecondary
                                          : AppColors.textSecondary,
                                    ),
                                  ),
                                  Text(
                                    '${prov.filteredEntries.length} Scholars',
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
                          ),

                          // Rank Tiles List
                          if (prov.filteredEntries.isEmpty)
                            SliverFillRemaining(
                              hasScrollBody: false,
                              child: Center(
                                child: Text(
                                  'No scholars found for this filter.',
                                  style: TextStyle(
                                    color: isDark
                                        ? AppColors.darkTextSecondary
                                        : AppColors.textSecondary,
                                  ),
                                ),
                              ),
                            )
                          else
                            SliverList(
                              delegate: SliverChildBuilderDelegate(
                                (context, index) {
                                  final entries = (prov.searchQuery.isEmpty &&
                                          prov.podiumEntries.length >= 3)
                                      ? prov.restOfEntries
                                      : prov.filteredEntries;

                                  if (index >= entries.length) return null;
                                  final entry = entries[index];

                                  return LeaderboardRankTile(
                                    entry: entry,
                                    isDark: isDark,
                                  );
                                },
                                childCount: (prov.searchQuery.isEmpty &&
                                        prov.podiumEntries.length >= 3)
                                    ? prov.restOfEntries.length
                                    : prov.filteredEntries.length,
                              ),
                            ),

                          const SliverToBoxAdapter(
                            child: SizedBox(height: 100),
                          ),
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),

      // Sticky User Rank Bottom Bar
      bottomNavigationBar: myEntry != null
          ? _buildStickyMyRankBar(myEntry, isDark)
          : null,
    );
  }

  // ── Category Carousel ──────────────────────────────────────────────────────

  Widget _buildCategoryCarousel(
    LeaderboardProvider prov,
    String? uid,
    bool isDark,
  ) {
    return Container(
      height: 44,
      margin: const EdgeInsets.only(top: 8, bottom: 6),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: LeaderboardType.values.length,
        separatorBuilder: (_, i) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final cat = LeaderboardType.values[index];
          final isSelected = prov.selectedType == cat;

          return InkWell(
            onTap: () {
              HapticFeedback.selectionClick();
              prov.setType(cat, currentUid: uid);
            },
            borderRadius: BorderRadius.circular(22),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primary
                    : (isDark
                        ? AppColors.darkSurfaceVariant
                        : AppColors.surfaceVariant),
                borderRadius: BorderRadius.circular(22),
                border: Border.all(
                  color: isSelected
                      ? AppColors.primary
                      : (isDark
                          ? Colors.white.withValues(alpha: 0.08)
                          : Colors.black.withValues(alpha: 0.08)),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    cat.icon,
                    size: 16,
                    color: isSelected
                        ? Colors.black
                        : (isDark
                            ? AppColors.darkTextPrimary
                            : AppColors.textPrimary),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    cat.label,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: isSelected
                          ? Colors.black
                          : (isDark
                              ? AppColors.darkTextPrimary
                              : AppColors.textPrimary),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // ── Scope Selector & Search Field ──────────────────────────────────────────

  Widget _buildFilterAndSearchBar(
    LeaderboardProvider prov,
    String? uid,
    bool isDark,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Column(
        children: [
          Row(
            children: [
              // Scope Chips
              ...LeaderboardScope.values.map((s) {
                final isSelected = prov.selectedScope == s;
                return Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: ChoiceChip(
                    label: Text(s.label),
                    selected: isSelected,
                    onSelected: (_) {
                      HapticFeedback.selectionClick();
                      prov.setScope(s, currentUid: uid);
                    },
                    selectedColor: AppColors.primary.withValues(alpha: 0.2),
                    labelStyle: TextStyle(
                      fontSize: 11,
                      fontWeight:
                          isSelected ? FontWeight.w800 : FontWeight.w500,
                      color: isSelected
                          ? AppColors.primary
                          : (isDark
                              ? AppColors.darkTextSecondary
                              : AppColors.textSecondary),
                    ),
                    visualDensity: VisualDensity.compact,
                  ),
                );
              }),
            ],
          ),
          const SizedBox(height: 6),

          // Search Field
          Container(
            height: 40,
            decoration: BoxDecoration(
              color: isDark
                  ? AppColors.darkSurfaceVariant
                  : AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.05)
                    : Colors.black.withValues(alpha: 0.05),
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                Icon(
                  Icons.search_rounded,
                  size: 18,
                  color: isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.textSecondary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    onChanged: prov.setSearchQuery,
                    style: TextStyle(
                      fontSize: 13,
                      color: isDark
                          ? AppColors.darkTextPrimary
                          : AppColors.textPrimary,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Search scholars, dept, college...',
                      hintStyle: TextStyle(
                        fontSize: 12,
                        color: isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.textSecondary,
                      ),
                      border: InputBorder.none,
                      isDense: true,
                    ),
                  ),
                ),
                if (_searchController.text.isNotEmpty)
                  GestureDetector(
                    onTap: () {
                      _searchController.clear();
                      prov.setSearchQuery('');
                    },
                    child: Icon(
                      Icons.close_rounded,
                      size: 16,
                      color: isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.textSecondary,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Sticky User Rank Bottom Bar ────────────────────────────────────────────

  Widget _buildStickyMyRankBar(LeaderboardEntry myEntry, bool isDark) {
    final progress = PointsEngine.calculateLevelProgress(myEntry.score);
    final ptsNeeded = PointsEngine.pointsToNextTier(myEntry.score);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F172A) : Colors.white,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AppDimensions.radiusXl),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.4),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
        border: Border(
          top: BorderSide(
            color: AppColors.primary.withValues(alpha: 0.3),
            width: 1.5,
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                // Rank Badge
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '#${myEntry.rank}',
                    style: const TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.w900,
                      fontSize: 14,
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                // Name & Streak
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Text(
                            'Your Standing',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 1,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              myEntry.badgeTitle,
                              style: const TextStyle(
                                color: AppColors.primary,
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        ptsNeeded > 0
                            ? '$ptsNeeded pts to next tier'
                            : 'Maximum Rank Achieved',
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

                // Points & Streak Flame
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${myEntry.score} pts',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                        color: AppColors.primary,
                      ),
                    ),
                    if (myEntry.streakDays > 0)
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.local_fire_department_rounded,
                            color: Color(0xFFF97316),
                            size: 13,
                          ),
                          const SizedBox(width: 2),
                          Text(
                            '${myEntry.streakDays}d streak',
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFFF97316),
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Next Tier Progress Bar
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progress,
                backgroundColor: isDark
                    ? Colors.white.withValues(alpha: 0.1)
                    : Colors.black.withValues(alpha: 0.1),
                valueColor:
                    const AlwaysStoppedAnimation<Color>(AppColors.primary),
                minHeight: 4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
