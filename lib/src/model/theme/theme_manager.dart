import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lichess_mobile/src/model/settings/theme_preferences.dart';
import 'package:lichess_mobile/src/model/theme/theme_category.dart';
import 'package:lichess_mobile/src/model/theme/theme_colors.dart';
import 'package:lichess_mobile/src/model/theme/theme_palette.dart';

/// Provider for the theme manager.
final themeManagerProvider = Provider<ThemeManager>((ref) {
  final prefs = ref.watch(themePreferencesProvider);
  return ThemeManager(prefs: prefs);
});

/// Centralized theme management service.
class ThemeManager {
  final ThemePrefs prefs;

  ThemeManager({required this.prefs});

  /// Get the currently selected theme palette.
  ThemePalette? get currentTheme => ThemePalettes.getById(prefs.currentThemeId);

  /// Get all available themes.
  List<ThemePalette> get allThemes => ThemePalettes.all;

  /// Get favorite themes.
  List<ThemePalette> get favoriteThemes {
    return prefs.favorites
        .map((id) => ThemePalettes.getById(id))
        .whereType<ThemePalette>()
        .toList();
  }

  /// Get recently used themes.
  List<ThemePalette> get recentThemes {
    return prefs.recentThemeIds
        .map((id) => ThemePalettes.getById(id))
        .whereType<ThemePalette>()
        .toList();
  }

  /// Get themes by category.
  List<ThemePalette> getThemesByCategory(ThemeCategory category) {
    return ThemePalettes.getByCategory(category);
  }

  /// Search themes by query.
  List<ThemePalette> searchThemes(String query) {
    if (query.isEmpty) return allThemes;
    return ThemePalettes.search(query);
  }

  /// Get theme by ID.
  ThemePalette? getThemeById(String id) => ThemePalettes.getById(id);

  /// Get the color scheme for the current theme.
  ({ColorGenerator light, ColorGenerator dark}) getColorSchemes() {
    final palette = currentTheme;
    if (palette == null) {
      return (
        light: AppColorGenerator.generateLight,
        dark: AppColorGenerator.generateDark,
      );
    }
    return (
      light: AppColorGenerator.generateLight,
      dark: AppColorGenerator.generateDark,
    );
  }

  /// Get all categories.
  List<ThemeCategory> get categories => ThemeCategory.values;

  /// Get theme count by category.
  int getThemeCountForCategory(ThemeCategory category) {
    return ThemePalettes.getByCategory(category).length;
  }
}

/// Provider for current theme color scheme.
final currentThemeColorSchemeProvider = Provider<ColorGenerator>((ref) {
  final prefs = ref.watch(themePreferencesProvider);
  final palette = ThemePalettes.getById(prefs.currentThemeId);
  return AppColorGenerator.generateLight;
});

/// Provider for themes filtered by category.
final themesByCategoryProvider =
    Provider.family<List<ThemePalette>, ThemeCategory>((ref, category) {
  return ThemePalettes.getByCategory(category);
});

/// Provider for theme search results.
final themeSearchProvider = Provider.family<List<ThemePalette>, String>((ref, query) {
  return ThemePalettes.search(query);
});