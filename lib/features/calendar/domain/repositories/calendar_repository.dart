import '../../../admin/domain/models/academic_calendar_event.dart';

abstract class CalendarRepository {
  Future<List<AcademicCalendarEvent>> getAcademicCalendarEvents({
    String? branch,
    int? semester,
    String? eventType,
  });

  Future<AcademicCalendarEvent> addPersonalEvent(AcademicCalendarEvent event);

  Future<void> deleteEvent(String eventId);
}
