import 'package:flutter_test/flutter_test.dart';

import 'package:focus_sessions/models/session_model.dart';
import 'package:focus_sessions/models/today_summary.dart';

SessionModel session(String id, DateTime startedAt, int actualSeconds) {
  return SessionModel(
    id: id,
    startedAt: startedAt,
    plannedSeconds: 1500,
    actualSeconds: actualSeconds,
    note: '',
  );
}

void main() {
  final now = DateTime(2026, 11, 6, 15, 0);

  group('TodaySummary', () {
    test('is empty when there are no sessions', () {
      final summary = TodaySummary.fromSessions([], now);

      expect(summary.sessionCount, 0);
      expect(summary.focusedSeconds, 0);
      expect(summary.focusedLabel, '0m');
    });

    test('counts only sessions that started today', () {
      final summary = TodaySummary.fromSessions([
        session('a', DateTime(2026, 11, 6, 9, 0), 600),
        session('b', DateTime(2026, 11, 6, 13, 0), 1500),
        session('yesterday', DateTime(2026, 11, 5, 23, 59), 900),
        session('last-year', DateTime(2025, 11, 6, 9, 0), 900),
      ], now);

      expect(summary.sessionCount, 2);
      expect(summary.focusedSeconds, 2100);
      expect(summary.focusedLabel, '35m');
    });

    test('focusedLabel switches to hours', () {
      const oneHour = TodaySummary(sessionCount: 2, focusedSeconds: 3600);
      const ninety = TodaySummary(sessionCount: 3, focusedSeconds: 5400);

      expect(oneHour.focusedLabel, '1h');
      expect(ninety.focusedLabel, '1h 30m');
    });
  });
}
