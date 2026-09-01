import 'package:flutter/material.dart';
import 'widgets/announcements_card.dart';
import 'widgets/assignments_summary_card.dart';
import 'widgets/attendance_summary_card.dart';
import 'widgets/community_preview_card.dart';
import 'widgets/compact_statistics_card.dart';
import 'widgets/events_summary_card.dart';
import 'widgets/greeting_header_card.dart';
import 'widgets/quick_actions_grid.dart';
import 'widgets/reminders_summary_card.dart';
import 'widgets/today_schedule_card.dart';

/// Configuration for a modular dashboard summary widget registered in [DashboardWidgetRegistry].
class DashboardWidgetConfig {
  const DashboardWidgetConfig({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.builder,
  });

  final String id;
  final String title;
  final String description;
  final IconData icon;
  final WidgetBuilder builder;
}

/// Centralized registry composing modular summary widgets for ScholarSync Home Dashboard.
class DashboardWidgetRegistry {
  DashboardWidgetRegistry._();

  static final Map<String, DashboardWidgetConfig> _registry = {
    'greeting': DashboardWidgetConfig(
      id: 'greeting',
      title: 'Greeting & Header',
      description: 'Time-based greeting, student profile summary, theme toggle, and notification bell.',
      icon: Icons.waving_hand_rounded,
      builder: (context) => const GreetingHeaderCard(),
    ),
    'today_classes': DashboardWidgetConfig(
      id: 'today_classes',
      title: "Today's Schedule",
      description: 'First 3 upcoming or current lectures timeline.',
      icon: Icons.schedule_rounded,
      builder: (context) => const TodayScheduleCard(),
    ),
    'quick_actions': DashboardWidgetConfig(
      id: 'quick_actions',
      title: 'Quick Actions',
      description: 'Shortcuts for adding assignments, reminders, notes, and opening timetable/attendance.',
      icon: Icons.grid_view_rounded,
      builder: (context) => const QuickActionsGrid(),
    ),
    'attendance_summary': DashboardWidgetConfig(
      id: 'attendance_summary',
      title: 'Attendance Summary',
      description: 'Circular progress indicator showing overall attendance and low-performing subject alert.',
      icon: Icons.pie_chart_outline_rounded,
      builder: (context) => const AttendanceSummaryCard(),
    ),
    'assignments': DashboardWidgetConfig(
      id: 'assignments',
      title: 'Upcoming Assignments',
      description: 'Top priority assignments sorted by urgency and due date.',
      icon: Icons.assignment_outlined,
      builder: (context) => const AssignmentsSummaryCard(),
    ),
    'calendar_preview': DashboardWidgetConfig(
      id: 'calendar_preview',
      title: 'Calendar & Events Preview',
      description: "Today's events and next upcoming exams.",
      icon: Icons.event_rounded,
      builder: (context) => const EventsSummaryCard(),
    ),
    'reminders': DashboardWidgetConfig(
      id: 'reminders',
      title: 'Quick Reminders',
      description: 'Active task checklist with quick complete toggle.',
      icon: Icons.notifications_active_outlined,
      builder: (context) => const RemindersSummaryCard(),
    ),
    'community_preview': DashboardWidgetConfig(
      id: 'community_preview',
      title: 'Community Preview',
      description: 'Recent discussions snippet and unread activity count.',
      icon: Icons.forum_outlined,
      builder: (context) => const CommunityPreviewCard(),
    ),
    'announcements': DashboardWidgetConfig(
      id: 'announcements',
      title: 'Campus Announcements',
      description: 'Official announcements and notices.',
      icon: Icons.campaign_outlined,
      builder: (context) => const AnnouncementsCard(),
    ),
    'compact_statistics': DashboardWidgetConfig(
      id: 'compact_statistics',
      title: 'Compact Statistics',
      description: 'High-value compact student metrics summary.',
      icon: Icons.analytics_outlined,
      builder: (context) => const CompactStatisticsCard(),
    ),
  };

  /// Default ordered widget ID list for the Home Dashboard layout.
  static const List<String> defaultOrder = [
    'greeting',
    'today_classes',
    'quick_actions',
    'attendance_summary',
    'assignments',
    'calendar_preview',
    'reminders',
    'community_preview',
    'announcements',
    'compact_statistics',
  ];

  static Map<String, DashboardWidgetConfig> get allWidgets => _registry;

  static DashboardWidgetConfig? getWidget(String id) => _registry[id];
}
