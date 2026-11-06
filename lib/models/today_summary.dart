import 'session_model.dart';

// Totals for the sessions that started today. Pure Dart, no Flutter, so it
// is easy to test.
class TodaySummary {
  const TodaySummary({required this.sessionCount, required this.focusedSeconds});

  final int sessionCount;
  final int focusedSeconds;

  factory TodaySummary.fromSessions(List<SessionModel> sessions, DateTime now) {
    var count = 0;
    var seconds = 0;
    for (final session in sessions) {
      final d = session.startedAt;
      if (d.year == now.year && d.month == now.month && d.day == now.day) {
        count++;
        seconds += session.actualSeconds;
      }
    }
    return TodaySummary(sessionCount: count, focusedSeconds: seconds);
  }

  // "0m", "35m", "1h", "1h 30m"
  String get focusedLabel {
    final minutes = focusedSeconds ~/ 60;
    if (minutes < 60) return '${minutes}m';
    final hours = minutes ~/ 60;
    final rest = minutes % 60;
    return rest == 0 ? '${hours}h' : '${hours}h ${rest}m';
  }
}
