import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/reading_provider.dart';
import '../widgets/app_drawer.dart';
import 'reader_screen.dart';
import 'table_of_contents_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Offset _coverOffset = Offset.zero;

  @override
  Widget build(BuildContext context) {
    return Consumer<ReadingProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        final book = provider.book;
        if (book == null) {
          return const Scaffold(
            body: Center(child: Text('Impossible de charger le livre.')),
          );
        }

        return Scaffold(
          drawer: const AppDrawer(),
          appBar: AppBar(
            title: const Text('LivreVivant'),
            centerTitle: true,
          ),
          body: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Theme.of(context).brightness == Brightness.dark
                      ? const Color(0xFF352A22)
                      : const Color(0xFFF6E7D3),
                  Theme.of(context).brightness == Brightness.dark
                      ? const Color(0xFF261F1B)
                      : const Color(0xFFFDF4E6),
                  Theme.of(context).brightness == Brightness.dark
                      ? const Color(0xFF1F1A17)
                      : const Color(0xFFFFFCF7),
                ],
              ),
            ),
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                MouseRegion(
                  onHover: (event) {
                    final x = (event.localPosition.dx - 140) / 50;
                    final y = (event.localPosition.dy - 140) / 50;
                    setState(() {
                      _coverOffset = Offset(x.clamp(-6, 6), y.clamp(-6, 6));
                    });
                  },
                  onExit: (_) => setState(() => _coverOffset = Offset.zero),
                  child: Hero(
                    tag: 'book_cover',
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      transform: Matrix4.identity()
                        ..translateByDouble(_coverOffset.dx, _coverOffset.dy, 0, 1),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(24),
                        child: Image.asset(
                          book.cover,
                          height: 260,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  book.title,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Par ${book.author}',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 16),
                Text(
                  book.description,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: () async {
                    await provider.goToChapter(0);
                    if (!context.mounted) return;
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const ReaderScreen()),
                    );
                  },
                  child: const Text('Commencer'),
                ),
                const SizedBox(height: 12),
                OutlinedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const ReaderScreen()),
                    );
                  },
                  child: const Text('Continuer la lecture'),
                ),
                const SizedBox(height: 12),
                TextButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const TableOfContentsScreen(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.list_alt_rounded),
                  label: const Text('Voir la table des matières'),
                ),
                const SizedBox(height: 12),
                LinearProgressIndicator(value: provider.progress),
                const SizedBox(height: 8),
                Text(
                  'Progression : ${(provider.progress * 100).toStringAsFixed(0)}%',
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
