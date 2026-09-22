import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/models/leaderboard_models.dart';

class LeaderboardPodium extends StatelessWidget {
  const LeaderboardPodium({
    super.key,
    required this.podiumEntries,
    required this.isDark,
  });

  final List<LeaderboardEntry> podiumEntries;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    if (podiumEntries.isEmpty) return const SizedBox.shrink();

    LeaderboardEntry? first;
    LeaderboardEntry? second;
    LeaderboardEntry? third;

    for (final e in podiumEntries) {
      if (e.rank == 1) first = e;
      if (e.rank == 2) second = e;
      if (e.rank == 3) third = e;
    }

    // Fallbacks if ranks are ordered by index
    first ??= podiumEntries.isNotEmpty ? podiumEntries[0] : null;
    if (podiumEntries.length > 1) second ??= podiumEntries[1];
    if (podiumEntries.length > 2) third ??= podiumEntries[2];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.fromLTRB(12, 16, 12, 0),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.darkSurfaceVariant.withValues(alpha: 0.6)
            : AppColors.surfaceVariant.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.08)
              : Colors.black.withValues(alpha: 0.08),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // 2nd Place (Silver)
          if (second != null)
            Expanded(
              child: _buildPodiumColumn(
                entry: second,
                rank: 2,
                pedestalHeight: 80,
                accentColor: const Color(0xFF94A3B8), // Silver
                crownIcon: Icons.workspace_premium_rounded,
                isDark: isDark,
              ),
            )
          else
            const Spacer(),

          // 1st Place (Gold)
          if (first != null)
            Expanded(
              child: _buildPodiumColumn(
                entry: first,
                rank: 1,
                pedestalHeight: 110,
                accentColor: const Color(0xFFF59E0B), // Gold
                crownIcon: Icons.emoji_events_rounded,
                isDark: isDark,
                isWinner: true,
              ),
            )
          else
            const Spacer(),

          // 3rd Place (Bronze)
          if (third != null)
            Expanded(
              child: _buildPodiumColumn(
                entry: third,
                rank: 3,
                pedestalHeight: 65,
                accentColor: const Color(0xFFD97706), // Bronze
                crownIcon: Icons.military_tech_rounded,
                isDark: isDark,
              ),
            )
          else
            const Spacer(),
        ],
      ),
    );
  }

  Widget _buildPodiumColumn({
    required LeaderboardEntry entry,
    required int rank,
    required double pedestalHeight,
    required Color accentColor,
    required IconData crownIcon,
    required bool isDark,
    bool isWinner = false,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Trophy / Crown
        Icon(
          crownIcon,
          color: accentColor,
          size: isWinner ? 24 : 20,
        ),
        const SizedBox(height: 4),

        // Avatar
        Stack(
          alignment: Alignment.bottomRight,
          children: [
            Container(
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: accentColor,
                  width: isWinner ? 2.5 : 2.0,
                ),
                boxShadow: [
                  BoxShadow(
                    color: accentColor.withValues(alpha: 0.3),
                    blurRadius: isWinner ? 12 : 6,
                  ),
                ],
              ),
              child: CircleAvatar(
                radius: isWinner ? 26 : 22,
                backgroundColor: isDark
                    ? AppColors.darkSurface
                    : AppColors.surface,
                child: Text(
                  entry.displayName.isNotEmpty
                      ? entry.displayName[0].toUpperCase()
                      : '?',
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    color: accentColor,
                    fontSize: isWinner ? 18 : 15,
                  ),
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: accentColor,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '#$rank',
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),

        // Display Name
        Text(
          entry.displayName,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: isWinner ? 13 : 12,
            fontWeight: FontWeight.w700,
            color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
          ),
        ),

        // Score Points
        Text(
          '${entry.score} pts',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w800,
            color: accentColor,
          ),
        ),
        const SizedBox(height: 8),

        // Pedestal Box
        Container(
          height: pedestalHeight,
          width: double.infinity,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                accentColor.withValues(alpha: isDark ? 0.35 : 0.25),
                accentColor.withValues(alpha: isDark ? 0.10 : 0.05),
              ],
            ),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            border: Border.all(
              color: accentColor.withValues(alpha: 0.3),
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            '$rank',
            style: TextStyle(
              fontSize: isWinner ? 28 : 22,
              fontWeight: FontWeight.w900,
              color: accentColor.withValues(alpha: 0.8),
            ),
          ),
        ),
      ],
    );
  }
}
