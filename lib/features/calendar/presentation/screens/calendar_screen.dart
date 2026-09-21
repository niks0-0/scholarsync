import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../admin/domain/models/academic_calendar_event.dart';
import '../../../auth/auth_provider.dart';
import '../../../profile/presentation/profile_provider.dart';
import '../../../timetable/presentation/timetable_provider.dart';
import '../calendar_provider.dart';
import '../widgets/add_personal_event_sheet.dart';
import '../widgets/calendar_category_chips.dart';
import '../widgets/calendar_day_timeline.dart';
import '../widgets/calendar_event_card.dart';
import '../widgets/calendar_header.dart';
import '../widgets/calendar_month_grid.dart';
import '../widgets/calendar_week_strip.dart';
import '../widgets/event_detail_modal.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final profile = context.read<ProfileProvider>().profile;
      final auth = context.read<AuthProvider>();
      context.read<CalendarProvider>().loadEvents(
            branch: profile?.branch,
            semester: profile?.semester,
          );
      if (auth.currentUser != null) {
        context.read<TimetableProvider>().loadWeeklySchedule(auth.currentUser!.uid);
      }
    });
  }

  void _showEventDetail(AcademicCalendarEvent event) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => EventDetailModal(event: event),
    );
  }

  void _showAddEventSheet() {
    final calendar = context.read<CalendarProvider>();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AddPersonalEventSheet(
        initialDate: calendar.selectedDate,
        onEventAdded: (newEvent) {
          calendar.addEvent(newEvent);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Event added to your calendar!'),
              behavior: SnackBarBehavior.floating,
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final calendar = context.watch<CalendarProvider>();
    final selectedEvents = calendar.getEventsForDate(calendar.selectedDate);

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.background,
      appBar: AppBar(
        title: const Text('Academic Calendar'),
        actions: [
          IconButton(
            onPressed: () {
              final profile = context.read<ProfileProvider>().profile;
              calendar.loadEvents(
                branch: profile?.branch,
                semester: profile?.semester,
              );
            },
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Sync Calendar',
          ),
          IconButton(
            onPressed: _showAddEventSheet,
            icon: const Icon(Icons.add_rounded),
            tooltip: 'Add Event',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddEventSheet,
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.black,
        icon: const Icon(Icons.add_rounded),
        label: const Text(
          'Add Event',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            final profile = context.read<ProfileProvider>().profile;
            await calendar.loadEvents(
              branch: profile?.branch,
              semester: profile?.semester,
            );
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.spacingLg,
              vertical: AppDimensions.spacingMd,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header (Month/Year, Today, Navigation, View Selector)
                CalendarHeader(
                  focusedMonth: calendar.focusedMonth,
                  viewMode: calendar.viewMode,
                  onPrevious: calendar.previousMonth,
                  onNext: calendar.nextMonth,
                  onToday: calendar.jumpToToday,
                  onViewModeChanged: calendar.setViewMode,
                ),
                const SizedBox(height: 12),

                // Category Filter Chips
                CalendarCategoryChips(
                  selectedCategory: calendar.selectedCategory,
                  onSelectCategory: calendar.filterCategory,
                ),
                const SizedBox(height: 14),

                // View Body Switching
                if (calendar.isLoading)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 40),
                    child: Center(child: CircularProgressIndicator()),
                  )
                else if (calendar.viewMode == CalendarViewMode.month) ...[
                  // Month Matrix
                  CalendarMonthGrid(
                    focusedMonth: calendar.focusedMonth,
                    selectedDate: calendar.selectedDate,
                    events: calendar.events,
                    onSelectDate: calendar.selectDate,
                  ),
                  const SizedBox(height: 20),

                  // Selected Date Events Section
                  _buildDateEventsSection(context, calendar, selectedEvents),
                ] else if (calendar.viewMode == CalendarViewMode.week) ...[
                  // Week Strip
                  CalendarWeekStrip(
                    selectedDate: calendar.selectedDate,
                    events: calendar.events,
                    onSelectDate: calendar.selectDate,
                  ),
                  const SizedBox(height: 20),

                  // Selected Date Events Section
                  _buildDateEventsSection(context, calendar, selectedEvents),
                ] else ...[
                  // Day Hourly Schedule & Timetable Classes
                  CalendarDayTimeline(
                    selectedDate: calendar.selectedDate,
                    events: selectedEvents,
                    onEventTap: _showEventDetail,
                  ),
                ],

                const SizedBox(height: 80), // Fab clearance
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDateEventsSection(
    BuildContext context,
    CalendarProvider calendar,
    List<AcademicCalendarEvent> events,
  ) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final date = calendar.selectedDate;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                'Events for ${date.day}/${date.month}/${date.year}',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.3,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurfaceVariant : AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '${events.length} event${events.length == 1 ? '' : 's'}',
                style: theme.textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (events.isEmpty)
          Container(
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurface : Colors.white,
              borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
              border: Border.all(
                color: isDark ? AppColors.darkBorder : AppColors.border,
              ),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.event_available_rounded,
                  size: 36,
                  color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                ),
                const SizedBox(height: 8),
                Text(
                  'No academic events on this date',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Tap + to schedule an assignment or reminder.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          )
        else
          ...events.map(
            (e) => CalendarEventCard(
              event: e,
              onTap: () => _showEventDetail(e),
            ),
          ),
      ],
    );
  }
}
