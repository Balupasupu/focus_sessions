import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/quote_model.dart';

// Thrown by a QuoteService for any reason a quote could not be loaded.
class QuoteException implements Exception {
  QuoteException(this.message);

  final String message;

  @override
  String toString() => 'QuoteException: $message';
}

// Anything that can provide a random quote. QuoteProvider depends on this
// type, so tests can pass in a fake and never touch the network.
abstract class QuoteService {
  Future<QuoteModel> fetchRandomQuote();
}

// Loads a random quote from https://zenquotes.io/api/random
class ZenQuotesService implements QuoteService {
  ZenQuotesService({
    http.Client? client,
    this.timeout = const Duration(seconds: 8),
  }) : _client = client ?? http.Client();

  static final Uri endpoint = Uri.parse('https://zenquotes.io/api/random');

  final http.Client _client;
  final Duration timeout;

  @override
  Future<QuoteModel> fetchRandomQuote() async {
    final http.Response response;
    try {
      response = await _client.get(endpoint).timeout(timeout);
    } on TimeoutException {
      throw QuoteException('The request timed out.');
    } catch (e) {
      throw QuoteException('Network error: $e');
    }

    if (response.statusCode != 200) {
      throw QuoteException('Server returned ${response.statusCode}.');
    }

    final QuoteModel quote;
    try {
      // Decode the bytes as UTF-8 ourselves so curly quotes and accents
      // survive even if the server omits the charset.
      quote = QuoteModel.fromZenQuotesJson(
        jsonDecode(utf8.decode(response.bodyBytes)),
      );
    } on FormatException catch (e) {
      throw QuoteException('Unexpected response: ${e.message}');
    }

    // When the limit is hit, ZenQuotes still answers 200 with a "quote"
    // that is really a warning message.
    if (_isRateLimitMessage(quote)) {
      throw QuoteException('Rate limit reached.');
    }
    return quote;
  }

  bool _isRateLimitMessage(QuoteModel quote) {
    return quote.author.toLowerCase() == 'zenquotes.io' ||
        quote.text.toLowerCase().startsWith('too many requests');
  }
}
