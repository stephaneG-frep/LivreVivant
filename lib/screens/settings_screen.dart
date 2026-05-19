import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/reading_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ReadingProvider>(
      builder: (context, provider, _) {
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
