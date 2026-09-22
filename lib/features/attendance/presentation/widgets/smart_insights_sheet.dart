import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/models/subject_attendance.dart';
import '../../domain/services/smart_attendance_insights_engine.dart';

/// Phase 3 — Production-Ready Smart Attendance Insights Sheet.
/// Rule-based deterministic offline mathematical assistant.
class SmartInsightsSheet extends StatefulWidget {
  const SmartInsightsSheet({
    super.key,
    required this.subjects,
    this.initialTargetPct = 75.0,
  });

  final List<SubjectAttendance> subjects;
  final double initialTargetPct;

  @override
  State<SmartInsightsSheet> createState() => _SmartInsightsSheetState();
}

class _SmartInsightsSheetState extends State<SmartInsightsSheet>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late double _targetPct;
  int? _selectedSubjectIndex;
  int _attendSim = 2;
  int _skipSim = 1;
  String? _expandedCardId;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _targetPct = widget.initialTargetPct;
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  SubjectAttendance? get _selected {
    if (widget.subjects.isEmpty) return null;
    final idx = _selectedSubjectIndex ?? 0;
    if (idx >= widget.subjects.length) return widget.subjects.first;
    return widget.subjects[idx];
  }

  IconData _resolveIcon(String iconName) {
    switch (iconName) {
      case 'warning_amber_rounded':
        return Icons.warning_amber_rounded;
      case 'crisis_alert_rounded':
        return Icons.crisis_alert_rounded;
      case 'trending_up_rounded':
        return Icons.trending_up_rounded;
      case 'event_busy_rounded':
        return Icons.event_busy_rounded;
      case 'block_rounded':
        return Icons.block_rounded;
      case 'check_circle_outline_rounded':
        return Icons.check_circle_outline_rounded;
      case 'query_stats_rounded':
        return Icons.query_stats_rounded;
      case 'compare_arrows_rounded':
        return Icons.compare_arrows_rounded;
      case 'speed_rounded':
        return Icons.speed_rounded;
      case 'workspace_premium_rounded':
        return Icons.workspace_premium_rounded;
      case 'flag_rounded':
        return Icons.flag_rounded;
      default:
        return Icons.lightbulb_outline_rounded;
    }
  }

  Color _resolveSeverityColor(String severity) {
    switch (severity) {
      case 'danger':
        return AppColors.error;
      case 'warning':
        return AppColors.warning;
      case 'success':
        return AppColors.success;
      default:
        return AppColors.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final report = SmartAttendanceInsightsEngine.generateReport(
      subjects: widget.subjects,
      targetPct: _targetPct,
    );

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.90,
      ),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.surface,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(24.0),
        ),
        border: Border.all(
          color: isDark
              ? AppColors.primary.withValues(alpha: 0.15)
              : AppColors.border,
        ),
      ),
      child: Column(
        children: [
          // Drag Handle & Top Title Bar
          const SizedBox(height: 12),
          Center(
            child: Container(
              width: 44,
              height: 4,
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.2)
                    : Colors.black.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 12),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.bolt_rounded,
                    color: AppColors.primary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Smart Attendance Insights',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.3,
                        ),
                      ),
                      Text(
                        'Deterministic Rule Engine • 100% Offline',
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
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close_rounded, size: 20),
                  tooltip: 'Close',
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Target % Selector Bar
          _buildTargetSelector(isDark),
          const SizedBox(height: 12),

          // Tab Bar
          TabBar(
            controller: _tabController,
            labelColor: AppColors.primary,
            unselectedLabelColor: isDark
                ? AppColors.darkTextSecondary
                : AppColors.textSecondary,
            indicatorColor: AppColors.primary,
            indicatorSize: TabBarIndicatorSize.label,
            labelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
            tabs: const [
              Tab(text: 'Dynamic Q&A'),
              Tab(text: 'What-If Simulator'),
              Tab(text: 'Subject Deep-Dive'),
            ],
          ),
          const Divider(height: 1),

          // Tab Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildDynamicQATab(report, isDark),
                _buildWhatIfSimulatorTab(report, isDark),
                _buildSubjectDeepDiveTab(report, isDark),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Target Percentage Selector ─────────────────────────────────────────────

  Widget _buildTargetSelector(bool isDark) {
    const presets = [60.0, 75.0, 80.0, 85.0];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurfaceVariant : AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.05)
              : Colors.black.withValues(alpha: 0.05),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.tune_rounded,
            size: 16,
            color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
          ),
          const SizedBox(width: 8),
          Text(
            'Target:',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: presets.map((target) {
                  final isSelected = (_targetPct - target).abs() < 0.1;
                  return Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: InkWell(
                      onTap: () {
                        HapticFeedback.selectionClick();
                        setState(() => _targetPct = target);
                      },
                      borderRadius: BorderRadius.circular(8),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.primary
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: isSelected
                                ? AppColors.primary
                                : (isDark
                                    ? Colors.white.withValues(alpha: 0.15)
                                    : Colors.black.withValues(alpha: 0.15)),
                          ),
                        ),
                        child: Text(
                          '${target.toInt()}%',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: isSelected
                                ? Colors.black
                                : (isDark
                                    ? AppColors.darkTextPrimary
                                    : AppColors.textPrimary),
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Tab 1: Dynamic Q&A Cards ───────────────────────────────────────────────

  Widget _buildDynamicQATab(AttendanceAnalysisReport report, bool isDark) {
    if (report.cards.isEmpty) {
      return Center(
        child: Text(
          'No insights available.',
          style: TextStyle(
            color: isDark
                ? AppColors.darkTextSecondary
                : AppColors.textSecondary,
          ),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(20),
      itemCount: report.cards.length,
      separatorBuilder: (_, i) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final card = report.cards[index];
        final isExpanded = _expandedCardId == card.id;
        final color = _resolveSeverityColor(card.severity);

        return InkWell(
          onTap: () {
            HapticFeedback.lightImpact();
            setState(() {
              _expandedCardId = isExpanded ? null : card.id;
            });
          },
          borderRadius: BorderRadius.circular(16),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark
                  ? AppColors.darkSurfaceVariant
                  : AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isExpanded
                    ? color.withValues(alpha: 0.5)
                    : (isDark
                        ? Colors.white.withValues(alpha: 0.06)
                        : Colors.black.withValues(alpha: 0.06)),
                width: isExpanded ? 1.5 : 1.0,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        _resolveIcon(card.iconName),
                        color: color,
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            card.question,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: isDark
                                  ? AppColors.darkTextPrimary
                                  : AppColors.textPrimary,
                              height: 1.25,
                            ),
                          ),
                          if (!isExpanded) ...[
                            const SizedBox(height: 4),
                            Text(
                              card.answer,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 12,
                                color: isDark
                                    ? AppColors.darkTextSecondary
                                    : AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    Icon(
                      isExpanded
                          ? Icons.keyboard_arrow_up_rounded
                          : Icons.keyboard_arrow_down_rounded,
                      color: isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.textSecondary,
                      size: 20,
                    ),
                  ],
                ),
                if (isExpanded) ...[
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.black.withValues(alpha: 0.3)
                          : Colors.white.withValues(alpha: 0.7),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.05)
                            : Colors.black.withValues(alpha: 0.05),
                      ),
                    ),
                    child: Text(
                      card.answer,
                      style: TextStyle(
                        fontSize: 13,
                        height: 1.45,
                        color: isDark
                            ? AppColors.darkTextPrimary
                            : AppColors.textPrimary,
                      ),
                    ),
                  ),
                  if (card.actionLabel != null) ...[
                    const SizedBox(height: 10),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton.icon(
                        onPressed: () {
                          Navigator.of(context).pop();
                          if (card.actionLabel == 'View Timetable') {
                            context.push('/timetable');
                          }
                        },
                        icon: const Icon(Icons.arrow_forward_rounded, size: 14),
                        label: Text(
                          card.actionLabel!,
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.primary,
                          visualDensity: VisualDensity.compact,
                        ),
                      ),
                    ),
                  ],
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  // ── Tab 2: Interactive What-If Simulator ───────────────────────────────────

  Widget _buildWhatIfSimulatorTab(
    AttendanceAnalysisReport report,
    bool isDark,
  ) {
    final currentSub = _selected;

    if (currentSub == null) {
      return Center(
        child: Text(
          'No subjects to simulate.',
          style: TextStyle(
            color: isDark
                ? AppColors.darkTextSecondary
                : AppColors.textSecondary,
          ),
        ),
      );
    }

    final currentPct = currentSub.totalClasses > 0
        ? (currentSub.attendedClasses / currentSub.totalClasses) * 100.0
        : 100.0;

    final simulatedPct = SmartAttendanceInsightsEngine.simulateFuturePercentage(
      currentAttended: currentSub.attendedClasses,
      currentHeld: currentSub.totalClasses,
      attend: _attendSim,
      skip: _skipSim,
    );

    final delta = simulatedPct - currentPct;
    final isImprovement = delta >= 0;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Subject Picker Dropdown
          Text(
            'SELECT SUBJECT',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8,
              color: isDark
                  ? AppColors.darkTextSecondary
                  : AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: isDark
                  ? AppColors.darkSurfaceVariant
                  : AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.08)
                    : Colors.black.withValues(alpha: 0.08),
              ),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<int>(
                isExpanded: true,
                value: _selectedSubjectIndex ?? 0,
                dropdownColor:
                    isDark ? AppColors.darkSurfaceVariant : AppColors.surface,
                items: widget.subjects.asMap().entries.map((entry) {
                  final s = entry.value;
                  final p = s.totalClasses > 0
                      ? (s.attendedClasses / s.totalClasses * 100)
                          .toStringAsFixed(1)
                      : '100.0';
                  return DropdownMenuItem<int>(
                    value: entry.key,
                    child: Text(
                      '${s.subjectName} ($p%)',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) {
                    setState(() => _selectedSubjectIndex = val);
                  }
                },
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Simulation Result Banner
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  (isImprovement ? AppColors.success : AppColors.error)
                      .withValues(alpha: 0.15),
                  Colors.transparent,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: (isImprovement ? AppColors.success : AppColors.error)
                    .withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Projected Attendance',
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${simulatedPct.toStringAsFixed(1)}%',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        color: simulatedPct >= _targetPct
                            ? AppColors.success
                            : AppColors.error,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: (isImprovement ? AppColors.success : AppColors.error)
                        .withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isImprovement
                            ? Icons.trending_up_rounded
                            : Icons.trending_down_rounded,
                        color:
                            isImprovement ? AppColors.success : AppColors.error,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${delta >= 0 ? '+' : ''}${delta.toStringAsFixed(1)}%',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: isImprovement
                              ? AppColors.success
                              : AppColors.error,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Steppers
          _buildStepperRow(
            label: 'Attend Next Classes',
            value: _attendSim,
            color: AppColors.success,
            onChanged: (v) => setState(() => _attendSim = v),
            isDark: isDark,
          ),
          const SizedBox(height: 12),
          _buildStepperRow(
            label: 'Skip / Miss Next Classes',
            value: _skipSim,
            color: AppColors.error,
            onChanged: (v) => setState(() => _skipSim = v),
            isDark: isDark,
          ),
        ],
      ),
    );
  }

  Widget _buildStepperRow({
    required String label,
    required int value,
    required Color color,
    required ValueChanged<int> onChanged,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurfaceVariant : AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.05)
              : Colors.black.withValues(alpha: 0.05),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
          ),
          Row(
            children: [
              IconButton(
                onPressed: value > 0 ? () => onChanged(value - 1) : null,
                icon: const Icon(Icons.remove_circle_outline_rounded),
                visualDensity: VisualDensity.compact,
                color: isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.textSecondary,
              ),
              Container(
                constraints: const BoxConstraints(minWidth: 32),
                alignment: Alignment.center,
                child: Text(
                  '$value',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: color,
                  ),
                ),
              ),
              IconButton(
                onPressed: () => onChanged(value + 1),
                icon: const Icon(Icons.add_circle_outline_rounded),
                visualDensity: VisualDensity.compact,
                color: color,
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Tab 3: Subject Deep-Dive ───────────────────────────────────────────────

  Widget _buildSubjectDeepDiveTab(
    AttendanceAnalysisReport report,
    bool isDark,
  ) {
    if (widget.subjects.isEmpty) {
      return Center(
        child: Text(
          'No subjects tracked yet.',
          style: TextStyle(
            color: isDark
                ? AppColors.darkTextSecondary
                : AppColors.textSecondary,
          ),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(20),
      itemCount: widget.subjects.length,
      separatorBuilder: (_, i) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final sub = widget.subjects[index];
        final pct = sub.totalClasses > 0
            ? (sub.attendedClasses / sub.totalClasses * 100.0)
            : 100.0;
        final isSafe = pct >= _targetPct;

        final safeBunks = SmartAttendanceInsightsEngine.safeBunksAvailable(
          attended: sub.attendedClasses,
          held: sub.totalClasses,
          targetPct: _targetPct,
        );
        final needToAttend = SmartAttendanceInsightsEngine.classesToReachTarget(
          attended: sub.attendedClasses,
          held: sub.totalClasses,
          targetPct: _targetPct,
        );

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark
                ? AppColors.darkSurfaceVariant
                : AppColors.surfaceVariant,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSafe
                  ? AppColors.success.withValues(alpha: 0.3)
                  : AppColors.error.withValues(alpha: 0.3),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      sub.subjectName,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: (isSafe ? AppColors.success : AppColors.error)
                          .withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${pct.toStringAsFixed(1)}%',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: isSafe ? AppColors.success : AppColors.error,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                '${sub.attendedClasses} attended / ${sub.totalClasses} held',
                style: TextStyle(
                  fontSize: 12,
                  color: isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 10),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.black.withValues(alpha: 0.2)
                      : Colors.white.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  isSafe
                      ? '🛡️ Safe to miss up to $safeBunks lecture${safeBunks == 1 ? '' : 's'} before dropping below ${_targetPct.toInt()}%. '
                      : '⚠️ Must attend the next $needToAttend lecture${needToAttend == 1 ? '' : 's'} consecutively to reach ${_targetPct.toInt()}%.',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isSafe ? AppColors.success : AppColors.error,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
