import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lichess_mobile/src/model/settings/preferences_storage.dart';
import 'package:lichess_mobile/src/model/settings/theme_palette.dart';

class ThemePrefs implements Serializable {
  final String selectedThemeId;
  final List<String> favoriteThemeIds;
  final List<String> recentThemeIds;

  const ThemePrefs({
    required this.selectedThemeId,
    this.favoriteThemeIds = const [],
    this.recentThemeIds = const [],
  });

  ThemePrefs copyWith({
    String? selectedThemeId,
    List<String>? favoriteThemeIds,
    List<String>? recentThemeIds,
  }) {
    return ThemePrefs(
      selectedThemeId: selectedThemeId ?? this.selectedThemeId,
      favoriteThemeIds: favoriteThemeIds ?? this.favoriteThemeIds,
      recentThemeIds: recentThemeIds ?? this.recentThemeIds,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'selectedThemeId': selectedThemeId,
    'favoriteThemeIds': favoriteThemeIds,
    'recentThemeIds': recentThemeIds,
  };

  factory ThemePrefs.fromJson(Map<String, dynamic> json) {
    return ThemePrefs(
      selectedThemeId: json['selectedThemeId'] as String,
      favoriteThemeIds:
          (json['favoriteThemeIds'] as List<dynamic>?)?.cast<String>() ?? [],
      recentThemeIds:
          (json['recentThemeIds'] as List<dynamic>?)?.cast<String>() ?? [],
    );
  }
}

final themePreferencesProvider =
    NotifierProvider<ThemePreferencesNotifier, ThemePrefs>(
      ThemePreferencesNotifier.new,
      name: 'ThemePreferencesProvider',
    );

class ThemePreferencesNotifier extends Notifier<ThemePrefs>
    with PreferencesStorage<ThemePrefs> {
  @override
  @protected
  PrefCategory get prefCategory => PrefCategory.theme;

  @override
  @protected
  ThemePrefs get defaults => const ThemePrefs(selectedThemeId: 'electric');

  @override
  ThemePrefs fromJson(Map<String, dynamic> json) => ThemePrefs.fromJson(json);

  @override
  ThemePrefs build() {
    return fetch();
  }

  Future<void> selectTheme(String themeId) async {
    final recent = List<String>.from(state.recentThemeIds);
    recent.remove(themeId);
    recent.insert(0, themeId);
    if (recent.length > 10) {
      recent.removeLast();
    }
    await save(
      state.copyWith(selectedThemeId: themeId, recentThemeIds: recent),
    );
  }

  Future<void> toggleFavorite(String themeId) async {
    final favorites = List<String>.from(state.favoriteThemeIds);
    if (favorites.contains(themeId)) {
      favorites.remove(themeId);
    } else {
      favorites.add(themeId);
    }
    await save(state.copyWith(favoriteThemeIds: favorites));
  }

  ThemePalette get currentPalette {
    return ThemePalette.allPalettes.firstWhere(
      (p) => p.id == state.selectedThemeId,
      orElse: () => ThemePalette.allPalettes.first,
    );
  }

  ColorScheme generateColorScheme(Brightness brightness) {
    final palette = currentPalette;
    final isDark = brightness == Brightness.dark;

    // Base colors from palette
    final primary = palette.primary;
    final secondary = palette.secondary;
    final surface =
        palette.background ??
        (isDark ? const Color(0xFF121212) : const Color(0xFFF5F5F5));

    // Create a base scheme from seed
    final baseScheme = ColorScheme.fromSeed(
      seedColor: primary,
      brightness: brightness,
    );

    return baseScheme.copyWith(
      primary: primary,
      onPrimary: _getContrastingColor(primary),
      secondary: secondary,
      onSecondary: _getContrastingColor(secondary),
      surface: surface,
      onSurface: _getContrastingColor(surface),
      error: const Color(0xFFB00020),
      onError: Colors.white,
    );
  }

  Color _getContrastingColor(Color color) {
    return ThemeData.estimateBrightnessForColor(color) == Brightness.dark
        ? Colors.white
        : Colors.black;
  }
}
