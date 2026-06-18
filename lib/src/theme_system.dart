import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:lichess_mobile/src/binding.dart';
import 'package:shared_preferences/shared_preferences.dart';

const String kThemeSelectionStorageKey = 'theme_system.selected_theme_id';
const String kThemeFavoritesStorageKey = 'theme_system.favorite_theme_ids';
const String kThemeRecentStorageKey = 'theme_system.recent_theme_ids';
const int kMaxRecentThemes = 8;

@immutable
class ThemePalette {
  const ThemePalette({required this.primary, required this.secondary, Color? tertiary, Color? neutral, Color? background})
    : tertiary = tertiary ?? secondary,
      neutral = neutral ?? primary,
      background = background ?? primary;

  final Color primary;
  final Color secondary;
  final Color tertiary;
  final Color neutral;
  final Color background;
}

enum ThemeCategory { vibrant, natural, luxury, minimal, dark, pastel, classic }

@immutable
class ThemeModel {
  const ThemeModel({required this.id, required this.name, required this.category, required this.palette});

  final String id;
  final String name;
  final ThemeCategory category;
  final ThemePalette palette;

  ColorScheme colorScheme(Brightness brightness) => _SchemeCache.schemeFor(this, brightness);

  bool matches(String query) {
    final normalized = query.trim().toLowerCase();
    return normalized.isEmpty ||
        name.toLowerCase().contains(normalized) ||
        id.contains(normalized) ||
        category.name.contains(normalized);
  }
}

class _SchemeCache {
  static final Map<String, ColorScheme> _schemes = <String, ColorScheme>{};

  static ColorScheme schemeFor(ThemeModel theme, Brightness brightness) {
    final key = '${theme.id}.${brightness.name}';
    return _schemes.putIfAbsent(key, () => _buildScheme(theme.palette, brightness));
  }

  static ColorScheme _buildScheme(ThemePalette palette, Brightness brightness) {
    final base = ColorScheme.fromSeed(seedColor: palette.primary, brightness: brightness);
    final surfaceSeed = ColorScheme.fromSeed(seedColor: palette.background, brightness: brightness, dynamicSchemeVariant: DynamicSchemeVariant.neutral);
    final primaryContainer = Color.lerp(palette.primary, surfaceSeed.surface, brightness == Brightness.dark ? 0.45 : 0.78)!;
    final secondaryContainer = Color.lerp(palette.secondary, surfaceSeed.surface, brightness == Brightness.dark ? 0.45 : 0.78)!;
    final tertiaryContainer = Color.lerp(palette.tertiary, surfaceSeed.surface, brightness == Brightness.dark ? 0.45 : 0.78)!;
    return base.copyWith(
      brightness: brightness,
      primary: palette.primary,
      onPrimary: _on(palette.primary),
      primaryContainer: primaryContainer,
      onPrimaryContainer: _on(primaryContainer),
      secondary: palette.secondary,
      onSecondary: _on(palette.secondary),
      secondaryContainer: secondaryContainer,
      onSecondaryContainer: _on(secondaryContainer),
      tertiary: palette.tertiary,
      onTertiary: _on(palette.tertiary),
      tertiaryContainer: tertiaryContainer,
      onTertiaryContainer: _on(tertiaryContainer),
      error: const Color(0xffba1a1a),
      onError: Colors.white,
      errorContainer: brightness == Brightness.dark ? const Color(0xff93000a) : const Color(0xffffdad6),
      onErrorContainer: brightness == Brightness.dark ? const Color(0xffffdad6) : const Color(0xff410002),
      surface: surfaceSeed.surface,
      onSurface: surfaceSeed.onSurface,
      surfaceDim: surfaceSeed.surfaceDim,
      surfaceBright: surfaceSeed.surfaceBright,
      surfaceContainerLowest: surfaceSeed.surfaceContainerLowest,
      surfaceContainerLow: surfaceSeed.surfaceContainerLow,
      surfaceContainer: surfaceSeed.surfaceContainer,
      surfaceContainerHigh: surfaceSeed.surfaceContainerHigh,
      surfaceContainerHighest: surfaceSeed.surfaceContainerHighest,
      onSurfaceVariant: surfaceSeed.onSurfaceVariant,
      outline: base.outline,
      outlineVariant: base.outlineVariant,
      shadow: Colors.black,
      scrim: Colors.black,
      inverseSurface: surfaceSeed.inverseSurface,
      onInverseSurface: surfaceSeed.onInverseSurface,
      inversePrimary: base.inversePrimary,
      surfaceTint: palette.primary,
    );
  }

