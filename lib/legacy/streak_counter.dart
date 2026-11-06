/// Counts how many consecutive calendar days have at least one session.
class StreakCounter {
  final List<DateTime> sessionDays;
  StreakCounter(this.sessionDays);

  /// Returns the number of consecutive calendar days with a session, ending
  /// today. If there is no session yet today, a streak that ended yesterday
  /// still counts, because the day is not over. Sessions dated in the future
  /// are ignored.
  int currentStreak() {
    final today = _dateOnly(DateTime.now());

    // Keep only the calendar date of each session. Using a Set means several
    // sessions on the same day count once, and the order of the input does
    // not matter.
    final days = <DateTime>{};
    for (final session in sessionDays) {
      days.add(_dateOnly(session));
    }

    // Start from today, or from yesterday when there is no session today.
    var cursor = days.contains(today) ? today : _previousDay(today);

    // Walk back one calendar day at a time while sessions exist. Because the
    // walk only goes backwards from today, future-dated sessions are never
    // reached, so they are ignored without any extra code.
    var streak = 0;
    while (days.contains(cursor)) {
      streak++;
      cursor = _previousDay(cursor);
    }
    return streak;
  }

  // The local calendar date at midnight, with the time of day removed.
  static DateTime _dateOnly(DateTime value) {
    final local = value.toLocal();
    return DateTime(local.year, local.month, local.day);
  }

  // Calendar arithmetic (day - 1), not Duration math, so daylight saving
  // changes can never make a day 23 or 25 hours long.
  static DateTime _previousDay(DateTime day) {
    return DateTime(day.year, day.month, day.day - 1);
  }
}