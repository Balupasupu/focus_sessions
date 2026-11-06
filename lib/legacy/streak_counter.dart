class StreakCounter {
  final List<DateTime> sessionDays;

  StreakCounter(this.sessionDays);

  /// Returns consecutive session days ending today or yesterday.
  int currentStreak() {
    if (sessionDays.isEmpty) return 0;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    final uniqueDays = sessionDays
        .where((date) => !date.isAfter(today.add(const Duration(days: 1))))
        .map((date) => DateTime(date.year, date.month, date.day))
        .where((date) => !date.isAfter(today))
        .toSet();

   final DateTime? startDate = uniqueDays.contains(today)
    ? today
    : uniqueDays.contains(yesterday)
        ? yesterday
        : null;

if (startDate == null) return 0;

var cursor = startDate;

    var streak = 0;

    while (uniqueDays.contains(cursor)) {
      streak++;
      cursor = DateTime(cursor.year, cursor.month, cursor.day - 1);
    }

    return streak;
  }
}