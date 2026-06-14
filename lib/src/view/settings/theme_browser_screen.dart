import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lichess_mobile/src/model/settings/theme_preferences.dart';
import 'package:lichess_mobile/src/model/theme/theme_category.dart';
import 'package:lichess_mobile/src/model/theme/theme_manager.dart';
import 'package:lichess_mobile/src/model/theme/theme_palette.dart';
import 'package:lichess_mobile/src/utils/l10n_context.dart';
import 'package:lichess_mobile/src/utils/navigation.dart';
import 'package:lichess_mobile/src/utils/screen.dart';
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

    if (_selectedCategory != null) {
      themes = themes.where((t) => t.category == _selectedCategory).toList();
    }

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
    final theme = Theme.of(context);
    final prefs = ref.watch(themePreferencesProvider);
    final filteredThemes = _getFilteredThemes();
    final manager = ref.watch(themeManagerProvider);
    final favorites = manager.favoriteThemes;
    final recentThemes = manager.recentThemes;

    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.mobileTheme),
        actions: [
          if (_searchQuery.isNotEmpty || _selectedCategory != null)
            TextButton(
              onPressed: () {
                setState(() {
                  _searchController.clear();
                  _searchQuery = '';
                  _selectedCategory = null;
                });
              },
              child: const Text('Reset'),
            ),
        ],
      ),
      body: Column(
        children: [
          // Search and Filters
          Container(
            color: theme.colorScheme.surface,
            padding: const EdgeInsets.only(bottom: 8),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search 50+ themes...',
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
                      contentPadding: const EdgeInsets.symmetric(vertical: 0),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(28),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                    ),
                    onChanged: (value) => setState(() => _searchQuery = value),
                  ),
                ),
                SizedBox(
                  height: 40,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    children: [
                      _CategoryChip(
                        label: 'All',
                        isSelected: _selectedCategory == null,
                        onSelected: (_) => setState(() => _selectedCategory = null),
                      ),
                      ...ThemeCategory.values.map((category) {
                        return _CategoryChip(
                          label: category.label,
                          icon: category.icon,
                          isSelected: _selectedCategory == category,
                          onSelected: (_) => setState(() {
                            _selectedCategory = _selectedCategory == category ? null : category;
                          }),
                        );
                      }),
                    ],
                  ),
                ),
              ],
            ),
          ),

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
          Icon(Icons.search_off, size: 64, color: Theme.of(context).colorScheme.outline),
          const SizedBox(height: 16),
          Text('No matching themes', style: Theme.of(context).textTheme.titleMedium),
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
    final showSections = _searchQuery.isEmpty && _selectedCategory == null;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (showSections && favorites.isNotEmpty) ...[
          _SectionHeader(title: 'Favorites', icon: Icons.favorite, color: Colors.red),
          const SizedBox(height: 12),
          _ThemeCarousel(
            themes: favorites,
            prefs: prefs,
            onSelect: _selectTheme,
            onFavoriteToggle: _toggleFavorite,
          ),
          const SizedBox(height: 24),
        ],
        if (showSections && recentThemes.isNotEmpty) ...[
          _SectionHeader(title: 'Recently Used', icon: Icons.history),
          const SizedBox(height: 12),
          _ThemeCarousel(
            themes: recentThemes,
            prefs: prefs,
            onSelect: _selectTheme,
            onFavoriteToggle: _toggleFavorite,
          ),
          const SizedBox(height: 24),
        ],
        _SectionHeader(
          title: showSections ? 'Discover' : 'Search Results (${themes.length})',
          icon: showSections ? Icons.explore : Icons.manage_search,
        ),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: isTabletOrLarger(context) ? 3 : 2,
            childAspectRatio: 0.75,
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
        ),
      ],
    );
  }

  void _selectTheme(ThemePalette palette) {
    ref.read(themePreferencesProvider.notifier).selectTheme(palette.id);
    ref.read(themePreferencesProvider.notifier).addToRecent(palette.id);
    Feedback.forTap(context);
  }

  void _toggleFavorite(String themeId) {
    ref.read(themePreferencesProvider.notifier).toggleFavorite(themeId);
  }
}

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({
    required this.label,
    this.icon,
    required this.isSelected,
    required this.onSelected,
  });

  final String label;
  final IconData? icon;
  final bool isSelected;
  final ValueChanged<bool> onSelected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        avatar: icon != null ? Icon(icon, size: 16) : null,
        selected: isSelected,
        onSelected: onSelected,
        showCheckmark: false,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: Colors.transparent,
        selectedColor: theme.colorScheme.primaryContainer,
        side: BorderSide(
          color: isSelected ? theme.colorScheme.primary : theme.colorScheme.outline.withValues(alpha: 0.3),
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, required this.icon, this.color});
  final String title;
  final IconData icon;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(icon, size: 18, color: color ?? theme.colorScheme.primary),
        const SizedBox(width: 8),
        Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}

class _ThemeCarousel extends StatelessWidget {
  const _ThemeCarousel({
    required this.themes,
    required this.prefs,
    required this.onSelect,
    required this.onFavoriteToggle,
  });

  final List<ThemePalette> themes;
  final ThemePrefs prefs;
  final Function(ThemePalette) onSelect;
  final Function(String) onFavoriteToggle;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 220,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: themes.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final palette = themes[index];
          return SizedBox(
            width: 160,
            child: ThemePreviewCard(
              palette: palette,
              isSelected: prefs.currentThemeId == palette.id,
              isFavorite: prefs.isFavorite(palette.id),
              onTap: () => onSelect(palette),
              onFavoriteToggle: () => onFavoriteToggle(palette.id),
            ),
          );
        },
      ),
    );
  }
}
