import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:lichess_mobile/src/model/settings/preferences_storage.dart';

part 'theme_preferences.freezed.dart';
part 'theme_preferences.g.dart';

/// Provider for theme preferences.
final themePreferencesProvider =
    NotifierProvider<ThemePreferencesNotifier, ThemePrefs>(
  ThemePreferencesNotifier.new,
  name: 'ThemePreferencesProvider',
);

class ThemePreferencesNotifier extends Notifier<ThemePrefs> with PreferencesStorage<ThemePrefs> {
  @override
  @protected
  final prefCategory = PrefCategory.general;

  @override
  ThemePrefs get defaults => ThemePrefs.defaults;

  @override
  ThemePrefs fromJson(Map<String, dynamic> json) => ThemePrefs.fromJson(json);

  @override
  ThemePrefs build() {
    return fetch();
  }

  /// Select a new theme by ID.
  Future<void> selectTheme(String themeId) async {
    await save(state.copyWith(currentThemeId: themeId));
  }

  /// Toggle a theme as favorite.
  Future<void> toggleFavorite(String themeId) async {
    final favorites = List<String>.from(state.favorites);
    if (favorites.contains(themeId)) {
      favorites.remove(themeId);
    } else {
      favorites.add(themeId);
    }
    await save(state.copyWith(favorites: favorites));
  }

  /// Add a theme to the recently used list.
  Future<void> addToRecent(String themeId) async {
    final recent = List<String>.from(state.recentThemeIds);
    recent.remove(themeId);
    recent.insert(0, themeId);
    // Keep only the last 10 recent themes
    if (recent.length > 10) {
      recent.removeRange(10, recent.length);
    }
    await save(state.copyWith(recentThemeIds: recent));
  }

  /// Reset to default theme.
  Future<void> resetToDefault() async {
    await save(ThemePrefs.defaults);
  }
}

/// Theme preferences data class.
@Freezed(fromJson: true, toJson: true)
sealed class ThemePrefs with _$ThemePrefs implements Serializable {
  const ThemePrefs._();

  const factory ThemePrefs({
    /// The currently selected theme ID.
    @JsonKey(defaultValue: 'luxury_noir') required String currentThemeId,

    /// List of favorite theme IDs.
    @JsonKey(defaultValue: []) required List<String> favorites,

    /// Recently used theme IDs (most recent first).
    @JsonKey(defaultValue: []) required List<String> recentThemeIds,
  }) = _ThemePrefs;

  static const defaults = ThemePrefs(
    currentThemeId: 'luxury_noir',
    favorites: [],
    recentThemeIds: [],
  );

  factory ThemePrefs.fromJson(Map<String, dynamic> json) {
    return _$ThemePrefsFromJson(json);
  }

  /// Check if a theme is in favorites.
  bool isFavorite(String themeId) => favorites.contains(themeId);
}