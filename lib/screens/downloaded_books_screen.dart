import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/reading_provider.dart';
import 'reader_screen.dart';

class DownloadedBooksScreen extends StatelessWidget {
  const DownloadedBooksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ReadingProvider>(
      builder: (context, provider, _) {
        final books = provider.downloadedBooks;

        return Scaffold(
          appBar: AppBar(title: const Text('Livres téléchargés')),
          body: books.isEmpty
              ? const Center(
                  child: Text('Aucun livre importé pour le moment.'),
                )
              : ListView.builder(
                  itemCount: books.length,
                  itemBuilder: (context, index) {
                    final item = books[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: ListTile(
                        leading: const Icon(Icons.menu_book_rounded),
                        title: Text(
                          item.title,
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                        subtitle: Text('Par ${item.author}\nSource: ${item.sourceLabel}'),
                        isThreeLine: true,
                        onTap: () async {
                          await provider.openDownloadedBook(item.id);
                          if (!context.mounted) return;
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const ReaderScreen()),
                          );
                        },
                        trailing: IconButton(
                          icon: const Icon(Icons.delete_outline_rounded),
                          tooltip: 'Supprimer',
                          onPressed: () => _confirmDelete(context, provider, item.id, item.title),
                        ),
                      ),
                    );
                  },
                ),
        );
      },
    );
  }

  void _confirmDelete(
    BuildContext context,
    ReadingProvider provider,
    String id,
    String title,
  ) {
    showDialog<void>(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text('Supprimer le livre'),
          content: Text('Supprimer "$title" de la bibliothèque locale ?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Annuler'),
            ),
            FilledButton(
              onPressed: () async {
                await provider.deleteDownloadedBook(id);
                if (!context.mounted) return;
                Navigator.pop(context);
              },
              child: const Text('Supprimer'),
            ),
          ],
        );
      },
    );
  }
}
