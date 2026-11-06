import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:focus_sessions/providers/quote_provider.dart';
import 'package:focus_sessions/providers/session_history_provider.dart';
import 'package:focus_sessions/providers/timer_provider.dart';
import 'package:focus_sessions/screens/home_screen.dart';

import 'helpers/fake_quote_service.dart';

// HomeScreen needs a TimerProvider and a SessionHistoryProvider (for the
// Today's Focus card) above it, so every test builds the screen inside the
// same provider setup that main.dart uses.
Widget buildTestApp() {
  return MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => TimerProvider()),
      ChangeNotifierProvider(create: (_) => SessionHistoryProvider()),
      ChangeNotifierProvider(create: (_) => QuoteProvider(FakeQuoteService())),
    ],
    child: const MaterialApp(home: HomeScreen()),
  );
}

ChoiceChip chipWithLabel(WidgetTester tester, String label) {
  return tester.widget<ChoiceChip>(find.widgetWithText(ChoiceChip, label));
}

VoidCallback? startButtonAction(WidgetTester tester) {
  return tester
      .widget<FilledButton>(find.widgetWithText(FilledButton, 'Start Focus'))
      .onPressed;
}

VoidCallback? endButtonAction(WidgetTester tester) {
  return tester
      .widget<OutlinedButton>(
          find.widgetWithText(OutlinedButton, 'End Session'))
      .onPressed;
}

void main() {
  testWidgets('HomeScreen displays the Focus Sessions title',
      (WidgetTester tester) async {
    await tester.pumpWidget(buildTestApp());

    expect(find.text('Focus Sessions'), findsOneWidget);
  });

  testWidgets('shows 25:00, 25 min selected, and End Session disabled',
      (WidgetTester tester) async {
    await tester.pumpWidget(buildTestApp());

    expect(find.text('25:00'), findsOneWidget);
    expect(find.text('Session length: 25 minutes'), findsOneWidget);
    expect(chipWithLabel(tester, '25 min').selected, true);
    expect(chipWithLabel(tester, '15 min').selected, false);
    expect(startButtonAction(tester), isNotNull);
    expect(endButtonAction(tester), isNull);
  });

  testWidgets('tapping a duration chip updates the selection and countdown',
      (WidgetTester tester) async {
    await tester.pumpWidget(buildTestApp());

    await tester.tap(find.text('15 min'));
    await tester.pump();

    expect(chipWithLabel(tester, '15 min').selected, true);
    expect(chipWithLabel(tester, '25 min').selected, false);
    expect(find.text('15:00'), findsOneWidget);
    expect(find.text('Session length: 15 minutes'), findsOneWidget);
  });

  testWidgets('Start Focus counts down and locks the duration chips',
      (WidgetTester tester) async {
    await tester.pumpWidget(buildTestApp());

    await tester.tap(find.text('Start Focus'));
    await tester.pump();
    await tester.pump(const Duration(seconds: 3));

    expect(find.text('24:57'), findsOneWidget);
    expect(chipWithLabel(tester, '15 min').onSelected, isNull);
    expect(chipWithLabel(tester, '25 min').onSelected, isNull);
    expect(chipWithLabel(tester, '45 min').onSelected, isNull);
    expect(startButtonAction(tester), isNull);
    expect(endButtonAction(tester), isNotNull);

    // Clean up: stop the timer so no Timer is left pending.
    await tester.tap(find.text('End Session'));
    await tester.pump();
  });
  testWidgets('End Session stops the countdown and keeps the remaining time',
      (WidgetTester tester) async {
    await tester.pumpWidget(buildTestApp());

    await tester.tap(find.text('Start Focus'));
    await tester.pump();
    await tester.pump(const Duration(seconds: 10));
    expect(find.text('24:50'), findsOneWidget);

    await tester.tap(find.text('End Session'));
    await tester.pump();

    // Time stays frozen even though more time passes.
    await tester.pump(const Duration(seconds: 5));
    expect(find.text('24:50'), findsOneWidget);

    // Step 3: the ended session is pending, so starting and changing the
    // duration stay locked until it is saved or discarded.
    expect(startButtonAction(tester), isNull);
    expect(chipWithLabel(tester, '15 min').onSelected, isNull);

    // Discard the pending session.
    await tester.ensureVisible(find.text('Discard'));
    await tester.pump();
    await tester.tap(find.text('Discard'));
    await tester.pump();

    // Controls return to their "not running" state (original assertions).
    expect(endButtonAction(tester), isNull);
    expect(startButtonAction(tester), isNotNull);
    expect(chipWithLabel(tester, '15 min').onSelected, isNotNull);
  });
}