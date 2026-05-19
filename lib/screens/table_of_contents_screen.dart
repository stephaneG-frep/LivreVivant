import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/reading_provider.dart';
import '../widgets/chapter_tile.dart';
import 'reader_screen.dart';

class TableOfContentsScreen extends StatelessWidget {
  const TableOfContentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ReadingProvider>(
      builder: (context, provider, _) {
        final book = provider.book;
        if (book == null) {
          return const Scaffold(
            body: Center(child: Text('Livre non chargé.')),
          );
        }

        return Scaffold(
          appBar: AppBar(title: const Text('Table des matières')),
          body: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    LinearProgressIndicator(value: provider.progress),
                    const SizedBox(height: 8),
                    Text(
                      'Dernier chapitre lu : ${book.chapters[provider.currentChapterIndex].title}',
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: book.chapters.length,
                  itemBuilder: (context, index) {
                    final chapter = book.chapters[index];
                    return ChapterTile(
                      title: chapter.title,
                      subtitle: 'Chapitre ${index + 1}',
                      isCurrent: index == provider.currentChapterIndex,
                      isFavorite: provider.isFavorite(chapter.id),
                      onTap: () async {
                        await provider.goToChapter(index);
                        if (!context.mounted) return;
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const ReaderScreen()),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
