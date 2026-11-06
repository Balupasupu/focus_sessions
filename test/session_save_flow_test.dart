import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:focus_sessions/providers/quote_provider.dart';
import 'package:focus_sessions/providers/session_history_provider.dart';
import 'package:focus_sessions/providers/timer_provider.dart';
import 'package:focus_sessions/screens/home_screen.dart';

import 'helpers/fake_quote_service.dart';

Widget buildFlowApp(TimerProvider timer, SessionHistoryProvider history) {
  return MultiProvider(
    providers: [
      ChangeNotifierProvider<TimerProvider>.value(value: timer),
      ChangeNotifierProvider<SessionHistoryProvider>.value(value: history),
      ChangeNotifierProvider<QuoteProvider>(
        create: (_) => QuoteProvider(FakeQuoteService()),
      ),
    ],
    child: const MaterialApp(home: HomeScreen()),
  );
}

// Starts a session, lets [seconds] pass, then taps End Session.
Future<void> runAndEnd(WidgetTester tester, {int seconds = 10}) async {
  await tester.tap(find.text('Start Focus'));
  await tester.pump();
  await tester.pump(Duration(seconds: seconds));
  await tester.tap(find.text('End Session'));
  await tester.pump();
}

Future<void> tapVisible(WidgetTester tester, Finder finder) async {
  await tester.ensureVisible(finder);
  await tester.pump();
  await tester.tap(finder);
  await tester.pump();
}

