import 'package:flutter/material.dart';

import '../models/book.dart';
import '../models/chapter.dart';
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

  Book? get book => _book;
  bool get isLoading => _isLoading;
  bool get hasBook => _book != null;
  int get currentChapterIndex => _currentChapterIndex;
  bool get isDarkMode => _isDarkMode;
  double get fontSize => _fontSize;
  Map<String, String> get notes => _notes;
  Set<String> get favorites => _favorites;

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

    final loadedBook = await _bookLoader.loadBook();
    final loadedIndex = await _storageService.loadCurrentChapterIndex();
    final loadedDarkMode = await _storageService.loadDarkMode();
    final loadedFontSize = await _storageService.loadFontSize();
    final loadedNotes = await _storageService.loadNotes();
    final loadedFavorites = await _storageService.loadFavorites();

    _book = loadedBook;
    _currentChapterIndex = loadedIndex.clamp(0, _book!.chapters.length - 1);
    _isDarkMode = loadedDarkMode;
    _fontSize = loadedFontSize.clamp(14, 30);
    _notes = loadedNotes;
    _favorites = loadedFavorites;

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
}
