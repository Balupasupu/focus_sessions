import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:focus_sessions/models/quote_model.dart';
import 'package:focus_sessions/providers/quote_provider.dart';
import 'package:focus_sessions/services/quote_service.dart';
import 'package:focus_sessions/widgets/quote_card.dart';

import 'helpers/fake_quote_service.dart';

Widget buildCard(QuoteProvider provider) {
  return ChangeNotifierProvider.value(
    value: provider,
    child: const MaterialApp(home: Scaffold(body: QuoteCard())),
  );
}

// Lets the provider finish and the card rebuild.
Future<void> settle(WidgetTester tester) async {
  await tester.pump();
  await tester.pump();
}

VoidCallback? refreshAction(WidgetTester tester) {
  return tester
      .widget<IconButton>(find.widgetWithIcon(IconButton, Icons.refresh))
      .onPressed;
}

void main() {
  const apiQuote = QuoteModel(text: 'From the API.', author: 'API Author');

  testWidgets('shows nothing before a fetch has started',
      (WidgetTester tester) async {
    await tester.pumpWidget(buildCard(QuoteProvider(FakeQuoteService())));

    expect(find.text('Daily Quote'), findsNothing);
    expect(find.byType(CircularProgressIndicator), findsNothing);
  });

  testWidgets('shows a loading indicator, then the quote',
      (WidgetTester tester) async {
    final service = PendingQuoteService();
    final provider = QuoteProvider(service);
    await tester.pumpWidget(buildCard(provider));

    provider.fetchQuote();
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.text('Loading quote…'), findsOneWidget);
    expect(refreshAction(tester), isNull);

    service.complete(apiQuote);
    await settle(tester);

    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(find.text('From the API.'), findsOneWidget);
    expect(find.text('— API Author'), findsOneWidget);
    expect(find.text('Offline quote'), findsNothing);
    expect(refreshAction(tester), isNotNull);
  });

  testWidgets('shows a fallback quote when the service fails',
      (WidgetTester tester) async {
    final provider = QuoteProvider(
      FakeQuoteService(error: QuoteException('offline')),
    );
    await tester.pumpWidget(buildCard(provider));

    provider.fetchQuote();
    await settle(tester);

    final fallback = QuoteProvider.fallbackQuotes.first;
    expect(find.text(fallback.text), findsOneWidget);
    expect(find.text('— ${fallback.author}'), findsOneWidget);
    expect(find.text('Offline quote'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsNothing);
  });

  testWidgets('the refresh button fetches another quote',
      (WidgetTester tester) async {
    final service = FakeQuoteService(quote: apiQuote);
    final provider = QuoteProvider(service);
    await tester.pumpWidget(buildCard(provider));
    provider.fetchQuote();
    await settle(tester);
    expect(service.callCount, 1);

    service.quote = const QuoteModel(text: 'A new one.', author: 'Other');
    await tester.tap(find.byIcon(Icons.refresh));
    await settle(tester);

    expect(service.callCount, 2);
    expect(find.text('A new one.'), findsOneWidget);
    expect(find.text('From the API.'), findsNothing);
  });
}
