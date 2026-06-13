import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lichess_mobile/src/model/settings/theme_palette.dart';
import 'package:lichess_mobile/src/model/settings/theme_preferences.dart';
import 'package:lichess_mobile/src/view/settings/theme_details_screen.dart';

class ThemeBrowserScreen extends ConsumerStatefulWidget {
  const ThemeBrowserScreen({super.key});

  static Route<void> buildRoute() {
    return MaterialPageRoute(builder: (context) => const ThemeBrowserScreen());
  }

  @override
  ConsumerState<ThemeBrowserScreen> createState() => _ThemeBrowserScreenState();
}

class _ThemeBrowserScreenState extends ConsumerState<ThemeBrowserScreen> {
  String _searchQuery = '';
  ThemeCategory? _selectedCategory;

  @override
  Widget build(BuildContext context) {
    final themePrefs = ref.watch(themePreferencesProvider);
    final themeNotifier = ref.read(themePreferencesProvider.notifier);

    final filteredPalettes = ThemePalette.allPalettes.where((p) {
      final matchesSearch = p.name.toLowerCase().contains(
        _searchQuery.toLowerCase(),
      );
      final matchesCategory =
          _selectedCategory == null ||
          (_selectedCategory == ThemeCategory.favorites
              ? themePrefs.favoriteThemeIds.contains(p.id)
              : _selectedCategory == ThemeCategory.recent
              ? themePrefs.recentThemeIds.contains(p.id)
              : p.categories.contains(_selectedCategory));
      return matchesSearch && matchesCategory;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Theme Browser'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Reset to Default',
            onPressed: () => themeNotifier.selectTheme('electric'),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(110),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: TextField(
                  decoration: const InputDecoration(
                    hintText: 'Search themes...',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(12)),
                    ),
                  ),
                  onChanged: (value) => setState(() => _searchQuery = value),
                ),
              ),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Row(
                  children: ThemeCategory.values.map((category) {
                    final isSelected = _selectedCategory == category;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        label: Text(
                          category.name[0].toUpperCase() +
                              category.name.substring(1),
                        ),
                        selected: isSelected,
                        onSelected: (selected) {
                          setState(
                            () =>
                                _selectedCategory = selected ? category : null,
                          );
                        },
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
      ),
      body: filteredPalettes.isEmpty
          ? const Center(child: Text('No themes found.'))
          : GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 1.2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: filteredPalettes.length,
              itemBuilder: (context, index) {
                final palette = filteredPalettes[index];
                final isSelected = themePrefs.selectedThemeId == palette.id;
                final isFavorite = themePrefs.favoriteThemeIds.contains(
                  palette.id,
                );

                return ThemePreviewCard(
                  palette: palette,
                  isSelected: isSelected,
                  isFavorite: isFavorite,
                  onTap: () => Navigator.of(
                    context,
                  ).push(ThemeDetailsScreen.buildRoute(palette)),
                  onFavoriteTap: () => themeNotifier.toggleFavorite(palette.id),
                );
              },
            ),
    );
  }
}

class ThemePreviewCard extends StatelessWidget {
  const ThemePreviewCard({
    super.key,
    required this.palette,
    required this.isSelected,
    required this.isFavorite,
    required this.onTap,
    required this.onFavoriteTap,
  });

  final ThemePalette palette;
  final bool isSelected;
  final bool isFavorite;
  final VoidCallback onTap;
  final VoidCallback onFavoriteTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isSelected
            ? BorderSide(color: Theme.of(context).colorScheme.primary, width: 3)
            : BorderSide.none,
      ),
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
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
                child: Stack(
                  children: [
                    if (isSelected)
                      const Positioned(
                        top: 8,
                        right: 8,
                        child: Icon(Icons.check_circle, color: Colors.white),
                      ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: IconButton(
                        icon: Icon(
                          isFavorite ? Icons.favorite : Icons.favorite_border,
                          color: isFavorite ? Colors.red : Colors.white,
                        ),
                        onPressed: onFavoriteTap,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                palette.name,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
