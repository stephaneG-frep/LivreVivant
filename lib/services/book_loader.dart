import 'dart:convert';

import 'package:flutter/services.dart';

import '../models/book.dart';

class BookLoader {
  static const String _bookPath = 'assets/books/mon_livre.json';

  Future<Book> loadBook() async {
    final jsonString = await rootBundle.loadString(_bookPath);
    final jsonMap = jsonDecode(jsonString) as Map<String, dynamic>;
    return Book.fromJson(jsonMap);
  }
}
