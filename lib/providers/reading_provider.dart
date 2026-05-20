import 'dart:convert';

import 'package:flutter/material.dart';

import '../models/book.dart';
import '../models/chapter.dart';
import '../models/downloaded_book.dart';
import '../services/book_loader.dart';
import '../services/storage_service.dart';

class ReadingProvider extends ChangeNotifier {
  ReadingProvider({
    required BookLoader bookLoader,
    required StorageService storageService,
  })  : _bookLoader = bookLoader,
        _storageService = storageService;

  final BookLoader _bookLoader;
  final StorageService _storageService;

  Book? _book;
  bool _isLoading = true;
  int _currentChapterIndex = 0;
  bool _isDarkMode = false;
  double _fontSize = 18;
  Map<String, String> _notes = {};
  Set<String> _favorites = {};
  bool _isImporting = false;
  String? _remoteBookUrl;
  List<DownloadedBook> _downloadedBooks = [];

  Book? get book => _book;
  bool get isLoading => _isLoading;
  bool get hasBook => _book != null;
  int get currentChapterIndex => _currentChapterIndex;
  bool get isDarkMode => _isDarkMode;
  double get fontSize => _fontSize;
  Map<String, String> get notes => _notes;
  Set<String> get favorites => _favorites;
  bool get isImporting => _isImporting;
  String? get remoteBookUrl => _remoteBookUrl;
  List<DownloadedBook> get downloadedBooks => List.unmodifiable(_downloadedBooks);

  Chapter? get currentChapter {
    if (_book == null || _book!.chapters.isEmpty) {
      return null;
    }
    return _book!.chapters[_currentChapterIndex];
  }

  double get progress {
    if (_book == null || _book!.chapters.isEmpty) {
      return 0;
    }
    return (_currentChapterIndex + 1) / _book!.chapters.length;
  }

  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();

    final storedRemoteContent = await _storageService.loadRemoteBookJson();
    final loadedIndex = await _storageService.loadCurrentChapterIndex();
    final loadedDarkMode = await _storageService.loadDarkMode();
    final loadedFontSize = await _storageService.loadFontSize();
    final loadedNotes = await _storageService.loadNotes();
    final loadedFavorites = await _storageService.loadFavorites();
    final loadedRemoteUrl = await _storageService.loadRemoteBookUrl();
    final downloadedBooksJson = await _storageService.loadDownloadedBooksJson();

    Book loadedBook;
    if (storedRemoteContent != null && storedRemoteContent.trim().isNotEmpty) {
      try {
        loadedBook = _bookLoader.parseBookFromContent(
          rawContent: storedRemoteContent,
          sourceLabel: loadedRemoteUrl,
        );
      } catch (_) {
        loadedBook = await _bookLoader.loadBook();
        await _storageService.clearRemoteBookJson();
        await _storageService.clearRemoteBookUrl();
      }
    } else {
      loadedBook = await _bookLoader.loadBook();
    }

    _book = loadedBook;
    _currentChapterIndex = loadedIndex.clamp(0, _book!.chapters.length - 1);
    _isDarkMode = loadedDarkMode;
    _fontSize = loadedFontSize.clamp(14, 30);
    _notes = loadedNotes;
    _favorites = loadedFavorites;
    _remoteBookUrl = loadedRemoteUrl;
    _downloadedBooks = _decodeDownloadedBooks(downloadedBooksJson);

