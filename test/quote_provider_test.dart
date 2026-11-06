import 'package:flutter_test/flutter_test.dart';

import 'package:focus_sessions/models/quote_model.dart';
import 'package:focus_sessions/providers/quote_provider.dart';
import 'package:focus_sessions/services/quote_service.dart';

import 'helpers/fake_quote_service.dart';

const apiQuote = QuoteModel(text: 'From the API.', author: 'API Author');

void main() {
  group('QuoteProvider', () {
    test('starts empty and not loading', () {
      final provider = QuoteProvider(FakeQuoteService());

      expect(provider.quote, isNull);
      expect(provider.isLoading, false);
      expect(provider.isFallback, false);
    });

    test('shows loading, then the API quote', () async {
      final service = PendingQuoteService();
      final provider = QuoteProvider(service);

      final future = provider.fetchQuote();
      expect(provider.isLoading, true);

      service.complete(apiQuote);
      await future;

      expect(provider.isLoading, false);
      expect(provider.isFallback, false);
      expect(provider.quote?.text, 'From the API.');
    });

    test('notifies when loading starts and when it finishes', () async {
      final provider = QuoteProvider(FakeQuoteService(quote: apiQuote));
      var notifications = 0;
      provider.addListener(() => notifications++);

      await provider.fetchQuote();

      expect(notifications, 2);
    });

    test('uses a fallback quote when the service fails', () async {
      final provider = QuoteProvider(
        FakeQuoteService(error: QuoteException('offline')),
      );

      await provider.fetchQuote();

      expect(provider.isLoading, false);
      expect(provider.isFallback, true);
      expect(QuoteProvider.fallbackQuotes, contains(provider.quote));
    });

    test('uses a fallback quote for unexpected errors too', () async {
      final provider = QuoteProvider(
        FakeQuoteService(error: StateError('anything')),
      );

      await provider.fetchQuote();

      expect(provider.isFallback, true);
      expect(provider.quote, isNotNull);
    });

    test('refreshing after a failure moves to the next fallback quote',
        () async {
      final provider = QuoteProvider(
        FakeQuoteService(error: QuoteException('offline')),
      );

      await provider.fetchQuote();
      final first = provider.quote;
      await provider.fetchQuote();

      expect(provider.quote, isNot(same(first)));
      expect(provider.isFallback, true);
    });

    test('a later success replaces the fallback', () async {
      final service = FakeQuoteService(error: QuoteException('offline'));
      final provider = QuoteProvider(service);
      await provider.fetchQuote();
      expect(provider.isFallback, true);

      service.error = null;
      service.quote = apiQuote;
      await provider.fetchQuote();

      expect(provider.isFallback, false);
      expect(provider.quote?.author, 'API Author');
    });

    test('ignores a second fetch while one is running', () async {
      final service = PendingQuoteService();
      final provider = QuoteProvider(service);

      final first = provider.fetchQuote();
      await provider.fetchQuote();

      expect(service.callCount, 1);

      service.complete(apiQuote);
      await first;
    });

    test('does not crash if disposed while a request is running', () async {
      final service = PendingQuoteService();
      final provider = QuoteProvider(service);

      final future = provider.fetchQuote();
      provider.dispose();
      service.complete(apiQuote);

      await future;
    });
  });
}
