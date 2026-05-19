import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/reading_provider.dart';
import 'reader_screen.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ReadingProvider>(
      builder: (context, provider, _) {
        final favorites = provider.favoriteChapters;
        final book = provider.book;

        if (book == null) {
          return const Scaffold(body: Center(child: Text('Livre non chargé.')));
        }

        return Scaffold(
          appBar: AppBar(title: const Text('Chapitres favoris')),
          body: favorites.isEmpty
              ? const Center(child: Text('Aucun favori pour le moment.'))
              : ListView.builder(
                  itemCount: favorites.length,
                  itemBuilder: (context, index) {
                    final chapter = favorites[index];
                    final chapterIndex = book.chapters.indexWhere((c) => c.id == chapter.id);

                    return ListTile(
                      leading: const Icon(Icons.favorite_rounded),
                      title: Text(chapter.title),
                      onTap: () async {
                        await provider.goToChapter(chapterIndex);
                        if (!context.mounted) return;
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const ReaderScreen()),
                        );
                      },
                    );
                  },
                ),
        );
      },
    );
  }
}