    _isLoading = false;
    notifyListeners();
  }

  Future<void> goToChapter(int index) async {
    if (_book == null) return;
    if (index < 0 || index >= _book!.chapters.length) return;

    _currentChapterIndex = index;
    notifyListeners();
    await _storageService.saveCurrentChapterIndex(_currentChapterIndex);
  }

  Future<void> nextChapter() async {
    await goToChapter(_currentChapterIndex + 1);
  }

  Future<void> previousChapter() async {
    await goToChapter(_currentChapterIndex - 1);
  }

  Future<void> toggleDarkMode() async {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
    await _storageService.saveDarkMode(_isDarkMode);
  }

  Future<void> setFontSize(double value) async {
    _fontSize = value.clamp(14, 30);
    notifyListeners();
    await _storageService.saveFontSize(_fontSize);
  }

  Future<void> saveNoteForChapter(String chapterId, String note) async {
    final trimmed = note.trim();
    if (trimmed.isEmpty) {
      _notes.remove(chapterId);
    } else {
      _notes[chapterId] = trimmed;
    }

    notifyListeners();
    await _storageService.saveNotes(_notes);
  }

  Future<void> deleteNoteForChapter(String chapterId) async {
    _notes.remove(chapterId);
    notifyListeners();
    await _storageService.saveNotes(_notes);
  }

  String noteForChapter(String chapterId) {
    return _notes[chapterId] ?? '';
  }

  bool isFavorite(String chapterId) {
    return _favorites.contains(chapterId);
  }

  Future<void> toggleFavorite(String chapterId) async {
    if (_favorites.contains(chapterId)) {
      _favorites.remove(chapterId);
    } else {
      _favorites.add(chapterId);
    }

    notifyListeners();
    await _storageService.saveFavorites(_favorites);
  }

  List<Chapter> get favoriteChapters {
    if (_book == null) return [];
    return _book!.chapters.where((chapter) => _favorites.contains(chapter.id)).toList();
  }

  Future<void> resetProgression() async {
    _currentChapterIndex = 0;
    _notes = {};
    _favorites = {};

    notifyListeners();
    await _storageService.resetProgress();
    await _storageService.saveCurrentChapterIndex(0);
  }

  Future<void> importBookFromUrl(String url) async {
    final trimmedUrl = url.trim();
    final rawContent = await _bookLoader.downloadRawBookContent(trimmedUrl);
    await importBookFromRawContent(
      rawContent: rawContent,
      sourceLabel: trimmedUrl,
    );
  }

  Future<void> importBookFromRawContent({
    required String rawContent,
    String? sourceLabel,
    String? formatHint,
  }) async {
    _isImporting = true;
    notifyListeners();

    try {
      final newBook = _bookLoader.parseBookFromContent(
        rawContent: rawContent,
        sourceLabel: sourceLabel,
        formatHint: formatHint,
      );
      final format = _resolveFormatFromHintOrSource(sourceLabel, formatHint);

      _book = newBook;
      _currentChapterIndex = 0;
      _notes = {};
      _favorites = {};
      _remoteBookUrl = sourceLabel;

      await _storageService.saveRemoteBookJson(rawContent);
      await _upsertDownloadedBook(
        rawJson: rawContent,
        title: newBook.title,
        author: newBook.author,
        sourceLabel: sourceLabel ?? 'Import local',
        format: format,
      );
      if (sourceLabel != null && sourceLabel.trim().isNotEmpty) {
        await _storageService.saveRemoteBookUrl(sourceLabel);
      } else {
        await _storageService.clearRemoteBookUrl();
      }
      await _storageService.resetProgress();
      await _storageService.saveCurrentChapterIndex(0);
    } finally {
      _isImporting = false;
      notifyListeners();
    }
  }

  Future<void> restoreBuiltInBook() async {
    _isImporting = true;
    notifyListeners();

    try {
      final builtIn = await _bookLoader.loadBook();
      _book = builtIn;
      _currentChapterIndex = 0;
      _notes = {};
      _favorites = {};
      _remoteBookUrl = null;

      await _storageService.clearRemoteBookJson();
      await _storageService.clearRemoteBookUrl();
      await _storageService.resetProgress();
      await _storageService.saveCurrentChapterIndex(0);
    } finally {
      _isImporting = false;
      notifyListeners();
    }
  }

  Future<void> loadBundledBook(String assetPath) async {
    _isImporting = true;
    notifyListeners();

    try {
      final bundledBook = await _bookLoader.loadBookFromAssetPath(assetPath);
      _book = bundledBook;
      _currentChapterIndex = 0;
      _notes = {};
      _favorites = {};
      _remoteBookUrl = null;

      await _storageService.clearRemoteBookJson();
      await _storageService.clearRemoteBookUrl();
      await _storageService.resetProgress();
      await _storageService.saveCurrentChapterIndex(0);
    } finally {
      _isImporting = false;
      notifyListeners();
    }
  }

  Future<void> openDownloadedBook(String downloadedBookId) async {
    final index = _downloadedBooks.indexWhere((b) => b.id == downloadedBookId);
    if (index == -1) return;
    final item = _downloadedBooks[index];

    await importBookFromRawContent(
      rawContent: item.rawJson,
      sourceLabel: item.sourceLabel,
      formatHint: item.format,
    );
  }

  Future<void> deleteDownloadedBook(String downloadedBookId) async {
    _downloadedBooks.removeWhere((b) => b.id == downloadedBookId);
    await _persistDownloadedBooks();
    notifyListeners();
  }

  List<DownloadedBook> _decodeDownloadedBooks(String? raw) {
    if (raw == null || raw.trim().isEmpty) {
      return [];
    }
    try {
      final decoded = jsonDecode(raw) as List<dynamic>;
      return decoded
          .map((entry) => DownloadedBook.fromJson(entry as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> _upsertDownloadedBook({
    required String rawJson,
    required String title,
    required String author,
    required String sourceLabel,
    required String format,
  }) async {
    final existingIndex = _downloadedBooks.indexWhere(
      (b) => b.title == title && b.author == author,
    );
    final now = DateTime.now().toIso8601String();
    if (existingIndex == -1) {
      _downloadedBooks.insert(
        0,
        DownloadedBook(
          id: '${DateTime.now().millisecondsSinceEpoch}_$title',
          title: title,
          author: author,
          sourceLabel: sourceLabel,
          rawJson: rawJson,
          format: format,
          savedAtIso: now,
        ),
      );
    } else {
      final previous = _downloadedBooks[existingIndex];
      _downloadedBooks[existingIndex] = DownloadedBook(
        id: previous.id,
        title: title,
        author: author,
        sourceLabel: sourceLabel,
        rawJson: rawJson,
        format: format,
        savedAtIso: now,
      );
      final updated = _downloadedBooks.removeAt(existingIndex);
      _downloadedBooks.insert(0, updated);
    }
    await _persistDownloadedBooks();
  }

  Future<void> _persistDownloadedBooks() async {
    final listJson = jsonEncode(_downloadedBooks.map((b) => b.toJson()).toList());
    await _storageService.saveDownloadedBooksJson(listJson);
  }

  String _resolveFormatFromHintOrSource(String? sourceLabel, String? formatHint) {
    final normalizedHint = formatHint?.toLowerCase().trim();
    if (normalizedHint == 'json' || normalizedHint == 'md' || normalizedHint == 'txt') {
      return normalizedHint!;
    }

    final source = (sourceLabel ?? '').toLowerCase();
    if (source.endsWith('.md') || source.endsWith('.markdown')) {
      return 'md';
    }
    if (source.endsWith('.txt')) {
      return 'txt';
    }
    return 'json';
  }
}
