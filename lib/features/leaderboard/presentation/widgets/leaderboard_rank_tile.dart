import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/models/leaderboard_models.dart';

class LeaderboardRankTile extends StatelessWidget {
  const LeaderboardRankTile({
    super.key,
    required this.entry,
    required this.isDark,
    this.onTap,
  });

  final LeaderboardEntry entry;
  final bool isDark;
  final VoidCallback? onTap;

  Color _badgeColor(BadgeTier tier) {
    switch (tier) {
      case BadgeTier.legend:
        return const Color(0xFFEF4444);
      case BadgeTier.diamond:
        return const Color(0xFF06B6D4);
      case BadgeTier.platinum:
        return const Color(0xFFA855F7);
      case BadgeTier.gold:
        return const Color(0xFFF59E0B);
      case BadgeTier.silver:
        return const Color(0xFF94A3B8);
      case BadgeTier.bronze:
        return const Color(0xFFD97706);
    }
  }

  @override
  Widget build(BuildContext context) {
    final delta = entry.rankDelta;
    final isMe = entry.isCurrentUser;
    final tierColor = _badgeColor(entry.badgeTier);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: isMe
              ? AppColors.primary.withValues(alpha: isDark ? 0.15 : 0.10)
              : (isDark
                  ? AppColors.darkSurfaceVariant
                  : AppColors.surfaceVariant),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isMe
                ? AppColors.primary.withValues(alpha: 0.6)
                : (isDark
                    ? Colors.white.withValues(alpha: 0.05)
                    : Colors.black.withValues(alpha: 0.05)),
            width: isMe ? 1.5 : 1.0,
          ),
        ),
        child: Row(
          children: [
            // Rank Number + Delta
            SizedBox(
              width: 44,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '#${entry.rank}',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                      color: isMe
                          ? AppColors.primary
                          : (isDark
                              ? AppColors.darkTextPrimary
                              : AppColors.textPrimary),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (delta > 0) ...[
                        const Icon(
                          Icons.arrow_drop_up_rounded,
                          color: AppColors.success,
                          size: 16,
                        ),
                        Text(
                          '$delta',
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: AppColors.success,
                          ),
                        ),
                      ] else if (delta < 0) ...[
                        const Icon(
                          Icons.arrow_drop_down_rounded,
                          color: AppColors.error,
                          size: 16,
                        ),
                        Text(
                          '${delta.abs()}',
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: AppColors.error,
                          ),
                        ),
                      ] else ...[
                        Text(
                          '—',
                          style: TextStyle(
                            fontSize: 10,
                            color: isDark
                                ? AppColors.darkTextSecondary
                                : AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),

            // Avatar
            CircleAvatar(
              radius: 18,
              backgroundColor: tierColor.withValues(alpha: 0.2),
              child: Text(
                entry.displayName.isNotEmpty
                    ? entry.displayName[0].toUpperCase()
                    : '?',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  color: tierColor,
                  fontSize: 14,
                ),
              ),
            ),
            const SizedBox(width: 12),

            // Name + Department/College
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          entry.displayName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight:
                                isMe ? FontWeight.w800 : FontWeight.w600,
                            color: isMe
                                ? AppColors.primary
                                : (isDark
                                    ? AppColors.darkTextPrimary
                                    : AppColors.textPrimary),
                          ),
                        ),
                      ),
                      if (isMe) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 1,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text(
                            'YOU',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 9,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 1,
                        ),
                        decoration: BoxDecoration(
                          color: tierColor.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          entry.badgeTitle,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: tierColor,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          '${entry.departmentName} • Sem ${entry.semester}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 11,
                            color: isDark
                                ? AppColors.darkTextSecondary
                                : AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Streak Flame & Score Points
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${entry.score}',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                    color: AppColors.primary,
                  ),
                ),
                if (entry.streakDays > 0) ...[
                  const SizedBox(height: 2),
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
                        '${entry.streakDays}d',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFFF97316),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
