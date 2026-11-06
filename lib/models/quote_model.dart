// A quote with its author.
class QuoteModel {
  const QuoteModel({required this.text, required this.author});

  final String text;
  final String author;

  // ZenQuotes answers with a list like:
  //   [{"q": "Quote text", "a": "Author", "h": "<html>"}]
  // Throws a FormatException if the data does not look like that.
  factory QuoteModel.fromZenQuotesJson(Object? decoded) {
    if (decoded is! List || decoded.isEmpty) {
      throw const FormatException('Expected a non-empty list.');
    }
    final first = decoded.first;
    if (first is! Map) {
      throw const FormatException('Expected a quote object.');
    }

    final text = first['q'];
    final author = first['a'];
    if (text is! String || text.trim().isEmpty) {
      throw const FormatException('The quote text is missing.');
    }

    return QuoteModel(
      text: text.trim(),
      author: author is String && author.trim().isNotEmpty
          ? author.trim()
          : 'Unknown',
    );
  }
}