  static Color _on(Color color) => ThemeData.estimateBrightnessForColor(color) == Brightness.dark ? Colors.white : Colors.black;
}

class ThemeRegistry {
  const ThemeRegistry._();

  static const List<ThemeModel> themes = <ThemeModel>[
    ThemeModel(id: 'electric', name: 'Electric', category: ThemeCategory.vibrant, palette: ThemePalette(primary: Color(0xff1B4FE4), secondary: Color(0xffFF4757), tertiary: Color(0xffFFE100), neutral: Color(0xff00E59B), background: Color(0xff0D0D0D))),
    ThemeModel(id: 'wabi_sabi', name: 'Wabi-Sabi', category: ThemeCategory.natural, palette: ThemePalette(primary: Color(0xff9E7B5A), secondary: Color(0xff6B7C49), tertiary: Color(0xffF4EEE0), neutral: Color(0xff2F2B24), background: Color(0xffEAE0D5))),
    ThemeModel(id: 'coastal_edit', name: 'Coastal Edit', category: ThemeCategory.natural, palette: ThemePalette(primary: Color(0xff2A7B9B), secondary: Color(0xffA8D8CF), tertiary: Color(0xff8B6F47), background: Color(0xffF2F7F5))),
    ThemeModel(id: 'luxury_noir', name: 'Luxury Noir', category: ThemeCategory.luxury, palette: ThemePalette(primary: Color(0xffD4AF37), secondary: Color(0xff9C4B1B), tertiary: Color(0xffF8F4E3), background: Color(0xff1A1A1A))),
    ThemeModel(id: 'sage_clay', name: 'Sage & Clay', category: ThemeCategory.natural, palette: ThemePalette(primary: Color(0xffB2C5A8), secondary: Color(0xffC4785A), tertiary: Color(0xff7A8B8B), background: Color(0xffF5F0E8))),
    ThemeModel(id: 'solar_flare', name: 'Solar Flare', category: ThemeCategory.vibrant, palette: ThemePalette(primary: Color(0xffFFAA00), secondary: Color(0xffE8003A), background: Color(0xffFFAA00))),
    ThemeModel(id: 'neon_tide', name: 'Neon Tide', category: ThemeCategory.vibrant, palette: ThemePalette(primary: Color(0xff00F5AA), secondary: Color(0xff3B00FF), background: Color(0xff00F5AA))),
    ThemeModel(id: 'arctic', name: 'Arctic', category: ThemeCategory.minimal, palette: ThemePalette(primary: Color(0xffE8F5FF), secondary: Color(0xff0050D8), background: Color(0xffE8F5FF))),
    ThemeModel(id: 'dusk', name: 'Dusk', category: ThemeCategory.vibrant, palette: ThemePalette(primary: Color(0xffFF5CBA), secondary: Color(0xff2B00FF), background: Color(0xffFF5CBA))),
    ThemeModel(id: 'berry_glow', name: 'Berry Glow', category: ThemeCategory.vibrant, palette: ThemePalette(primary: Color(0xff9333EA), secondary: Color(0xffFB7185), background: Color(0xff9333EA))),
    ThemeModel(id: 'cotton_candy', name: 'Cotton Candy', category: ThemeCategory.pastel, palette: ThemePalette(primary: Color(0xff7AA8FF), secondary: Color(0xffFF9AEF), background: Color(0xff7AA8FF))),
    ThemeModel(id: 'golden_ember', name: 'Golden Ember', category: ThemeCategory.vibrant, palette: ThemePalette(primary: Color(0xffFACC15), secondary: Color(0xffF97316), background: Color(0xffFACC15))),
    ThemeModel(id: 'aqua_depth', name: 'Aqua Depth', category: ThemeCategory.vibrant, palette: ThemePalette(primary: Color(0xff0F766E), secondary: Color(0xff22D3EE), background: Color(0xff0F766E))),
    ThemeModel(id: 'royal_flame', name: 'Royal Flame', category: ThemeCategory.vibrant, palette: ThemePalette(primary: Color(0xffDB2777), secondary: Color(0xffDC2626), background: Color(0xffDB2777))),
    ThemeModel(id: 'dark_scarlet_antique_ruby', name: 'Dark Scarlet / Antique Ruby', category: ThemeCategory.dark, palette: ThemePalette(primary: Color(0xff4F0715), secondary: Color(0xff781728), background: Color(0xff4F0715))),
    ThemeModel(id: 'japanese_carmine_dark_slate_gray', name: 'Japanese Carmine / Dark Slate Gray', category: ThemeCategory.classic, palette: ThemePalette(primary: Color(0xff982930), secondary: Color(0xff39544B), background: Color(0xff982930))),
    ThemeModel(id: 'slate_blue_glacier', name: 'Slate Blue / Glacier', category: ThemeCategory.pastel, palette: ThemePalette(primary: Color(0xff619BB6), secondary: Color(0xffBAD7E1), background: Color(0xff619BB6))),
    ThemeModel(id: 'thistle_liberty', name: 'Thistle / Liberty', category: ThemeCategory.pastel, palette: ThemePalette(primary: Color(0xffDEC2DB), secondary: Color(0xff5B62B3), background: Color(0xffDEC2DB))),
    ThemeModel(id: 'stormy_teal_oxidized_iron_pale_oak', name: 'Stormy Teal / Oxidized Iron / Pale Oak', category: ThemeCategory.classic, palette: ThemePalette(primary: Color(0xff32707C), secondary: Color(0xffA8371C), tertiary: Color(0xffD4C4B7), background: Color(0xff32707C))),
    ThemeModel(id: 'luxury_noir_soft_oat', name: 'Luxury Noir / Soft Oat', category: ThemeCategory.luxury, palette: ThemePalette(primary: Color(0xff060D0C), secondary: Color(0xffF0EDE5), background: Color(0xff060D0C))),
    ThemeModel(id: 'liver_tan', name: 'Liver / Tan', category: ThemeCategory.classic, palette: ThemePalette(primary: Color(0xff6A3428), secondary: Color(0xffCFB882), background: Color(0xff6A3428))),
    ThemeModel(id: 'bistre_brown_sugar', name: 'Bistre / Brown Sugar', category: ThemeCategory.classic, palette: ThemePalette(primary: Color(0xff3D2C22), secondary: Color(0xffBB734B), background: Color(0xff3D2C22))),
    ThemeModel(id: 'dark_gray_vivid_yellow', name: 'Dark Gray / Vivid Yellow', category: ThemeCategory.minimal, palette: ThemePalette(primary: Color(0xff323232), secondary: Color(0xffFFDB00), background: Color(0xff323232))),
    ThemeModel(id: 'jasmine_dark_graphite', name: 'Jasmine / Dark Graphite', category: ThemeCategory.classic, palette: ThemePalette(primary: Color(0xffF8DE7F), secondary: Color(0xff3A393F), background: Color(0xffF8DE7F))),
    ThemeModel(id: 'deep_dark_blue_warm_yellow_orange', name: 'Deep Dark Blue / Warm Yellow Orange', category: ThemeCategory.vibrant, palette: ThemePalette(primary: Color(0xff001F7B), secondary: Color(0xffFFBA09), background: Color(0xff001F7B))),
    ThemeModel(id: 'dark_green_neon_green', name: 'Dark Green / Neon Green', category: ThemeCategory.vibrant, palette: ThemePalette(primary: Color(0xff01210A), secondary: Color(0xffA8FF00), background: Color(0xff01210A))),
    ThemeModel(id: 'dark_rich_green_golden_yellow', name: 'Dark Rich Green / Golden Yellow', category: ThemeCategory.classic, palette: ThemePalette(primary: Color(0xff014726), secondary: Color(0xffFFCF00), background: Color(0xff014726))),
    ThemeModel(id: 'deep_rich_red_soft_yellow', name: 'Deep Rich Red / Soft Yellow', category: ThemeCategory.classic, palette: ThemePalette(primary: Color(0xffAB1509), secondary: Color(0xffFFF8D2), background: Color(0xffAB1509))),
    ThemeModel(id: 'dark_red_bright_warm_yellow', name: 'Dark Red / Bright Warm Yellow', category: ThemeCategory.vibrant, palette: ThemePalette(primary: Color(0xffA01717), secondary: Color(0xffFFE162), background: Color(0xffA01717))),
    ThemeModel(id: 'matcha_cream_milky_honey', name: 'Matcha Cream / Milky Honey', category: ThemeCategory.natural, palette: ThemePalette(primary: Color(0xff9CA763), secondary: Color(0xffF1E8C7), background: Color(0xff9CA763))),
    ThemeModel(id: 'coffee_bean_almond', name: 'Coffee Bean / Almond', category: ThemeCategory.classic, palette: ThemePalette(primary: Color(0xff2E0D14), secondary: Color(0xffEFE1D5), background: Color(0xff2E0D14))),
    ThemeModel(id: 'mocha_berry_soft_vanilla', name: 'Mocha Berry / Soft Vanilla', category: ThemeCategory.pastel, palette: ThemePalette(primary: Color(0xff784955), secondary: Color(0xffFAEDDB), background: Color(0xff784955))),
    ThemeModel(id: 'twilight', name: 'Twilight', category: ThemeCategory.classic, palette: ThemePalette(primary: Color(0xff564A96), secondary: Color(0xffB75F67), background: Color(0xff564A96))),
    ThemeModel(id: 'blacklist_purple_transparent_pink', name: 'Blacklist Purple / Transparent Pink', category: ThemeCategory.dark, palette: ThemePalette(primary: Color(0xff240A30), secondary: Color(0xffFFDCF0), background: Color(0xff240A30))),
    ThemeModel(id: 'magenta', name: 'Magenta', category: ThemeCategory.vibrant, palette: ThemePalette(primary: Color(0xff4B0C37), secondary: Color(0xffC8005A), background: Color(0xff4B0C37))),
    ThemeModel(id: 'muted_blue_green_fresh_green', name: 'Muted Blue Green / Fresh Green', category: ThemeCategory.vibrant, palette: ThemePalette(primary: Color(0xff162531), secondary: Color(0xff9AF376), background: Color(0xff162531))),
    ThemeModel(id: 'deep_rich_purple_light_cream', name: 'Deep Rich Purple / Light Cream', category: ThemeCategory.classic, palette: ThemePalette(primary: Color(0xff720065), secondary: Color(0xffFDF9B6), background: Color(0xff720065))),
    ThemeModel(id: 'deep_royal_purple_soft_snow_white', name: 'Deep Royal Purple / Soft Snow White', category: ThemeCategory.classic, palette: ThemePalette(primary: Color(0xff460B6A), secondary: Color(0xffFFFBFF), background: Color(0xff460B6A))),
    ThemeModel(id: 'deep_navy_vibrant_cyan', name: 'Deep Navy / Vibrant Cyan', category: ThemeCategory.vibrant, palette: ThemePalette(primary: Color(0xff001935), secondary: Color(0xff2FE8FF), background: Color(0xff001935))),
    ThemeModel(id: 'vanilla_latte_teal_forest', name: 'Vanilla Latte / Teal Forest', category: ThemeCategory.natural, palette: ThemePalette(primary: Color(0xffEFE1D5), secondary: Color(0xff184E50), background: Color(0xffEFE1D5))),
    ThemeModel(id: 'sage_black_olive', name: 'Sage / Black Olive', category: ThemeCategory.natural, palette: ThemePalette(primary: Color(0xffB2B49C), secondary: Color(0xff3B3B2A), background: Color(0xffB2B49C))),
    ThemeModel(id: 'old_rose_seashell_sky_reflection', name: 'Old Rose / Seashell / Sky Reflection', category: ThemeCategory.pastel, palette: ThemePalette(primary: Color(0xffE19AA6), secondary: Color(0xffFAF0EA), tertiary: Color(0xff82B0CE), background: Color(0xffE19AA6))),
    ThemeModel(id: 'soft_fawn_carbon_black_ivory_mist', name: 'Soft Fawn / Carbon Black / Ivory Mist', category: ThemeCategory.luxury, palette: ThemePalette(primary: Color(0xffD5B572), secondary: Color(0xff201F14), tertiary: Color(0xffF8F2E1), background: Color(0xffD5B572))),
    ThemeModel(id: 'onyx_olive_desert', name: 'Onyx / Olive / Desert', category: ThemeCategory.natural, palette: ThemePalette(primary: Color(0xff13140E), secondary: Color(0xff838236), tertiary: Color(0xffDEDACF), background: Color(0xff13140E))),
    ThemeModel(id: 'fiery_rose_black_pearl', name: 'Fiery Rose / Black Pearl', category: ThemeCategory.vibrant, palette: ThemePalette(primary: Color(0xffFF4D73), secondary: Color(0xff00181B), background: Color(0xffFF4D73))),
    ThemeModel(id: 'tranquil_orange_maastricht_blue', name: 'Tranquil Orange / Maastricht Blue', category: ThemeCategory.classic, palette: ThemePalette(primary: Color(0xffFFB268), secondary: Color(0xff001E37), background: Color(0xffFFB268))),
    ThemeModel(id: 'sangria', name: 'Sangria', category: ThemeCategory.dark, palette: ThemePalette(primary: Color(0xffC0392B), secondary: Color(0xff080205), background: Color(0xffC0392B))),
    ThemeModel(id: 'forest_night', name: 'Forest Night', category: ThemeCategory.dark, palette: ThemePalette(primary: Color(0xff0A1200), secondary: Color(0xffBD5E85), background: Color(0xff0A1200))),
    ThemeModel(id: 'burgundy', name: 'Burgundy', category: ThemeCategory.classic, palette: ThemePalette(primary: Color(0xff4A1528), secondary: Color(0xffD8A1B7), background: Color(0xff4A1528))),
    ThemeModel(id: 'navy', name: 'Navy', category: ThemeCategory.classic, palette: ThemePalette(primary: Color(0xff292F91), secondary: Color(0xff9FA8FF), background: Color(0xff292F91))),
    ThemeModel(id: 'cyan_spark', name: 'Cyan Spark', category: ThemeCategory.vibrant, palette: ThemePalette(primary: Color(0xff00D4FF), secondary: Color(0xff003847), background: Color(0xff00D4FF))),
    ThemeModel(id: 'near_black', name: 'Near Black', category: ThemeCategory.dark, palette: ThemePalette(primary: Color(0xff1A0508), secondary: Color(0xffFFB3BD), background: Color(0xff1A0508))),
  ];

