import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:focus_sessions/models/session_model.dart';
import 'package:focus_sessions/providers/quote_provider.dart';
import 'package:focus_sessions/providers/session_history_provider.dart';
import 'package:focus_sessions/providers/timer_provider.dart';
import 'package:focus_sessions/screens/history_screen.dart';
import 'package:focus_sessions/screens/home_screen.dart';
import 'package:focus_sessions/widgets/session_history_tile.dart';

import 'helpers/fake_quote_service.dart';

Widget buildApp(SessionHistoryProvider history, {required Widget home}) {
  return MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => TimerProvider()),
      ChangeNotifierProvider.value(value: history),
      ChangeNotifierProvider(create: (_) => QuoteProvider(FakeQuoteService())),
    ],
    child: MaterialApp(home: home),
  );
}

void main() {
  group('formatters', () {
    test('formatSessionDuration uses MM:SS', () {
      expect(formatSessionDuration(0), '00:00');
      expect(formatSessionDuration(600), '10:00');
      expect(formatSessionDuration(1499), '24:59');
    });

    test('formatSessionDate uses a 12-hour clock', () {
      expect(formatSessionDate(DateTime(2026, 11, 6, 14, 5)),
          'Nov 6, 2026 • 2:05 PM');
      expect(formatSessionDate(DateTime(2026, 1, 2, 0, 30)),
          'Jan 2, 2026 • 12:30 AM');
      expect(formatSessionDate(DateTime(2026, 1, 2, 12, 0)),
          'Jan 2, 2026 • 12:00 PM');
    });

    test('formatTotalFocusTime shows minutes, then hours', () {
      expect(formatTotalFocusTime(59), '0 min');
      expect(formatTotalFocusTime(2100), '35 min');
      expect(formatTotalFocusTime(3600), '1h');
      expect(formatTotalFocusTime(5400), '1h 30m');
    });
  });

  group('HistoryScreen', () {
    testWidgets('shows the empty state when there are no sessions',
        (tester) async {
      await tester.pumpWidget(
          buildApp(SessionHistoryProvider(), home: const HistoryScreen()));

      expect(find.text('Session History'), findsOneWidget);
      expect(find.text('No focus sessions yet'), findsOneWidget);
    });

    testWidgets('shows saved sessions with their details', (tester) async {
      final history = SessionHistoryProvider();
      history.addSession(SessionModel(
        id: 'a',
        startedAt: DateTime(2026, 11, 5, 9, 0),
        plannedSeconds: 1500,
        actualSeconds: 600,
        note: 'Read chapter 3',
      ));
      history.addSession(SessionModel(
        id: 'b',
        startedAt: DateTime(2026, 11, 6, 14, 5),
        plannedSeconds: 1500,
        actualSeconds: 1500,
        note: '',
      ));

      await tester.pumpWidget(buildApp(history, home: const HistoryScreen()));

      expect(find.text('No focus sessions yet'), findsNothing);
      expect(find.text('2 sessions • 35 min focused'), findsOneWidget);
      expect(find.text('Nov 6, 2026 • 2:05 PM'), findsOneWidget);
      expect(find.text('Focused 25:00 of 25:00'), findsOneWidget);
      expect(find.text('No note'), findsOneWidget);
      expect(find.text('Nov 5, 2026 • 9:00 AM'), findsOneWidget);
      expect(find.text('Focused 10:00 of 25:00'), findsOneWidget);
      expect(find.text('Read chapter 3'), findsOneWidget);
    });
  });

  group('HomeScreen history button', () {
    testWidgets('opens the History screen and can go back', (tester) async {
      await tester.pumpWidget(
          buildApp(SessionHistoryProvider(), home: const HomeScreen()));

      await tester.tap(find.byIcon(Icons.history));
      await tester.pumpAndSettle();

      expect(find.byType(HistoryScreen), findsOneWidget);
      expect(find.text('No focus sessions yet'), findsOneWidget);

      await tester.pageBack();
      await tester.pumpAndSettle();

      expect(find.byType(HistoryScreen), findsNothing);
      expect(find.text('Start Focus'), findsOneWidget);
    });
  });
}
