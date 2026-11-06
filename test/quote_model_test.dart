import 'package:flutter_test/flutter_test.dart';

import 'package:focus_sessions/models/quote_model.dart';

void main() {
  group('QuoteModel.fromZenQuotesJson', () {
    test('reads the quote and the author', () {
      final quote = QuoteModel.fromZenQuotesJson([
        {'q': 'Keep going.', 'a': 'Someone', 'h': '<blockquote>x</blockquote>'},
      ]);

      expect(quote.text, 'Keep going.');
      expect(quote.author, 'Someone');
    });

    test('trims extra spaces', () {
      final quote = QuoteModel.fromZenQuotesJson([
        {'q': '  Keep going.  ', 'a': '  Someone '},
      ]);

      expect(quote.text, 'Keep going.');
      expect(quote.author, 'Someone');
    });

    test('uses "Unknown" when the author is missing or blank', () {
      final missing = QuoteModel.fromZenQuotesJson([
        {'q': 'Keep going.'},
      ]);
      final blank = QuoteModel.fromZenQuotesJson([
        {'q': 'Keep going.', 'a': '   '},
      ]);

      expect(missing.author, 'Unknown');
      expect(blank.author, 'Unknown');
    });

    test('throws FormatException for data that is not a quote list', () {
      expect(() => QuoteModel.fromZenQuotesJson(null), throwsFormatException);
      expect(() => QuoteModel.fromZenQuotesJson('text'), throwsFormatException);
      expect(
          () => QuoteModel.fromZenQuotesJson({'q': 'x'}), throwsFormatException);
      expect(() => QuoteModel.fromZenQuotesJson([]), throwsFormatException);
      expect(() => QuoteModel.fromZenQuotesJson(['not a map']),
          throwsFormatException);
    });

    test('throws FormatException when the quote text is missing or blank', () {
      expect(
        () => QuoteModel.fromZenQuotesJson([
          {'a': 'Someone'},
        ]),
        throwsFormatException,
      );
      expect(
        () => QuoteModel.fromZenQuotesJson([
          {'q': '   ', 'a': 'Someone'},
        ]),
        throwsFormatException,
      );
      expect(
        () => QuoteModel.fromZenQuotesJson([
          {'q': 42, 'a': 'Someone'},
        ]),
        throwsFormatException,
      );
    });
  });
}
