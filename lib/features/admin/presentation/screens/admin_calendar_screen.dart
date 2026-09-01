import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/models/academic_calendar_event.dart';
import '../admin_provider.dart';

/// Academic Calendar & Exam Dates Management Studio for ScholarSync App Owner.
class AdminCalendarScreen extends StatefulWidget {
  const AdminCalendarScreen({super.key});

  @override
  State<AdminCalendarScreen> createState() => _AdminCalendarScreenState();
}

class _AdminCalendarScreenState extends State<AdminCalendarScreen> {
  String? _selectedTypeFilter;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminProvider>().loadCalendarEvents();
    });
  }

  void _openAddEventDialog(BuildContext context) {
    final titleController = TextEditingController();
    final descController = TextEditingController();
    String selectedType = 'exam';
    DateTime selectedDate = DateTime.now().add(const Duration(days: 7));

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) => AlertDialog(
          title: const Text('Add Academic Calendar Event'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(labelText: 'Event Title', hintText: 'e.g. End Semester Exam Phase 1'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: descController,
                  decoration: const InputDecoration(labelText: 'Description (Optional)'),
                  maxLines: 2,
                ),
                const SizedBox(height: 16),
                const Text('Event Type', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: [
                    ChoiceChip(
                      label: const Text('Exam'),
                      selected: selectedType == 'exam',
                      selectedColor: AppColors.error.withValues(alpha: 0.2),
                      onSelected: (_) => setModalState(() => selectedType = 'exam'),
                    ),
                    ChoiceChip(
                      label: const Text('Holiday'),
                      selected: selectedType == 'holiday',
                      selectedColor: AppColors.success.withValues(alpha: 0.2),
                      onSelected: (_) => setModalState(() => selectedType = 'holiday'),
                    ),
                    ChoiceChip(
                      label: const Text('Semester Term'),
                      selected: selectedType == 'semester_start',
                      selectedColor: AppColors.primary.withValues(alpha: 0.2),
                      onSelected: (_) => setModalState(() => selectedType = 'semester_start'),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Event Date', style: TextStyle(fontSize: 13)),
                  subtitle: Text(
                    '${selectedDate.year}-${selectedDate.month.toString().padLeft(2, '0')}-${selectedDate.day.toString().padLeft(2, '0')}',
                    style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary),
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.calendar_today_rounded),
                    onPressed: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: selectedDate,
                        firstDate: DateTime.now().subtract(const Duration(days: 30)),
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                      );
                      if (picked != null) {
                        setModalState(() => selectedDate = picked);
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(backgroundColor: AppColors.primary),
              onPressed: () async {
                if (titleController.text.trim().isEmpty) return;
                Navigator.pop(ctx);
                final event = AcademicCalendarEvent(
                  id: '',
                  title: titleController.text.trim(),
                  description: descController.text.trim(),
                  eventType: selectedType,
                  startDate: selectedDate,
                );
                final success = await context.read<AdminProvider>().createCalendarEvent(event);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(success ? 'Calendar event added.' : 'Failed to add event.'),
                      backgroundColor: success ? AppColors.success : AppColors.error,
                    ),
                  );
                }
              },
              child: const Text('Save Event', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final admin = context.watch<AdminProvider>();
    final events = _selectedTypeFilter == null
        ? admin.calendarEvents
        : admin.calendarEvents.where((e) => e.eventType == _selectedTypeFilter).toList();

    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openAddEventDialog(context),
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.event_available_rounded, color: Colors.black),
        label: const Text('Add Date', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Academic Calendar & Dates',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Colors.white),
                      ),
                      Text(
                        '${events.length} schedule dates, exams, and holidays configured',
                        style: TextStyle(fontSize: 12, color: Colors.white.withValues(alpha: 0.6)),
                      ),
                    ],
                  ),
                ),
                IconButton.filledTonal(
                  icon: const Icon(Icons.refresh_rounded),
                  tooltip: 'Refresh Calendar',
                  onPressed: () => admin.loadCalendarEvents(),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Filter Row
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  ChoiceChip(
                    label: const Text('All Events'),
                    selected: _selectedTypeFilter == null,
                    selectedColor: AppColors.primary.withValues(alpha: 0.25),
                    onSelected: (_) => setState(() => _selectedTypeFilter = null),
                  ),
                  const SizedBox(width: 8),
                  ChoiceChip(
                    label: const Text('Exams'),
                    selected: _selectedTypeFilter == 'exam',
                    selectedColor: AppColors.error.withValues(alpha: 0.25),
                    onSelected: (_) => setState(() => _selectedTypeFilter = 'exam'),
                  ),
                  const SizedBox(width: 8),
                  ChoiceChip(
                    label: const Text('Holidays'),
                    selected: _selectedTypeFilter == 'holiday',
                    selectedColor: AppColors.success.withValues(alpha: 0.25),
                    onSelected: (_) => setState(() => _selectedTypeFilter = 'holiday'),
                  ),
                  const SizedBox(width: 8),
                  ChoiceChip(
                    label: const Text('Semesters'),
                    selected: _selectedTypeFilter == 'semester_start',
                    selectedColor: AppColors.secondary.withValues(alpha: 0.25),
                    onSelected: (_) => setState(() => _selectedTypeFilter = 'semester_start'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Events List
            Expanded(
              child: admin.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : events.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.calendar_month_outlined, size: 56, color: Colors.white.withValues(alpha: 0.4)),
                              const SizedBox(height: 12),
                              const Text(
                                'No Calendar Events Configured',
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Add exam timetables, semester milestones, or holiday schedules.',
                                style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 12),
                              ),
                            ],
                          ),
                        )
                      : ListView.separated(
                          itemCount: events.length,
                          separatorBuilder: (context, index) => const SizedBox(height: 10),
                          itemBuilder: (context, index) {
                            final item = events[index];
                            final isExam = item.eventType == 'exam';
                            final isHoliday = item.eventType == 'holiday';

                            return Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: const Color(0xFF0F1218),
                                borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
                                border: Border.all(color: const Color(0xFF27272A)),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                    decoration: BoxDecoration(
                                      color: (isExam ? AppColors.error : isHoliday ? AppColors.success : AppColors.primary)
                                          .withValues(alpha: 0.15),
                                      borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
                                      border: Border.all(
                                        color: (isExam ? AppColors.error : isHoliday ? AppColors.success : AppColors.primary)
                                            .withValues(alpha: 0.3),
                                      ),
                                    ),
                                    child: Column(
                                      children: [
                                        Text(
                                          '${item.startDate.day}',
                                          style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: Colors.white),
                                        ),
                                        Text(
                                          _getMonthName(item.startDate.month),
                                          style: TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                            color: isExam ? AppColors.error : isHoliday ? AppColors.success : AppColors.primary,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          item.title,
                                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.white),
                                        ),
                                        if (item.description != null && item.description!.isNotEmpty) ...[
                                          const SizedBox(height: 2),
                                          Text(
                                            item.description!,
                                            style: TextStyle(fontSize: 12, color: Colors.white.withValues(alpha: 0.6)),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                        const SizedBox(height: 4),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: Colors.white.withValues(alpha: 0.06),
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                          child: Text(
                                            item.eventType.toUpperCase(),
                                            style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Color(0xFF94A3B8)),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete_outline_rounded, size: 20, color: AppColors.error),
                                    tooltip: 'Delete Event',
                                    onPressed: () async {
                                      final success = await admin.deleteCalendarEvent(item.id);
                                      if (context.mounted) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Text(success ? 'Event deleted.' : 'Failed to delete.'),
                                            backgroundColor: success ? AppColors.success : AppColors.error,
                                          ),
                                        );
                                      }
                                    },
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }

  String _getMonthName(int month) {
    const months = ['JAN', 'FEB', 'MAR', 'APR', 'MAY', 'JUN', 'JUL', 'AUG', 'SEP', 'OCT', 'NOV', 'DEC'];
    return months[month - 1];
  }
}
