import 'package:flutter/foundation.dart';

import '../models/quote_model.dart';
import '../services/quote_service.dart';

// Holds the quote shown on the Home Screen. Separate from the timer and
// history providers on purpose.
class QuoteProvider extends ChangeNotifier {
  QuoteProvider(this._service);

  final QuoteService _service;

  // Shown whenever the API fails, times out, or hits its rate limit.
  static const List<QuoteModel> fallbackQuotes = [
    QuoteModel(
      text: 'It does not matter how slowly you go as long as you do not stop.',
      author: 'Confucius',
    ),
    QuoteModel(
      text: 'The journey of a thousand miles begins with a single step.',
      author: 'Lao Tzu',
    ),
    QuoteModel(
      text: 'Well begun is half done.',
      author: 'Proverb',
    ),
    QuoteModel(
      text: 'Focus on being productive instead of busy.',
      author: 'Tim Ferriss',
    ),
  ];

  QuoteModel? _quote;
  bool _isLoading = false;
  bool _isFallback = false;
  int _fallbackIndex = 0;
  bool _disposed = false;

  // Null until the first fetch has finished.
  QuoteModel? get quote => _quote;
  bool get isLoading => _isLoading;

  // True when [quote] is a built-in fallback, not one from the API.
  bool get isFallback => _isFallback;

  // Loads a new quote. Never throws: any failure shows a fallback quote.
  // Ignored while a request is already in progress.
  Future<void> fetchQuote() async {
    if (_isLoading) return;

    _isLoading = true;
    _notify();

    try {
      _quote = await _service.fetchRandomQuote();
      _isFallback = false;
    } catch (_) {
      _quote = fallbackQuotes[_fallbackIndex % fallbackQuotes.length];
      _fallbackIndex++;
      _isFallback = true;
    }

    _isLoading = false;
    _notify();
  }

  // The app can close this provider while a request is still running.
  void _notify() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
