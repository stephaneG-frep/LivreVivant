import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/reading_provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final TextEditingController _urlController = TextEditingController();

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ReadingProvider>(
      builder: (context, provider, _) {
        final currentUrl = provider.remoteBookUrl;
        if (_urlController.text.isEmpty && currentUrl != null) {
          _urlController.text = currentUrl;
        }

        return Scaffold(
          appBar: AppBar(title: const Text('Réglages')),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text('Taille de texte : ${provider.fontSize.toStringAsFixed(0)}'),
              Slider(
                value: provider.fontSize,
                min: 14,
                max: 30,
                divisions: 16,
                onChanged: provider.setFontSize,
              ),
              const SizedBox(height: 8),
              SwitchListTile(
                value: provider.isDarkMode,
                title: const Text('Mode sombre'),
                onChanged: (_) => provider.toggleDarkMode(),
              ),
              const SizedBox(height: 18),
              Text(
                'Importer un livre depuis une URL (JSON/MD/TXT)',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _urlController,
                keyboardType: TextInputType.url,
                decoration: const InputDecoration(
                  hintText: 'https://exemple.com/mon_livre.json | .md | .txt',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              FilledButton.icon(
                onPressed: provider.isImporting
                    ? null
                    : () => _importFromUrl(context, provider),
                icon: provider.isImporting
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.download_rounded),
                label: const Text('Télécharger et utiliser ce livre'),
              ),
              const SizedBox(height: 10),
              OutlinedButton.icon(
                onPressed: provider.isImporting
                    ? null
                    : () => _importFromSmartphoneFile(context, provider),
                icon: const Icon(Icons.upload_file_rounded),
                label: const Text('Importer JSON/MD/TXT depuis le smartphone'),
              ),
              const SizedBox(height: 10),
              OutlinedButton.icon(
                onPressed: provider.isImporting
                    ? null
                    : () => _restoreBuiltIn(context, provider),
                icon: const Icon(Icons.restore_rounded),
                label: const Text('Revenir au livre intégré'),
              ),
              const SizedBox(height: 10),
              OutlinedButton.icon(
                onPressed: provider.isImporting
                    ? null
                    : () => _loadGitHubBook(context, provider),
                icon: const Icon(Icons.menu_book_rounded),
                label: const Text('Charger mon livre Git/GitHub (local)'),
              ),
              const SizedBox(height: 10),
              OutlinedButton.icon(
                onPressed: provider.isImporting
                    ? null
                    : () => _loadBashBook(context, provider),
                icon: const Icon(Icons.terminal_rounded),
                label: const Text('Charger le livre Bash Linux (local)'),
              ),
              const SizedBox(height: 10),
              OutlinedButton.icon(
                onPressed: provider.isImporting
                    ? null
                    : () => _loadEthicalHackingBook(context, provider),
                icon: const Icon(Icons.security_rounded),
                label: const Text('Charger le livre Hacking Éthique (local)'),
              ),
              if (currentUrl != null) ...[
                const SizedBox(height: 8),
                Text('Livre externe actuel : $currentUrl'),
              ],
              const SizedBox(height: 16),
              FilledButton.tonal(
                onPressed: () => _showResetDialog(context, provider),
                child: const Text('Réinitialiser la progression'),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _importFromUrl(BuildContext context, ReadingProvider provider) async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      await provider.importBookFromUrl(_urlController.text);
      if (!context.mounted) return;
      messenger.showSnackBar(
        const SnackBar(content: Text('Livre téléchargé et chargé avec succès.')),
      );
    } catch (error) {
      if (!context.mounted) return;
      messenger.showSnackBar(
        SnackBar(content: Text('Erreur import: $error')),
      );
    }
  }

  Future<void> _importFromSmartphoneFile(
    BuildContext context,
    ReadingProvider provider,
  ) async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      final picked = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: const ['json', 'md', 'markdown', 'txt'],
        allowMultiple: false,
        withData: true,
      );

      if (picked == null || picked.files.isEmpty) {
        return;
      }

      final file = picked.files.first;
      String rawContent;
      if (file.bytes != null) {
        rawContent = utf8.decode(file.bytes!);
      } else if (file.path != null) {
        rawContent = await File(file.path!).readAsString();
      } else {
        throw Exception('Impossible de lire le fichier sélectionné.');
      }

      await provider.importBookFromRawContent(
        rawContent: rawContent,
        sourceLabel: file.name,
      );
      if (!context.mounted) return;
      messenger.showSnackBar(
        SnackBar(content: Text('Livre importé depuis ${file.name}.')),
      );
    } catch (error) {
      if (!context.mounted) return;
      messenger.showSnackBar(
        SnackBar(content: Text('Erreur import fichier: $error')),
      );
    }
  }

  Future<void> _restoreBuiltIn(BuildContext context, ReadingProvider provider) async {
    await provider.restoreBuiltInBook();
    if (!context.mounted) return;
    _urlController.clear();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Livre intégré restauré.')),
    );
  }

  Future<void> _loadGitHubBook(BuildContext context, ReadingProvider provider) async {
    await provider.loadBundledBook('assets/books/mon_livre_github.json');
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Livre Git/GitHub local chargé.')),
    );
  }

  Future<void> _loadBashBook(BuildContext context, ReadingProvider provider) async {
    await provider.loadBundledBook('assets/books/livre_pedagogique_bash_linux.md');
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Livre Bash Linux local chargé.')),
    );
  }

  Future<void> _loadEthicalHackingBook(BuildContext context, ReadingProvider provider) async {
    await provider.loadBundledBook('assets/books/hacking_etique.md');
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Livre Hacking Éthique local chargé.')),
    );
  }

  void _showResetDialog(BuildContext context, ReadingProvider provider) {
    showDialog<void>(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text('Réinitialisation'),
          content: const Text(
            'Cette action supprime la progression, les notes et les favoris. Continuer ?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Annuler'),
            ),
            FilledButton(
              onPressed: () async {
                await provider.resetProgression();
                if (!context.mounted) return;
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Progression réinitialisée.')),
                );
              },
              child: const Text('Confirmer'),
            ),
          ],
        );
      },
    );
  }
}
