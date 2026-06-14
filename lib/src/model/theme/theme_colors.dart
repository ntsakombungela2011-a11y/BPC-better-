import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:lichess_mobile/src/model/theme/theme_palette.dart';

typedef ColorGenerator = AppColorScheme Function(Color seedColor);

/// A complete color scheme for the app.
class AppColorScheme {
  final Color primary;
  final Color onPrimary;
  final Color primaryContainer;
  final Color onPrimaryContainer;
  final Color secondary;
  final Color onSecondary;
  final Color secondaryContainer;
  final Color onSecondaryContainer;
  final Color tertiary;
  final Color onTertiary;
  final Color tertiaryContainer;
  final Color onTertiaryContainer;
  final Color error;
  final Color onError;
  final Color errorContainer;
  final Color onErrorContainer;
  final Color surface;
  final Color onSurface;
  final Color surfaceContainerHighest;
  final Color onSurfaceVariant;
  final Color outline;
  final Color outlineVariant;
  final Color shadow;
  final Color scrim;
  final Color inverseSurface;
  final Color onInverseSurface;
  final Color inversePrimary;
  final Color surfaceTint;

  // New Material 3 surface roles
  final Color surfaceContainerLowest;
  final Color surfaceContainerLow;
  final Color surfaceContainer;
  final Color surfaceContainerHigh;
  final Color surfaceDim;
  final Color surfaceBright;

  const AppColorScheme({
    required this.primary,
    required this.onPrimary,
    required this.primaryContainer,
    required this.onPrimaryContainer,
    required this.secondary,
    required this.onSecondary,
    required this.secondaryContainer,
    required this.onSecondaryContainer,
    required this.tertiary,
    required this.onTertiary,
    required this.tertiaryContainer,
    required this.onTertiaryContainer,
    required this.error,
    required this.onError,
    required this.errorContainer,
    required this.onErrorContainer,
    required this.surface,
    required this.onSurface,
    required this.surfaceContainerHighest,
    required this.onSurfaceVariant,
    required this.outline,
    required this.outlineVariant,
    required this.shadow,
    required this.scrim,
    required this.inverseSurface,
    required this.onInverseSurface,
    required this.inversePrimary,
    required this.surfaceTint,
    required this.surfaceContainerLowest,
    required this.surfaceContainerLow,
    required this.surfaceContainer,
    required this.surfaceContainerHigh,
    required this.surfaceDim,
    required this.surfaceBright,
  });

  ColorScheme toColorScheme(Brightness brightness) {
    return ColorScheme(
      brightness: brightness,
      primary: primary,
      onPrimary: onPrimary,
      primaryContainer: primaryContainer,
      onPrimaryContainer: onPrimaryContainer,
      secondary: secondary,
      onSecondary: onSecondary,
      secondaryContainer: secondaryContainer,
      onSecondaryContainer: onSecondaryContainer,
      tertiary: tertiary,
      onTertiary: onTertiary,
      tertiaryContainer: tertiaryContainer,
      onTertiaryContainer: onTertiaryContainer,
      error: error,
      onError: onError,
      errorContainer: errorContainer,
      onErrorContainer: onErrorContainer,
      surface: surface,
      onSurface: onSurface,
      surfaceContainerHighest: surfaceContainerHighest,
      onSurfaceVariant: onSurfaceVariant,
      outline: outline,
      outlineVariant: outlineVariant,
      shadow: shadow,
      scrim: scrim,
      inverseSurface: inverseSurface,
      onInverseSurface: onInverseSurface,
      inversePrimary: inversePrimary,
      surfaceTint: surfaceTint,
      surfaceContainerLowest: surfaceContainerLowest,
      surfaceContainerLow: surfaceContainerLow,
      surfaceContainer: surfaceContainer,
      surfaceContainerHigh: surfaceContainerHigh,
      surfaceDim: surfaceDim,
      surfaceBright: surfaceBright,
    );
  }
}

/// Utility class for generating color schemes.
class AppColorGenerator {
  AppColorGenerator._();

  static final Map<String, AppColorScheme> _cache = {};

  /// Generate a color scheme from a theme palette.
  static AppColorScheme generateFromPalette(ThemePalette palette, {bool isDark = false}) {
    final cacheKey = '${palette.id}_${isDark ? 'dark' : 'light'}';
    if (_cache.containsKey(cacheKey)) {
      return _cache[cacheKey]!;
    }

    final primary = palette.primaryColor;
    final secondary = palette.secondaryColor;
    final tertiary = palette.tertiaryColor;
    final surface = palette.surfaceColor;

    final scheme = _generate(
      primary: primary,
      secondary: secondary,
      tertiary: tertiary,
      surface: surface,
      isDark: isDark,
    );

    _cache[cacheKey] = scheme;
    return scheme;
  }

