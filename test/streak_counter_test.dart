import 'package:flutter_test/flutter_test.dart';
import 'package:focus_sessions/legacy/streak_counter.dart';

void main() {
  group('StreakCounter', () {
    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);

    DateTime daysAgo(int days, {int hour = 10, int minute = 0}) {
      final date = todayDate.subtract(Duration(days: days));
      return DateTime(date.year, date.month, date.day, hour, minute);
    }

    test('returns 0 when there are no sessions', () {
      expect(StreakCounter([]).currentStreak(), 0);
    });

    test('counts consecutive calendar days despite different times', () {
      final sessions = [
        daysAgo(1, hour: 23, minute: 59),
        daysAgo(0, hour: 0, minute: 1),
      ];

      expect(StreakCounter(sessions).currentStreak(), 2);
    });

    test('counts duplicate sessions on the same day only once', () {
      final sessions = [
        daysAgo(0, hour: 9),
        daysAgo(0, hour: 14),
        daysAgo(1, hour: 10),
      ];

      expect(StreakCounter(sessions).currentStreak(), 2);
    });

    test('continues streak from yesterday when there is no session today', () {
      final sessions = [
        daysAgo(1),
        daysAgo(2),
        daysAgo(3),
      ];

      expect(StreakCounter(sessions).currentStreak(), 3);
    });

    test('returns 0 when the latest session was two days ago', () {
      final sessions = [daysAgo(2)];

      expect(StreakCounter(sessions).currentStreak(), 0);
    });

    test('returns 0 for an old session', () {
      final sessions = [daysAgo(7)];

      expect(StreakCounter(sessions).currentStreak(), 0);
    });

    test('counts an unsorted list correctly', () {
      final sessions = [
        daysAgo(0),
        daysAgo(2),
        daysAgo(1),
      ];

      expect(StreakCounter(sessions).currentStreak(), 3);
    });
  });
}