void main() {
  group('TimerProvider pending session', () {
    testWidgets('nothing is pending before any session',
        (WidgetTester tester) async {
      final timer = TimerProvider();

      expect(timer.hasUnsavedSession, false);
      expect(timer.startedAt, isNull);
    });

    testWidgets('ending manually after 10 minutes leaves 600 seconds pending',
        (WidgetTester tester) async {
      final timer = TimerProvider();
      timer.startSession();
      await tester.pump(const Duration(minutes: 10));

      timer.endSession();

      expect(timer.hasUnsavedSession, true);
      expect(timer.actualDurationSeconds, 600);
      expect(timer.formattedActualDuration, '10:00');
      expect(timer.startedAt, isNotNull);
    });

    testWidgets('timer completion leaves the full duration pending',
        (WidgetTester tester) async {
      final timer = TimerProvider();
      timer.selectDuration(15);
      timer.startSession();

      await tester.pump(const Duration(minutes: 15));

      expect(timer.isRunning, false);
      expect(timer.hasUnsavedSession, true);
      expect(timer.actualDurationSeconds, 900);
    });

    testWidgets('ending instantly leaves nothing to save',
        (WidgetTester tester) async {
      final timer = TimerProvider();
      timer.startSession();

      timer.endSession();

      expect(timer.hasUnsavedSession, false);
    });

    testWidgets('startSession is blocked while a session is pending',
        (WidgetTester tester) async {
      final timer = TimerProvider();
      timer.startSession();
      await tester.pump(const Duration(minutes: 10));
      timer.endSession();

      timer.startSession();

      expect(timer.isRunning, false);
      expect(timer.remainingSeconds, 900);
      expect(timer.actualDurationSeconds, 600);
    });

    testWidgets('selectDuration is blocked while a session is pending',
        (WidgetTester tester) async {
      final timer = TimerProvider();
      timer.startSession();
      await tester.pump(const Duration(minutes: 10));
      timer.endSession();

      timer.selectDuration(15);

      expect(timer.selectedMinutes, 25);
      expect(timer.actualDurationSeconds, 600);
    });

    testWidgets('resetSession clears the pending session and allows a start',
        (WidgetTester tester) async {
      final timer = TimerProvider();
      timer.startSession();
      await tester.pump(const Duration(minutes: 10));
      timer.endSession();

      timer.resetSession();

      expect(timer.hasUnsavedSession, false);
      expect(timer.startedAt, isNull);

      timer.startSession();
      expect(timer.isRunning, true);

      timer.endSession();
    });
  });

  group('SessionHistoryProvider savePendingSession', () {
    testWidgets('saves the ended session with the right values',
        (WidgetTester tester) async {
      final timer = TimerProvider();
      final history = SessionHistoryProvider();
      timer.startSession();
      final startedAt = timer.startedAt;
      await tester.pump(const Duration(minutes: 10));
      timer.endSession();

      final saved = history.savePendingSession(timer, 'Read chapter 3');

      expect(saved, true);
      expect(history.sessions.length, 1);
      final session = history.sessions.first;
      expect(session.plannedSeconds, 1500);
      expect(session.actualSeconds, 600);
      expect(session.note, 'Read chapter 3');
      expect(session.startedAt, startedAt);
      // The timer is cleared and ready for the next session.
      expect(timer.hasUnsavedSession, false);
      expect(timer.formattedTime, '25:00');
    });

    testWidgets('trims whitespace around the note',
        (WidgetTester tester) async {
      final timer = TimerProvider();
      final history = SessionHistoryProvider();
      timer.startSession();
      await tester.pump(const Duration(seconds: 30));
      timer.endSession();

      history.savePendingSession(timer, '  deep work  ');

      expect(history.sessions.first.note, 'deep work');
    });

    testWidgets('a completed session is saved with its full duration',
        (WidgetTester tester) async {
      final timer = TimerProvider();
      final history = SessionHistoryProvider();
      timer.selectDuration(15);
      timer.startSession();
      await tester.pump(const Duration(minutes: 15));

      history.savePendingSession(timer, '');

      expect(history.sessions.length, 1);
      expect(history.sessions.first.plannedSeconds, 900);
      expect(history.sessions.first.actualSeconds, 900);
    });

    testWidgets('saving twice does not create a duplicate',
        (WidgetTester tester) async {
      final timer = TimerProvider();
      final history = SessionHistoryProvider();
      timer.startSession();
      await tester.pump(const Duration(minutes: 10));
      timer.endSession();

      final first = history.savePendingSession(timer, 'once');
      final second = history.savePendingSession(timer, 'twice');

      expect(first, true);
      expect(second, false);
      expect(history.sessions.length, 1);
      expect(history.sessions.first.note, 'once');
    });

    testWidgets('returns false when there is nothing to save',
        (WidgetTester tester) async {
      final timer = TimerProvider();
      final history = SessionHistoryProvider();

      final saved = history.savePendingSession(timer, 'note');

      expect(saved, false);
      expect(history.sessions, isEmpty);
    });

    testWidgets('returns false while a session is still running',
        (WidgetTester tester) async {
      final timer = TimerProvider();
      final history = SessionHistoryProvider();
      timer.startSession();
      await tester.pump(const Duration(seconds: 5));

      final saved = history.savePendingSession(timer, 'note');

      expect(saved, false);
      expect(history.sessions, isEmpty);
      expect(timer.isRunning, true);

      timer.endSession();
    });

    testWidgets('discarding clears the session without saving it',
        (WidgetTester tester) async {
      final timer = TimerProvider();
      final history = SessionHistoryProvider();
      timer.startSession();
      await tester.pump(const Duration(minutes: 10));
      timer.endSession();

      timer.resetSession();

      expect(history.sessions, isEmpty);
      expect(timer.hasUnsavedSession, false);
      expect(history.savePendingSession(timer, 'late'), false);
    });
  });

  group('Save and Discard card', () {
    testWidgets('appears after End Session and locks the controls',
        (WidgetTester tester) async {
      final timer = TimerProvider();
      final history = SessionHistoryProvider();
      await tester.pumpWidget(buildFlowApp(timer, history));
      expect(find.text('Session finished'), findsNothing);

      await runAndEnd(tester);

      expect(find.text('Session finished'), findsOneWidget);
      expect(find.text('You focused for 00:10'), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);
      final start = tester.widget<FilledButton>(
          find.widgetWithText(FilledButton, 'Start Focus'));
      expect(start.onPressed, isNull);
    });

    testWidgets('Save adds the session with the note and clears the card',
        (WidgetTester tester) async {
      final timer = TimerProvider();
      final history = SessionHistoryProvider();
      await tester.pumpWidget(buildFlowApp(timer, history));
      await runAndEnd(tester);

      await tester.enterText(find.byType(TextField), 'Deep work');
      await tapVisible(tester, find.widgetWithText(FilledButton, 'Save'));

      expect(history.sessions.length, 1);
      expect(history.sessions.first.note, 'Deep work');
      expect(history.sessions.first.actualSeconds, 10);
      expect(history.sessions.first.plannedSeconds, 1500);
      expect(find.text('Session finished'), findsNothing);
      expect(find.text('25:00'), findsOneWidget);
    });

    testWidgets('Discard clears the card without saving',
        (WidgetTester tester) async {
      final timer = TimerProvider();
      final history = SessionHistoryProvider();
      await tester.pumpWidget(buildFlowApp(timer, history));
      await runAndEnd(tester);

      await tapVisible(tester, find.widgetWithText(TextButton, 'Discard'));

      expect(history.sessions, isEmpty);
      expect(find.text('Session finished'), findsNothing);
      expect(find.text('25:00'), findsOneWidget);
    });

    testWidgets('the card also appears when the timer completes by itself',
        (WidgetTester tester) async {
      final timer = TimerProvider();
      final history = SessionHistoryProvider();
      await tester.pumpWidget(buildFlowApp(timer, history));

      await tester.tap(find.text('15 min'));
      await tester.pump();
      await tester.tap(find.text('Start Focus'));
      await tester.pump();
      await tester.pump(const Duration(minutes: 15));

      expect(find.text('00:00'), findsOneWidget);
      expect(find.text('Session finished'), findsOneWidget);
      expect(find.text('You focused for 15:00'), findsOneWidget);
    });
  });
}