import 'dart:async';

import 'package:focus_sessions/models/quote_model.dart';
import 'package:focus_sessions/services/quote_service.dart';

// Answers immediately with [quote], or throws [error] if one is given.
class FakeQuoteService implements QuoteService {
  FakeQuoteService({this.quote, this.error});

  QuoteModel? quote;
  Object? error;
  int callCount = 0;

  @override
  Future<QuoteModel> fetchRandomQuote() async {
    callCount++;
    final failure = error;
    if (failure != null) throw failure;
    return quote ?? const QuoteModel(text: 'Fake quote', author: 'Fake Author');
  }
}

// Waits until the test calls complete() or completeError().
class PendingQuoteService implements QuoteService {
  final List<Completer<QuoteModel>> _requests = [];

  int get callCount => _requests.length;

  void complete(QuoteModel quote) => _requests.last.complete(quote);

  void completeError(Object error) => _requests.last.completeError(error);

  @override
  Future<QuoteModel> fetchRandomQuote() {
    final completer = Completer<QuoteModel>();
    _requests.add(completer);
    return completer.future;
  }
}