  static final Map<String, ThemeModel> byId = <String, ThemeModel>{for (final theme in themes) theme.id: theme};
  static ThemeModel get defaultTheme => byId['coastal_edit'] ?? themes.first;
  static ThemeModel resolve(String? id) => byId[id] ?? defaultTheme;
  static List<ThemeModel> search(String query, {ThemeCategory? category}) => themes.where((theme) => theme.matches(query) && (category == null || theme.category == category)).toList(growable: false);
}

class ThemeManager {
  ThemeManager._();

  static final ThemeManager instance = ThemeManager._();

  final StreamController<ThemeModel> _controller = StreamController<ThemeModel>.broadcast();
  final ValueNotifier<ThemeModel> currentTheme = ValueNotifier<ThemeModel>(ThemeRegistry.defaultTheme);
  SharedPreferencesWithCache? _prefs;

  Stream<ThemeModel> get themeStream => _controller.stream;
  List<ThemeModel> get allThemes => ThemeRegistry.themes;
  List<String> get favoriteThemeIds => List<String>.unmodifiable(_prefs?.getStringList(kThemeFavoritesStorageKey) ?? const <String>[]);
  List<String> get recentThemeIds => List<String>.unmodifiable(_prefs?.getStringList(kThemeRecentStorageKey) ?? const <String>[]);
  List<ThemeModel> get favoriteThemes => favoriteThemeIds.map(ThemeRegistry.resolve).toList(growable: false);
  List<ThemeModel> get recentThemes => recentThemeIds.map(ThemeRegistry.resolve).toList(growable: false);

