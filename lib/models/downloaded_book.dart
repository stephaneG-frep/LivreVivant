class DownloadedBook {
  final String id;
  final String title;
  final String author;
  final String sourceLabel;
  final String rawJson;
  final String format;
  final String savedAtIso;

  const DownloadedBook({
    required this.id,
    required this.title,
    required this.author,
    required this.sourceLabel,
    required this.rawJson,
    required this.format,
    required this.savedAtIso,
  });

  factory DownloadedBook.fromJson(Map<String, dynamic> json) {
    return DownloadedBook(
      id: json['id'] as String,
      title: json['title'] as String,
      author: json['author'] as String,
      sourceLabel: json['sourceLabel'] as String,
      rawJson: json['rawJson'] as String,
      format: (json['format'] as String?) ?? 'json',
      savedAtIso: json['savedAtIso'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'author': author,
      'sourceLabel': sourceLabel,
      'rawJson': rawJson,
      'format': format,
      'savedAtIso': savedAtIso,
    };
  }
}
