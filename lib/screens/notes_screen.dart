import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/reading_provider.dart';

class NotesScreen extends StatelessWidget {
  const NotesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ReadingProvider>(
      builder: (context, provider, _) {
        final book = provider.book;
        if (book == null) {
          return const Scaffold(body: Center(child: Text('Livre non chargé.')));
        }

        final notesEntries = provider.notes.entries.toList();

        return Scaffold(
          appBar: AppBar(title: const Text('Mes notes')),
          body: notesEntries.isEmpty
              ? const Center(child: Text('Aucune note pour le moment.'))
              : ListView.builder(
                  itemCount: notesEntries.length,
                  itemBuilder: (context, index) {
                    final entry = notesEntries[index];
                    final chapterIndex = book.chapters.indexWhere((c) => c.id == entry.key);
                    final chapterTitle = chapterIndex == -1 ? entry.key : book.chapters[chapterIndex].title;

                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      child: ListTile(
                        title: Text(chapterTitle, style: const TextStyle(fontWeight: FontWeight.w700)),
                        subtitle: Text(entry.value, maxLines: 3, overflow: TextOverflow.ellipsis),
                        trailing: PopupMenuButton<String>(
                          onSelected: (value) {
                            if (value == 'edit') {
                              _showEditDialog(context, provider, entry.key, entry.value);
                            } else if (value == 'delete') {
                              provider.deleteNoteForChapter(entry.key);
                            }
                          },
                          itemBuilder: (_) => const [
                            PopupMenuItem(value: 'edit', child: Text('Modifier')),
                            PopupMenuItem(value: 'delete', child: Text('Supprimer')),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        );
      },
    );
  }

  void _showEditDialog(
    BuildContext context,
    ReadingProvider provider,
    String chapterId,
    String initialValue,
  ) {
    final controller = TextEditingController(text: initialValue);

    showDialog<void>(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text('Modifier la note'),
          content: TextField(
            controller: controller,
            maxLines: 8,
            decoration: const InputDecoration(border: OutlineInputBorder()),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Annuler'),
            ),
            FilledButton(
              onPressed: () async {
                await provider.saveNoteForChapter(chapterId, controller.text);
                if (!context.mounted) return;
                Navigator.pop(context);
              },
              child: const Text('Sauvegarder'),
            ),
          ],
        );
      },
    );
  }
}