  Future<void> initialize() async {
    _prefs = LichessBinding.instance.sharedPreferences;
    final theme = ThemeRegistry.resolve(_prefs?.getString(kThemeSelectionStorageKey));
    currentTheme.value = theme;
    _controller.add(theme);
  }

  Future<void> applyTheme(ThemeModel theme) async {
    if (currentTheme.value.id == theme.id) return;
    currentTheme.value = theme;
    _controller.add(theme);
    final prefs = _prefs ?? LichessBinding.instance.sharedPreferences;
    await Future<void>(() async {
      await prefs.setString(kThemeSelectionStorageKey, theme.id);
      await _recordRecent(theme.id, prefs);
    });
  }

  Future<void> toggleFavorite(ThemeModel theme) async {
    final prefs = _prefs ?? LichessBinding.instance.sharedPreferences;
    final ids = prefs.getStringList(kThemeFavoritesStorageKey) ?? <String>[];
    if (ids.contains(theme.id)) {
      ids.remove(theme.id);
    } else {
      ids.add(theme.id);
    }
    await prefs.setStringList(kThemeFavoritesStorageKey, ids);
  }

  Future<void> _recordRecent(String id, SharedPreferencesWithCache prefs) async {
    final ids = prefs.getStringList(kThemeRecentStorageKey) ?? <String>[];
    ids.remove(id);
    ids.insert(0, id);
    await prefs.setStringList(kThemeRecentStorageKey, ids.take(kMaxRecentThemes).toList(growable: false));
  }
}
