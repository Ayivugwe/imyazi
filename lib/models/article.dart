// lib/models/article.dart
class Article {
  final String title;
  final String content;
  final String? imageUrl;
  final DateTime publishDate;
  final String source;
  final String? author;
  final List<String> tags;
  bool isSaved;

  Article({
    required this.title,
    required this.content,
    this.imageUrl,
    required this.publishDate,
    required this.source,
    this.author,
    this.tags = const [],
    this.isSaved = false,
  });
}
