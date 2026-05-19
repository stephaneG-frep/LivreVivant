import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:provider/provider.dart';

import '../providers/reading_provider.dart';
import '../widgets/reader_controls.dart';

class ReaderScreen extends StatefulWidget {
  const ReaderScreen({super.key});

  @override
  State<ReaderScreen> createState() => _ReaderScreenState();
}

class _ReaderScreenState extends State<ReaderScreen> {
  bool _immersive = false;

  @override
  Widget build(BuildContext context) {
    return Consumer<ReadingProvider>(
      builder: (context, provider, _) {
        final book = provider.book;
        final chapter = provider.currentChapter;

        if (book == null || chapter == null) {
          return const Scaffold(body: Center(child: Text('Chapitre introuvable.')));
        }

        final canGoPrevious = provider.currentChapterIndex > 0;
        final canGoNext = provider.currentChapterIndex < book.chapters.length - 1;

        return Scaffold(
          appBar: _immersive
              ? null
              : AppBar(
                  title: Text(chapter.title),
                  actions: [
                    IconButton(
                      onPressed: () => _showFontSizeSheet(context, provider),
                      icon: const Icon(Icons.format_size_rounded),
                      tooltip: 'Taille de police',
                    ),
                    IconButton(
                      onPressed: provider.toggleDarkMode,
                      icon: Icon(
                        provider.isDarkMode
                            ? Icons.light_mode_rounded
                            : Icons.dark_mode_rounded,
                      ),
                      tooltip: 'Mode clair / sombre',
                    ),
                  ],
                ),
          body: SafeArea(
            child: GestureDetector(
              onTap: () => setState(() => _immersive = !_immersive),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: provider.isDarkMode
                        ? const [Color(0xFF2D2621), Color(0xFF1E1A17)]
                        : const [Color(0xFFF8EBD9), Color(0xFFFFF9EF)],
                  ),
                ),
                padding: EdgeInsets.fromLTRB(16, _immersive ? 18 : 8, 16, 16),
                child: Column(
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      margin: const EdgeInsets.only(bottom: 10),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: LinearProgressIndicator(
                          minHeight: _immersive ? 0 : 6,
                          value: provider.progress,
                        ),
                      ),
                    ),
                    Expanded(
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 350),
                        switchInCurve: Curves.easeOutCubic,
                        switchOutCurve: Curves.easeInCubic,
                        transitionBuilder: (child, animation) {
                          return AnimatedBuilder(
                            animation: animation,
                            child: child,
                            builder: (context, animatedChild) {
                              final angle = (1 - animation.value) * 0.18 * math.pi;
                              final tilt = (1 - animation.value) * 0.012;
                              final transform = Matrix4.identity()
                                ..setEntry(3, 2, 0.0012)
                                ..rotateY(angle)
                                ..translateByDouble(
                                  (1 - animation.value) * 18,
                                  tilt * 100,
                                  0,
                                  1,
                                );

                              return Opacity(
                                opacity: animation.value.clamp(0, 1),
                                child: Transform(
                                  alignment: Alignment.centerLeft,
                                  transform: transform,
                                  child: animatedChild,
                                ),
                              );
                            },
                          );
                        },
                        child: Container(
                          key: ValueKey(chapter.id),
                          width: double.infinity,
                          padding: const EdgeInsets.fromLTRB(14, 8, 14, 4),
                          decoration: BoxDecoration(
                            color: provider.isDarkMode
                                ? Colors.black.withValues(alpha: 0.14)
                                : Colors.white.withValues(alpha: 0.50),
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(
                              color: provider.isDarkMode
                                  ? Colors.white.withValues(alpha: 0.08)
                                  : const Color(0xFFE2D3BC),
                            ),
                          ),
                          child: Markdown(
                            data: chapter.content,
                            physics: const BouncingScrollPhysics(),
                            styleSheet:
                                MarkdownStyleSheet.fromTheme(Theme.of(context)).copyWith(
                              p: TextStyle(height: 1.68, fontSize: provider.fontSize),
                              h1: TextStyle(
                                fontSize: provider.fontSize + 8,
                                fontWeight: FontWeight.w800,
                              ),
                              h2: TextStyle(
                                fontSize: provider.fontSize + 5,
                                fontWeight: FontWeight.w700,
                              ),
                              blockquotePadding:
                                  const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            ),
                          ),
                        ),
                      ),
                    ),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 250),
                      child: _immersive
                          ? const SizedBox.shrink()
                          : Column(
                              key: const ValueKey('reader_controls'),
                              children: [
                                Row(
                                  children: [
                                    IconButton.filledTonal(
                                      onPressed: () =>
                                          _showNoteDialog(context, provider, chapter.id),
                                      icon: const Icon(Icons.sticky_note_2_rounded),
                                      tooltip: 'Note du chapitre',
                                    ),
                                    const SizedBox(width: 10),
                                    IconButton.filledTonal(
                                      onPressed: () => provider.toggleFavorite(chapter.id),
                                      icon: Icon(
                                        provider.isFavorite(chapter.id)
                                            ? Icons.favorite_rounded
                                            : Icons.favorite_border_rounded,
                                      ),
                                      tooltip: 'Favori',
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                ReaderControls(
                                  onPrevious: provider.previousChapter,
                                  onNext: provider.nextChapter,
                                  canGoPrevious: canGoPrevious,
                                  canGoNext: canGoNext,
                                ),
                              ],
                            ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _showFontSizeSheet(BuildContext context, ReadingProvider provider) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Taille du texte', style: TextStyle(fontWeight: FontWeight.w700)),
              Slider(
                value: provider.fontSize,
                min: 14,
                max: 30,
                divisions: 16,
                label: provider.fontSize.toStringAsFixed(0),
                onChanged: (value) => provider.setFontSize(value),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showNoteDialog(BuildContext context, ReadingProvider provider, String chapterId) {
    final controller = TextEditingController(text: provider.noteForChapter(chapterId));

    showDialog<void>(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text('Note personnelle'),
          content: TextField(
            controller: controller,
            maxLines: 8,
            decoration: const InputDecoration(
              hintText: 'Écris ta note ici...',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Annuler'),
            ),
            FilledButton(
              onPressed: () async {
                await provider.saveNoteForChapter(chapterId, controller.text);
                if (!context.mounted) return;
                Navigator.pop(context);
              },
              child: const Text('Enregistrer'),
            ),
          ],
        );
      },
    );
  }
}
