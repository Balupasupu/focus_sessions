import 'package:flutter_test/flutter_test.dart';

import 'package:focus_sessions/providers/timer_provider.dart';

void main() {
  group('TimerProvider defaults', () {
    test('starts with 25 minutes, 1500 seconds, and not running', () {
      final provider = TimerProvider();

      expect(provider.selectedMinutes, 25);
      expect(provider.remainingSeconds, 1500);
      expect(provider.isRunning, false);
      expect(provider.formattedTime, '25:00');
    });

    test('actual duration is 0 before any session starts', () {
      final provider = TimerProvider();

      expect(provider.actualDurationSeconds, 0);
    });
  });

  group('TimerProvider selectDuration', () {
    test('changes the selected minutes and resets the countdown', () {
      final provider = TimerProvider();

      provider.selectDuration(15);

      expect(provider.selectedMinutes, 15);
      expect(provider.remainingSeconds, 900);
      expect(provider.formattedTime, '15:00');
    });

    test('notifies listeners when the duration changes', () {
      final provider = TimerProvider();
      var notifications = 0;
      provider.addListener(() => notifications++);

      provider.selectDuration(45);

      expect(notifications, 1);
    });

    testWidgets('is ignored while a session is running',
        (WidgetTester tester) async {
      final provider = TimerProvider();
      provider.startSession();

      provider.selectDuration(15);

      expect(provider.selectedMinutes, 25);
      expect(provider.remainingSeconds, 1500);

      provider.endSession();
    });
  });

  group('TimerProvider countdown', () {
    testWidgets('startSession marks the session as running',
        (WidgetTester tester) async {
      final provider = TimerProvider();

      provider.startSession();

      expect(provider.isRunning, true);

      provider.endSession();
    });

    testWidgets('counts down one second at a time',
        (WidgetTester tester) async {
      final provider = TimerProvider();
      provider.startSession();

      await tester.pump(const Duration(seconds: 1));
      expect(provider.remainingSeconds, 1499);
      expect(provider.formattedTime, '24:59');

      await tester.pump(const Duration(seconds: 2));
      expect(provider.remainingSeconds, 1497);

      provider.endSession();
    });

    testWidgets('calling startSession twice does not speed up the clock',
        (WidgetTester tester) async {
      final provider = TimerProvider();
      provider.startSession();
      provider.startSession();

      await tester.pump(const Duration(seconds: 1));

      expect(provider.remainingSeconds, 1499);

      provider.endSession();
    });

    testWidgets('stops automatically at zero and counts the full duration',
        (WidgetTester tester) async {
      final provider = TimerProvider();
      provider.selectDuration(15);
      provider.startSession();

      await tester.pump(const Duration(minutes: 15));

      expect(provider.remainingSeconds, 0);
      expect(provider.isRunning, false);
      expect(provider.formattedTime, '00:00');
      expect(provider.actualDurationSeconds, 900);

      // Extra time passing must not push the countdown below zero.
      await tester.pump(const Duration(seconds: 5));
      expect(provider.remainingSeconds, 0);
      expect(provider.actualDurationSeconds, 900);
    });

    testWidgets('can start again after a session finishes',
        (WidgetTester tester) async {
      final provider = TimerProvider();
      provider.selectDuration(15);
      provider.startSession();
      await tester.pump(const Duration(minutes: 15));

      // The finished session must be saved or discarded first (Step 3).
      provider.resetSession();
      provider.startSession();

      expect(provider.isRunning, true);
      expect(provider.remainingSeconds, 900);

      provider.endSession();
    });

    testWidgets('starting after an early end begins from the full duration',
        (WidgetTester tester) async {
      final provider = TimerProvider();
      provider.startSession();
      await tester.pump(const Duration(minutes: 10));
      provider.endSession();
      expect(provider.remainingSeconds, 900);

      // The ended session must be saved or discarded first (Step 3).
      provider.resetSession();
      provider.startSession();

      expect(provider.remainingSeconds, 1500);
      expect(provider.isRunning, true);

      provider.endSession();
    });
  });

  group('TimerProvider endSession', () {
    testWidgets('ending a 25-minute session after 10 minutes gives 600 seconds',
        (WidgetTester tester) async {
      final provider = TimerProvider();
      provider.startSession();
      await tester.pump(const Duration(minutes: 10));

      provider.endSession();

      expect(provider.isRunning, false);
      expect(provider.remainingSeconds, 900);
      expect(provider.actualDurationSeconds, 600);
    });

    testWidgets('keeps the values and stops ticking after ending',
        (WidgetTester tester) async {
      final provider = TimerProvider();
      provider.startSession();
      await tester.pump(const Duration(seconds: 3));

      provider.endSession();
      await tester.pump(const Duration(seconds: 5));

      expect(provider.remainingSeconds, 1497);
      expect(provider.actualDurationSeconds, 3);
    });

    test('does nothing when no session is running', () {
      final provider = TimerProvider();
      var notifications = 0;
      provider.addListener(() => notifications++);

      provider.endSession();

      expect(notifications, 0);
      expect(provider.remainingSeconds, 1500);
    });
  });

  group('TimerProvider resetSession', () {
    testWidgets('restores the full duration after an early end',
        (WidgetTester tester) async {
      final provider = TimerProvider();
      provider.startSession();
      await tester.pump(const Duration(minutes: 10));
      provider.endSession();

      provider.resetSession();

      expect(provider.isRunning, false);
      expect(provider.remainingSeconds, 1500);
      expect(provider.actualDurationSeconds, 0);
      expect(provider.formattedTime, '25:00');
    });

    testWidgets('stops a running timer and restores the duration',
        (WidgetTester tester) async {
      final provider = TimerProvider();
      provider.startSession();
      await tester.pump(const Duration(seconds: 5));

      provider.resetSession();
      await tester.pump(const Duration(seconds: 5));

      expect(provider.isRunning, false);
      expect(provider.remainingSeconds, 1500);
    });
  });

  group('TimerProvider dispose', () {
    testWidgets('cancels the timer so nothing ticks afterwards',
        (WidgetTester tester) async {
      final provider = TimerProvider();
      provider.startSession();

      provider.dispose();

      // If the timer were still running, a tick would call
      // notifyListeners() on a disposed provider and throw.
      await tester.pump(const Duration(seconds: 5));
    });
  });
}