  /// Legacy support for seed color.
  static AppColorScheme generateFromSeed(Color seedColor, {bool isDark = false}) {
    final cacheKey = 'seed_${seedColor.toARGB32()}_${isDark ? 'dark' : 'light'}';
    if (_cache.containsKey(cacheKey)) {
      return _cache[cacheKey]!;
    }

    final hsl = HSLColor.fromColor(seedColor);
    final secondary = hsl.withHue((hsl.hue + 30) % 360).toColor();
    final tertiary = hsl.withHue((hsl.hue + 120) % 360).toColor();
    final surface = isDark ? const Color(0xFF0D0D0D) : const Color(0xFFF2F2F2);

    final scheme = _generate(
      primary: seedColor,
      secondary: secondary,
      tertiary: tertiary,
      surface: surface,
      isDark: isDark,
    );

    _cache[cacheKey] = scheme;
    return scheme;
  }

  static AppColorScheme _generate({
    required Color primary,
    required Color secondary,
    required Color tertiary,
    required Color surface,
    required bool isDark,
  }) {
    final onPrimary = _contrastColor(primary);
    final primaryContainer = _adjustLightness(primary, isDark ? 0.1 : -0.1);
    final onPrimaryContainer = _contrastColor(primaryContainer);

    final onSecondary = _contrastColor(secondary);
    final secondaryContainer = _adjustLightness(secondary, isDark ? 0.1 : -0.1);
    final onSecondaryContainer = _contrastColor(secondaryContainer);

    final onTertiary = _contrastColor(tertiary);
    final tertiaryContainer = _adjustLightness(tertiary, isDark ? 0.1 : -0.1);
    final onTertiaryContainer = _contrastColor(tertiaryContainer);

    final onSurface = _contrastColor(surface);

    final surfaceContainerHighest = _adjustLightness(surface, isDark ? 0.15 : -0.15);
    final onSurfaceVariant = _adjustLightness(onSurface, isDark ? -0.2 : 0.2);

    // Error colors
    const error = Color(0xFFB3261E);
    const onError = Color(0xFFFFFFFF);
    final errorContainer = isDark ? const Color(0xFF8C1D18) : const Color(0xFFF9DEDC);
    final onErrorContainer = _contrastColor(errorContainer);

    // Other colors
    final outline = _adjustLightness(surface, isDark ? 0.3 : -0.3);
    final outlineVariant = _adjustLightness(surface, isDark ? 0.15 : -0.15);

    const shadow = Color(0xFF000000);
    const scrim = Color(0xFF000000);

    final inverseSurface = onSurface;
    final onInverseSurface = surface;
    final inversePrimary = isDark ? primary : _desaturate(primary, 0.5);

    return AppColorScheme(
      primary: primary,
      onPrimary: onPrimary,
      primaryContainer: primaryContainer,
      onPrimaryContainer: onPrimaryContainer,
      secondary: secondary,
      onSecondary: onSecondary,
      secondaryContainer: secondaryContainer,
      onSecondaryContainer: onSecondaryContainer,
      tertiary: tertiary,
      onTertiary: onTertiary,
      tertiaryContainer: tertiaryContainer,
      onTertiaryContainer: onTertiaryContainer,
      error: error,
      onError: onError,
      errorContainer: errorContainer,
      onErrorContainer: onErrorContainer,
      surface: surface,
      onSurface: onSurface,
      surfaceContainerHighest: surfaceContainerHighest,
      onSurfaceVariant: onSurfaceVariant,
      outline: outline,
      outlineVariant: outlineVariant,
      shadow: shadow,
      scrim: scrim,
      inverseSurface: inverseSurface,
      onInverseSurface: onInverseSurface,
      inversePrimary: inversePrimary,
      surfaceTint: primary,
      surfaceContainerLowest: _adjustLightness(surface, isDark ? -0.05 : 0.05),
      surfaceContainerLow: _adjustLightness(surface, isDark ? 0.02 : -0.02),
      surfaceContainer: surface,
      surfaceContainerHigh: _adjustLightness(surface, isDark ? 0.05 : -0.05),
      surfaceDim: _adjustLightness(surface, isDark ? -0.02 : 0.02),
      surfaceBright: _adjustLightness(surface, isDark ? 0.05 : -0.05),
    );
  }

  static Color _contrastColor(Color color) {
    return color.computeLuminance() > 0.5 ? Colors.black : Colors.white;
  }

  static Color _adjustLightness(Color color, double amount) {
    final hsl = HSLColor.fromColor(color);
    return hsl.withLightness((hsl.lightness + amount).clamp(0.0, 1.0)).toColor();
  }

  static Color _desaturate(Color color, double factor) {
    final hsl = HSLColor.fromColor(color);
    return hsl.withSaturation((hsl.saturation * (1 - factor)).clamp(0.0, 1.0)).toColor();
  }

  static AppColorScheme generateLight(Color seedColor) => generateFromSeed(seedColor, isDark: false);
  static AppColorScheme generateDark(Color seedColor) => generateFromSeed(seedColor, isDark: true);
}

extension ColorUtils on Color {
  bool get isDark => computeLuminance() < 0.5;
  bool get isLight => !isDark;
  Color lighter([double amount = 0.1]) => AppColorGenerator._adjustLightness(this, amount);
  Color darker([double amount = 0.1]) => AppColorGenerator._adjustLightness(this, -amount);
}
