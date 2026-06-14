import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lichess_mobile/src/model/settings/theme_preferences.dart';
import 'package:lichess_mobile/src/model/theme/theme_category.dart';
import 'package:lichess_mobile/src/model/theme/theme_manager.dart';
import 'package:lichess_mobile/src/model/theme/theme_palette.dart';
import 'package:lichess_mobile/src/utils/l10n_context.dart';
import 'package:lichess_mobile/src/utils/navigation.dart';
import 'package:lichess_mobile/src/utils/screen.dart';
import 'package:lichess_mobile/src/widgets/adaptive_choice_picker.dart';
import 'package:lichess_mobile/src/widgets/list.dart';
import 'package:lichess_mobile/src/widgets/settings.dart';
import 'package:lichess_mobile/src/widgets/theme_preview_card.dart';

class ThemeBrowserScreen extends ConsumerStatefulWidget {
  const ThemeBrowserScreen({super.key});

  static Route<dynamic> buildRoute() {
    return buildScreenRoute(screen: const ThemeBrowserScreen());
  }

  @override
  ConsumerState<ThemeBrowserScreen> createState() => _ThemeBrowserScreenState();
}

class _ThemeBrowserScreenState extends ConsumerState<ThemeBrowserScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';
  ThemeCategory? _selectedCategory;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<ThemePalette> _getFilteredThemes() {
    var themes = ThemePalettes.all;

    // Filter by category
    if (_selectedCategory != null) {
      themes = themes.where((t) => t.category == _selectedCategory).toList();
    }

    // Filter by search query
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      themes = themes.where((t) {
        return t.name.toLowerCase().contains(query) ||
            t.colors.any((c) => c.name.toLowerCase().contains(query));
      }).toList();
    }

    return themes;
  }

  @override
  Widget build(BuildContext context) {
    final prefs = ref.watch(themePreferencesProvider);
    final filteredThemes = _getFilteredThemes();
    final favorites = ref.watch(themeManagerProvider).favoriteThemes;
    final recentThemes = ref.watch(themeManagerProvider).recentThemes;

    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.mobileTheme),
        animateColor: true,
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search themes...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
              ),
              onChanged: (value) => setState(() => _searchQuery = value),
            ),
          ),

          // Category filter chips
          SizedBox(
            height: 50,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: const Text('All'),
                    selected: _selectedCategory == null,
                    onSelected: (_) => setState(() => _selectedCategory = null),
                  ),
                ),
                ...ThemeCategory.values.map((category) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      avatar: Icon(category.icon, size: 18),
                      label: Text(category.label),
                      selected: _selectedCategory == category,
                      onSelected: (_) => setState(() {
                        _selectedCategory =
                            _selectedCategory == category ? null : category;
                      }),
                    ),
                  );
                }),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // Content
          Expanded(
            child: filteredThemes.isEmpty
                ? _buildEmptyState()
                : _buildThemeGrid(filteredThemes, prefs, favorites, recentThemes),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 64,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: 16),
          Text(
            'No themes found',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'Try a different search term or category',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildThemeGrid(
    List<ThemePalette> themes,
    ThemePrefs prefs,
    List<ThemePalette> favorites,
    List<ThemePalette> recentThemes,
  ) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Favorites section
        if (favorites.isNotEmpty && _searchQuery.isEmpty && _selectedCategory == null) ...[
          _buildSectionHeader('Favorites', Icons.favorite, Colors.red),
          const SizedBox(height: 8),
          _buildThemeGridView(favorites, prefs, compact: true),
          const SizedBox(height: 24),
        ],

        // Recently used section
        if (recentThemes.isNotEmpty && _searchQuery.isEmpty && _selectedCategory == null) ...[
          _buildSectionHeader('Recently Used', Icons.history, null),
          const SizedBox(height: 8),
          _buildThemeGridView(recentThemes, prefs, compact: true),
          const SizedBox(height: 24),
        ],

        // All themes section
        _buildSectionHeader(
          'All Themes (${themes.length})',
          Icons.palette,
          null,
        ),
        const SizedBox(height: 8),
        _buildThemeGridView(themes, prefs, compact: false),
      ],
    );
  }

  Widget _buildSectionHeader(String title, IconData icon, Color? iconColor) {
    return Row(
      children: [
        Icon(icon, size: 20, color: iconColor ?? Theme.of(context).colorScheme.primary),
        const SizedBox(width: 8),
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
      ],
    );
  }

  Widget _buildThemeGridView(List<ThemePalette> themes, ThemePrefs prefs, {required bool compact}) {
    if (compact) {
      return SizedBox(
        height: 160,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: themes.length,
          separatorBuilder: (_, __) => const SizedBox(width: 12),
          itemBuilder: (context, index) {
            final palette = themes[index];
            return SizedBox(
              width: 140,
              child: ThemePreviewCard(
                palette: palette,
                isSelected: prefs.currentThemeId == palette.id,
                isFavorite: prefs.isFavorite(palette.id),
                onTap: () => _selectTheme(palette),
                onFavoriteToggle: () => _toggleFavorite(palette.id),
              ),
            );
          },
        ),
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: isTabletOrLarger(context) ? 3 : 2,
        childAspectRatio: 0.85,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: themes.length,
      itemBuilder: (context, index) {
        final palette = themes[index];
        return ThemePreviewCard(
          palette: palette,
          isSelected: prefs.currentThemeId == palette.id,
          isFavorite: prefs.isFavorite(palette.id),
          onTap: () => _selectTheme(palette),
          onFavoriteToggle: () => _toggleFavorite(palette.id),
        );
      },
    );
  }

  void _selectTheme(ThemePalette palette) {
    ref.read(themePreferencesProvider.notifier).selectTheme(palette.id);
    ref.read(themePreferencesProvider.notifier).addToRecent(palette.id);

    // Show confirmation
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Theme "${palette.name}" applied'),
        duration: const Duration(seconds: 2),
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () {
            // Could implement undo functionality
          },
        ),
      ),
    );
  }

  void _toggleFavorite(String themeId) {
    ref.read(themePreferencesProvider.notifier).toggleFavorite(themeId);
  }
}