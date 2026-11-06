import 'dart:async';
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'package:focus_sessions/services/quote_service.dart';

// All tests use MockClient, so nothing here touches the network.
ZenQuotesService serviceReturning(http.Response response) {
  return ZenQuotesService(client: MockClient((_) async => response));
}

void main() {
  group('ZenQuotesService', () {
    test('requests the ZenQuotes random endpoint', () async {
      Uri? requested;
      final service = ZenQuotesService(
        client: MockClient((request) async {
          requested = request.url;
          return http.Response('[{"q":"Hi","a":"Me"}]', 200);
        }),
      );

      await service.fetchRandomQuote();

      expect(requested, Uri.parse('https://zenquotes.io/api/random'));
    });

    test('returns the quote from a good response', () async {
      final service = serviceReturning(
        http.Response('[{"q":"Keep going.","a":"Someone","h":"<p>x</p>"}]', 200),
      );

      final quote = await service.fetchRandomQuote();

      expect(quote.text, 'Keep going.');
      expect(quote.author, 'Someone');
    });

    test('decodes UTF-8 text such as curly quotes', () async {
      final body = utf8.encode('[{"q":"“Hello” — café","a":"Zoë"}]');
      final service = serviceReturning(http.Response.bytes(body, 200));

      final quote = await service.fetchRandomQuote();

      expect(quote.text, '“Hello” — café');
      expect(quote.author, 'Zoë');
    });

    test('throws QuoteException for a non-200 status', () async {
      final service = serviceReturning(http.Response('Server error', 500));

      expect(service.fetchRandomQuote(), throwsA(isA<QuoteException>()));
    });

    test('throws QuoteException when ZenQuotes reports the rate limit',
        () async {
      final service = serviceReturning(http.Response(
        '[{"q":"Too many requests. Obtain an auth key for unlimited access.",'
        '"a":"zenquotes.io","h":"<p>x</p>"}]',
        200,
      ));

      expect(service.fetchRandomQuote(), throwsA(isA<QuoteException>()));
    });

    test('throws QuoteException for invalid JSON', () async {
      final service = serviceReturning(http.Response('not json', 200));

      expect(service.fetchRandomQuote(), throwsA(isA<QuoteException>()));
    });

    test('throws QuoteException for an empty list', () async {
      final service = serviceReturning(http.Response('[]', 200));

      expect(service.fetchRandomQuote(), throwsA(isA<QuoteException>()));
    });

    test('throws QuoteException when the network fails', () async {
      final service = ZenQuotesService(
        client: MockClient((_) async => throw http.ClientException('offline')),
      );

      expect(service.fetchRandomQuote(), throwsA(isA<QuoteException>()));
    });

    test('throws QuoteException when the request times out', () async {
      final service = ZenQuotesService(
        // A request that never answers.
        client: MockClient((_) => Completer<http.Response>().future),
        timeout: const Duration(milliseconds: 20),
      );

      expect(service.fetchRandomQuote(), throwsA(isA<QuoteException>()));
    });
  });
}
