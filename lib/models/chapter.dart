class Chapter {
  final String id;
  final String title;
  final String content;

  const Chapter({
    required this.id,
    required this.title,
    required this.content,
  });

  factory Chapter.fromJson(Map<String, dynamic> json) {
    return Chapter(
      id: json['id'] as String,
      title: json['title'] as String,
      content: json['content'] as String,
    );
  }
}
