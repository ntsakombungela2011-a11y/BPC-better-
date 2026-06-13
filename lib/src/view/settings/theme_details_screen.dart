import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lichess_mobile/src/model/settings/theme_palette.dart';
import 'package:lichess_mobile/src/model/settings/theme_preferences.dart';

class ThemeDetailsScreen extends ConsumerWidget {
  const ThemeDetailsScreen({super.key, required this.palette});

  final ThemePalette palette;

  static Route<void> buildRoute(ThemePalette palette) {
    return MaterialPageRoute(
      builder: (context) => ThemeDetailsScreen(palette: palette),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themePrefs = ref.watch(themePreferencesProvider);
    final themeNotifier = ref.read(themePreferencesProvider.notifier);
    final isSelected = themePrefs.selectedThemeId == palette.id;
    final isFavorite = themePrefs.favoriteThemeIds.contains(palette.id);

    return Scaffold(
      appBar: AppBar(
        title: Text(palette.name),
        actions: [
          IconButton(
            icon: Icon(isFavorite ? Icons.favorite : Icons.favorite_border),
            color: isFavorite ? Colors.red : null,
            onPressed: () => themeNotifier.toggleFavorite(palette.id),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              height: 200,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: LinearGradient(
                  colors: palette.colors.length > 1
                      ? palette.colors
                      : [
                          palette.primary,
                          palette.primary.withValues(alpha: 0.7),
                        ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              palette.name,
              style: Theme.of(
                context,
              ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              children: palette.categories
                  .map((c) => Chip(label: Text(c.name)))
                  .toList(),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: isSelected
                  ? null
                  : () => themeNotifier.selectTheme(palette.id),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: palette.primary,
                foregroundColor: Colors.white,
              ),
              child: Text(isSelected ? 'Currently Applied' : 'Apply Theme'),
            ),
          ],
        ),
      ),
    );
  }
}
