import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static const String keyCurrentChapterIndex = 'current_chapter_index';
  static const String keyIsDarkMode = 'is_dark_mode';
  static const String keyFontSize = 'font_size';
  static const String keyNotes = 'notes_by_chapter';
  static const String keyFavorites = 'favorites_chapters';
  static const String keyRemoteBookJson = 'remote_book_json';
  static const String keyRemoteBookUrl = 'remote_book_url';

  Future<void> saveCurrentChapterIndex(int index) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(keyCurrentChapterIndex, index);
  }

  Future<int> loadCurrentChapterIndex() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(keyCurrentChapterIndex) ?? 0;
  }

  Future<void> saveDarkMode(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(keyIsDarkMode, value);
  }

  Future<bool> loadDarkMode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(keyIsDarkMode) ?? false;
  }

  Future<void> saveFontSize(double size) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(keyFontSize, size);
  }

  Future<double> loadFontSize() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble(keyFontSize) ?? 18;
  }

  Future<void> saveNotes(Map<String, String> notes) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(keyNotes, jsonEncode(notes));
  }

  Future<Map<String, String>> loadNotes() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(keyNotes);
    if (raw == null || raw.isEmpty) {
      return {};
    }

    final decoded = jsonDecode(raw) as Map<String, dynamic>;
    return decoded.map((key, value) => MapEntry(key, value as String));
  }

  Future<void> saveFavorites(Set<String> favorites) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(keyFavorites, favorites.toList());
  }

  Future<Set<String>> loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    return (prefs.getStringList(keyFavorites) ?? []).toSet();
  }

  Future<void> resetProgress() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(keyCurrentChapterIndex);
    await prefs.remove(keyNotes);
    await prefs.remove(keyFavorites);
  }

  Future<void> saveRemoteBookJson(String json) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(keyRemoteBookJson, json);
  }

  Future<String?> loadRemoteBookJson() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(keyRemoteBookJson);
  }

  Future<void> clearRemoteBookJson() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(keyRemoteBookJson);
  }

  Future<void> saveRemoteBookUrl(String url) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(keyRemoteBookUrl, url);
  }

  Future<String?> loadRemoteBookUrl() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(keyRemoteBookUrl);
  }

  Future<void> clearRemoteBookUrl() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(keyRemoteBookUrl);
  }
}
