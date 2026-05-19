import 'package:flutter/material.dart';

class ChapterTile extends StatelessWidget {
  const ChapterTile({
    super.key,
    required this.title,
    required this.subtitle,
    required this.isCurrent,
    required this.isFavorite,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final bool isCurrent;
  final bool isFavorite;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: isCurrent ? colorScheme.primaryContainer : colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(18),
      ),
      child: ListTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        onTap: onTap,
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
        subtitle: Text(subtitle),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isFavorite)
              Icon(Icons.favorite_rounded, color: colorScheme.error),
            if (isCurrent)
              Padding(
                padding: const EdgeInsets.only(left: 8),
                child: Icon(Icons.play_arrow_rounded, color: colorScheme.primary),
              ),
          ],
        ),
      ),
    );
  }
}
