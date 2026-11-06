import 'package:flutter_test/flutter_test.dart';

import 'package:focus_sessions/providers/timer_provider.dart';

void main() {
  group('TimerProvider pause and resume', () {
    testWidgets('pause freezes the countdown and keeps the session open',
        (WidgetTester tester) async {
      final provider = TimerProvider();
      provider.startSession();
      await tester.pump(const Duration(seconds: 3));

      provider.pauseSession();
      await tester.pump(const Duration(seconds: 10));

      expect(provider.isPaused, true);
      expect(provider.isRunning, false);
      expect(provider.remainingSeconds, 1497);
      // Paused is still "in progress", not an unsaved session.
      expect(provider.hasUnsavedSession, false);

      provider.endSession();
    });

    testWidgets('resume continues from the remaining time',
        (WidgetTester tester) async {
      final provider = TimerProvider();
      provider.startSession();
      await tester.pump(const Duration(seconds: 3));
      provider.pauseSession();
      await tester.pump(const Duration(seconds: 10));

      provider.resumeSession();
      await tester.pump(const Duration(seconds: 2));

      expect(provider.isPaused, false);
      expect(provider.isRunning, true);
      expect(provider.remainingSeconds, 1495);

      provider.endSession();
    });

    testWidgets('start and duration changes are ignored while paused',
        (WidgetTester tester) async {
      final provider = TimerProvider();
      provider.startSession();
      await tester.pump(const Duration(seconds: 3));
      provider.pauseSession();

      provider.startSession();
      provider.selectDuration(45);

      expect(provider.isRunning, false);
      expect(provider.selectedMinutes, 25);
      expect(provider.remainingSeconds, 1497);

      provider.endSession();
    });

    testWidgets('ending a paused session keeps the time that was focused',
        (WidgetTester tester) async {
      final provider = TimerProvider();
      provider.startSession();
      await tester.pump(const Duration(seconds: 5));
      provider.pauseSession();

      provider.endSession();

      expect(provider.isPaused, false);
      expect(provider.actualDurationSeconds, 5);
      expect(provider.hasUnsavedSession, true);
    });

    testWidgets('resetSession clears a paused session',
        (WidgetTester tester) async {
      final provider = TimerProvider();
      provider.startSession();
      await tester.pump(const Duration(seconds: 5));
      provider.pauseSession();

      provider.resetSession();

      expect(provider.isPaused, false);
      expect(provider.remainingSeconds, 1500);
      expect(provider.startedAt, isNull);
    });

    test('pause and resume do nothing when they do not apply', () {
      final provider = TimerProvider();
      var notifications = 0;
      provider.addListener(() => notifications++);

      provider.pauseSession();
      provider.resumeSession();

      expect(notifications, 0);
      expect(provider.isPaused, false);
      expect(provider.isRunning, false);
    });
  });
}
