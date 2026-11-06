import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:focus_sessions/models/quote_model.dart';
import 'package:focus_sessions/models/session_model.dart';
import 'package:focus_sessions/providers/quote_provider.dart';
import 'package:focus_sessions/providers/session_history_provider.dart';
import 'package:focus_sessions/providers/timer_provider.dart';
import 'package:focus_sessions/screens/home_screen.dart';
import 'package:focus_sessions/widgets/quote_card.dart';
import 'package:focus_sessions/widgets/today_focus_card.dart';

import 'helpers/fake_quote_service.dart';

Widget buildApp(SessionHistoryProvider history, {QuoteProvider? quotes}) {
  return MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => TimerProvider()),
      ChangeNotifierProvider.value(value: history),
      ChangeNotifierProvider.value(
        value: quotes ?? QuoteProvider(FakeQuoteService()),
      ),
    ],
    child: const MaterialApp(home: HomeScreen()),
  );
}

VoidCallback? pauseButtonAction(WidgetTester tester, String label) {
  return tester
      .widget<FilledButton>(find.widgetWithText(FilledButton, label))
      .onPressed;
}

void main() {
  testWidgets('shows the greeting, Today\'s Focus card and a disabled Pause',
      (WidgetTester tester) async {
    await tester.pumpWidget(buildApp(SessionHistoryProvider()));

    expect(find.text('Ready to Focus?'), findsOneWidget);
    expect(find.text("Today's Focus"), findsOneWidget);
    expect(find.text('READY'), findsOneWidget);
    expect(pauseButtonAction(tester, 'Pause'), isNull);
    expect(find.byIcon(Icons.history), findsOneWidget);
  });

  testWidgets('Pause freezes the countdown and Resume continues it',
      (WidgetTester tester) async {
    await tester.pumpWidget(buildApp(SessionHistoryProvider()));

    await tester.tap(find.text('Start Focus'));
    await tester.pump();
    await tester.pump(const Duration(seconds: 3));
    expect(find.text('24:57'), findsOneWidget);
    expect(find.text('FOCUSING'), findsOneWidget);

    await tester.tap(find.text('Pause'));
    await tester.pump();
    await tester.pump(const Duration(seconds: 5));
    expect(find.text('24:57'), findsOneWidget);
    expect(find.text('PAUSED'), findsOneWidget);
    expect(find.text('Resume'), findsOneWidget);

    await tester.tap(find.text('Resume'));
    await tester.pump();
    await tester.pump(const Duration(seconds: 2));
    expect(find.text('24:55'), findsOneWidget);
    expect(find.text('Pause'), findsOneWidget);

    // Clean up: stop the timer so no Timer is left pending.
    await tester.tap(find.text('End Session'));
    await tester.pump();
  });

  testWidgets('End Session works while paused and shows the save card',
      (WidgetTester tester) async {
    await tester.pumpWidget(buildApp(SessionHistoryProvider()));

    await tester.tap(find.text('Start Focus'));
    await tester.pump();
    await tester.pump(const Duration(seconds: 5));
    await tester.tap(find.text('Pause'));
    await tester.pump();

    await tester.tap(find.text('End Session'));
    await tester.pump();

    expect(find.text('Session finished'), findsOneWidget);
    expect(find.text('You focused for 00:05'), findsOneWidget);
  });

  testWidgets('Today\'s Focus counts only today\'s sessions',
      (WidgetTester tester) async {
    final history = SessionHistoryProvider();
    history.addSession(SessionModel(
      id: 'today',
      startedAt: DateTime.now(),
      plannedSeconds: 1500,
      actualSeconds: 600,
      note: '',
    ));
    history.addSession(SessionModel(
      id: 'old',
      startedAt: DateTime(2020, 1, 1, 9, 0),
      plannedSeconds: 1500,
      actualSeconds: 1500,
      note: '',
    ));

    await tester.pumpWidget(buildApp(history));

    expect(find.text('1'), findsOneWidget);
    expect(find.text('10m'), findsOneWidget);
  });

  testWidgets('shows the daily quote below Today\'s Focus',
      (WidgetTester tester) async {
    final quotes = QuoteProvider(FakeQuoteService(
      quote: const QuoteModel(text: 'Stay curious.', author: 'Someone'),
    ));
    quotes.fetchQuote();

    await tester.pumpWidget(buildApp(SessionHistoryProvider(), quotes: quotes));
    await tester.pump();
    await tester.pump();

    expect(find.text('Stay curious.'), findsOneWidget);
    expect(find.text('— Someone'), findsOneWidget);

    final todayTop = tester.getTopLeft(find.byType(TodayFocusCard)).dy;
    final quoteTop = tester.getTopLeft(find.byType(QuoteCard)).dy;
    expect(quoteTop, greaterThan(todayTop));
  });
}
