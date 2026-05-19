import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

import '../models/book.dart';

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

  Future<Book> loadBookFromUrl(String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null || !uri.hasScheme) {
      throw Exception('URL invalide.');
    }

    final response = await http.get(uri);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Téléchargement impossible (HTTP ${response.statusCode}).');
    }

    return parseBook(response.body);
  }

  Book parseBook(String jsonString) {
    final jsonMap = jsonDecode(jsonString) as Map<String, dynamic>;
    return Book.fromJson(jsonMap);
  }

  Future<String> downloadRawBookJson(String url) async {
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
}
