import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

import '../models/book.dart';
import '../models/chapter.dart';

class BookLoader {
  static const String _bookPath = 'assets/books/mon_livre.json';

  Future<Book> loadBook() async {
    final jsonString = await rootBundle.loadString(_bookPath);
    return parseBook(jsonString);
  }

  Future<Book> loadBookFromAssetPath(String assetPath) async {
    final jsonString = await rootBundle.loadString(assetPath);
    return parseBook(jsonString);
  }

  Book parseBook(String jsonString) {
    final jsonMap = jsonDecode(jsonString) as Map<String, dynamic>;
    return Book.fromJson(jsonMap);
  }

  Future<String> downloadRawBookContent(String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null || !uri.hasScheme) {
      throw Exception('URL invalide.');
    }

    final response = await http.get(uri);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Téléchargement impossible (HTTP ${response.statusCode}).');
    }

    return response.body;
  }

  Book parseBookFromContent({
    required String rawContent,
    String? sourceLabel,
    String? formatHint,
  }) {
    final format = _resolveFormat(rawContent: rawContent, sourceLabel: sourceLabel, formatHint: formatHint);
    if (format == 'json') {
      return parseBook(rawContent);
    }
    if (format == 'md') {
      return _parseMarkdownBook(rawContent, sourceLabel: sourceLabel);
    }
    return _parseTextBook(rawContent, sourceLabel: sourceLabel);
  }

  String _resolveFormat({
    required String rawContent,
    String? sourceLabel,
    String? formatHint,
  }) {
    final normalizedHint = formatHint?.toLowerCase().trim();
    if (normalizedHint == 'json' || normalizedHint == 'md' || normalizedHint == 'txt') {
      return normalizedHint!;
    }

    final label = (sourceLabel ?? '').toLowerCase();
    if (label.endsWith('.json')) return 'json';
    if (label.endsWith('.md') || label.endsWith('.markdown')) return 'md';
    if (label.endsWith('.txt')) return 'txt';

    final trimmed = rawContent.trimLeft();
    if (trimmed.startsWith('{')) return 'json';
    if (trimmed.startsWith('#')) return 'md';
    return 'txt';
  }

  Book _parseMarkdownBook(String markdown, {String? sourceLabel}) {
    final lines = markdown.split('\n');
    final title = _extractFirstMarkdownTitle(lines) ?? _fallbackTitle(sourceLabel);

    final chapters = <Chapter>[];
    String currentTitle = 'Introduction';
    final buffer = StringBuffer();
    var chapterIndex = 0;

    for (final line in lines) {
      if (line.startsWith('# ')) {
        if (buffer.toString().trim().isNotEmpty) {
          chapters.add(
            Chapter(
              id: 'chapitre_${chapterIndex + 1}',
              title: currentTitle,
              content: buffer.toString().trim(),
            ),
          );
          buffer.clear();
          chapterIndex++;
        }
        currentTitle = line.replaceFirst('# ', '').trim();
      }
      buffer.writeln(line);
    }

    if (buffer.toString().trim().isNotEmpty) {
      chapters.add(
        Chapter(
          id: 'chapitre_${chapterIndex + 1}',
          title: currentTitle,
          content: buffer.toString().trim(),
        ),
      );
    }

    if (chapters.isEmpty) {
      chapters.add(
        Chapter(
          id: 'chapitre_1',
          title: 'Chapitre 1',
          content: markdown.trim(),
        ),
      );
    }

    return Book(
      title: title,
      author: 'Auteur non précisé',
      cover: 'assets/images/cover.png',
      description: 'Livre importé en Markdown.',
      chapters: chapters,
    );
  }

  Book _parseTextBook(String text, {String? sourceLabel}) {
    final normalized = text.trim();
    final title = _fallbackTitle(sourceLabel);
    final lines = normalized.split('\n');
    final chapters = <Chapter>[];

    final chapterRegex = RegExp(r'^\s*(chapitre|chapter)\s+[\divxlcm]+', caseSensitive: false);
    var currentTitle = 'Chapitre 1';
    final buffer = StringBuffer();
    var chapterIndex = 0;

    for (final line in lines) {
      if (chapterRegex.hasMatch(line)) {
        if (buffer.toString().trim().isNotEmpty) {
          chapters.add(
            Chapter(
              id: 'chapitre_${chapterIndex + 1}',
              title: currentTitle,
              content: '# $currentTitle\n\n${buffer.toString().trim()}',
            ),
          );
          buffer.clear();
          chapterIndex++;
        }
        currentTitle = line.trim();
      } else {
        buffer.writeln(line);
      }
    }

    if (buffer.toString().trim().isNotEmpty) {
      chapters.add(
        Chapter(
          id: 'chapitre_${chapterIndex + 1}',
          title: currentTitle,
          content: '# $currentTitle\n\n${buffer.toString().trim()}',
        ),
      );
    }

    if (chapters.isEmpty) {
      chapters.add(
        Chapter(
          id: 'chapitre_1',
          title: 'Chapitre 1',
          content: '# Chapitre 1\n\n$normalized',
        ),
      );
    }

    return Book(
      title: title,
      author: 'Auteur non précisé',
      cover: 'assets/images/cover.png',
      description: 'Livre importé en texte brut.',
      chapters: chapters,
    );
  }

  String _fallbackTitle(String? sourceLabel) {
    final label = sourceLabel?.trim();
    if (label == null || label.isEmpty) {
      return 'Livre importé';
    }
    final filename = label.split('/').last.split('\\').last;
    return filename.replaceAll(RegExp(r'\.(json|md|markdown|txt)$', caseSensitive: false), '');
  }

  String? _extractFirstMarkdownTitle(List<String> lines) {
    for (final line in lines) {
      if (line.startsWith('# ')) {
        return line.replaceFirst('# ', '').trim();
      }
    }
    return null;
  }
}
