import 'package:flutter_test/flutter_test.dart';
import 'package:scholarsync/features/admin/domain/models/academic_calendar_event.dart';
import 'package:scholarsync/features/calendar/domain/repositories/calendar_repository.dart';
import 'package:scholarsync/features/calendar/presentation/calendar_provider.dart';

class MockCalendarRepository implements CalendarRepository {
  List<AcademicCalendarEvent> events = [
    AcademicCalendarEvent(
      id: 'e-1',
      title: 'Midterm Exam',
      eventType: 'exam',
      startDate: DateTime(2026, 9, 24),
      endDate: DateTime(2026, 9, 26),
    ),
    AcademicCalendarEvent(
      id: 'e-2',
      title: 'Gandhi Jayanti',
      eventType: 'holiday',
      startDate: DateTime(2026, 10, 2),
    ),
  ];

  @override
  Future<List<AcademicCalendarEvent>> getAcademicCalendarEvents({
    String? branch,
    int? semester,
    String? eventType,
  }) async {
    if (eventType != null && eventType.isNotEmpty) {
      return events.where((e) => e.eventType == eventType).toList();
    }
    return List.from(events);
  }

  @override
  Future<AcademicCalendarEvent> addPersonalEvent(
      AcademicCalendarEvent event) async {
    events.add(event);
    return event;
  }

  @override
  Future<void> deleteEvent(String eventId) async {
    events.removeWhere((e) => e.id == eventId);
  }
}

void main() {
  group('CalendarProvider Tests', () {
    late CalendarProvider provider;
    late MockCalendarRepository mockRepo;

    setUp(() {
      mockRepo = MockCalendarRepository();
      provider = CalendarProvider(repository: mockRepo);
    });

    test('Initializes with current date and loads events', () async {
      await provider.loadEvents();

      expect(provider.events.length, 2);
      expect(provider.isLoading, false);
      expect(provider.error, isNull);
    });

    test('Date selection and month navigation work properly', () {
      final newDate = DateTime(2026, 12, 15);
      provider.selectDate(newDate);

      expect(provider.selectedDate, DateTime(2026, 12, 15));
      expect(provider.focusedMonth, DateTime(2026, 12, 1));

      provider.nextMonth();
      expect(provider.focusedMonth.month, 1);
      expect(provider.focusedMonth.year, 2027);

      provider.previousMonth();
      expect(provider.focusedMonth.month, 12);
      expect(provider.focusedMonth.year, 2026);
    });

    test('getEventsForDate accurately matches multi-day and single-day events', () async {
      await provider.loadEvents();

      // e-1 runs Sept 24 - 26
      final day24Events = provider.getEventsForDate(DateTime(2026, 9, 24));
      expect(day24Events.length, 1);
      expect(day24Events.first.title, 'Midterm Exam');

      final day25Events = provider.getEventsForDate(DateTime(2026, 9, 25));
      expect(day25Events.length, 1);

      final day27Events = provider.getEventsForDate(DateTime(2026, 9, 27));
      expect(day27Events.isEmpty, true);
    });

    test('addEvent adds a personal event to provider state', () async {
      await provider.loadEvents();

      final newEvent = AcademicCalendarEvent(
        id: 'e-3',
        title: 'Project Submission',
        eventType: 'deadline',
        startDate: DateTime(2026, 9, 30),
      );

      await provider.addEvent(newEvent);
      expect(provider.events.length, 3);
    });
  });
}
