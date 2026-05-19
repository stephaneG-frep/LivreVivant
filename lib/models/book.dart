import 'chapter.dart';

class Book {
  final String title;
  final String author;
  final String cover;
  final String description;
  final List<Chapter> chapters;

  const Book({
    required this.title,
    required this.author,
    required this.cover,
    required this.description,
    required this.chapters,
  });

  factory Book.fromJson(Map<String, dynamic> json) {
    final chaptersJson = json['chapters'] as List<dynamic>;

    return Book(
      title: json['title'] as String,
      author: json['author'] as String,
      cover: json['cover'] as String,
      description: json['description'] as String,
      chapters: chaptersJson
          .map((chapter) => Chapter.fromJson(chapter as Map<String, dynamic>))
          .toList(),
    );
  }
}
