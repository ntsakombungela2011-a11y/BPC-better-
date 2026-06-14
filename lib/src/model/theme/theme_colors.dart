
import 'dart:math' as math;
import 'package:flutter/material.dart';
typedef ColorGenerator = AppColorScheme Function(Color seedColor);

/// Function type for generating color schemes.


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
  });

  /// Convert to Flutter ColorScheme.
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
    );
  }
}

/// Utility class for generating color schemes from seed colors.
class AppColorGenerator {
  ColorGenerator._();

  /// Generate a complete color scheme from a seed color.
  static AppColorScheme generateFromSeed(Color seedColor, {bool isDark = false}) {
    final hsl = HSLColor.fromColor(seedColor);
    final hue = hsl.hue;
    final saturation = hsl.saturation;
    final lightness = hsl.lightness;

    // Generate primary colors
    final primary = seedColor;
    final onPrimary = _contrastColor(primary);
    final primaryContainer = _adjustLightness(primary, isDark ? 0.1 : -0.1);
    final onPrimaryContainer = _contrastColor(primaryContainer);

    // Generate secondary colors (complementary or analogous)
    final secondaryHue = (hue + 30) % 360;
    final secondary = HSLColor.fromAHSL(1.0, secondaryHue, saturation, lightness + 0.1).toColor();
    final onSecondary = _contrastColor(secondary);
    final secondaryContainer = _adjustLightness(secondary, isDark ? 0.1 : -0.1);
    final onSecondaryContainer = _contrastColor(secondaryContainer);

    // Generate tertiary colors (triadic)
    final tertiaryHue = (hue + 180) % 360;
    final tertiary = HSLColor.fromAHSL(1.0, tertiaryHue, saturation, lightness + 0.05).toColor();
    final onTertiary = _contrastColor(tertiary);
    final tertiaryContainer = _adjustLightness(tertiary, isDark ? 0.1 : -0.1);
    final onTertiaryContainer = _contrastColor(tertiaryContainer);

    // Surface colors
    final surface = isDark
        ? HSLColor.fromAHSL(1.0, hue, saturation * 0.3, 0.08).toColor()
        : HSLColor.fromAHSL(1.0, hue, saturation * 0.2, 0.97).toColor();
    final onSurface = _contrastColor(surface);

    final surfaceContainerHighest = isDark
        ? HSLColor.fromAHSL(1.0, hue, saturation * 0.3, 0.15).toColor()
        : HSLColor.fromAHSL(1.0, hue, saturation * 0.2, 0.92).toColor();

    final onSurfaceVariant = isDark
        ? HSLColor.fromAHSL(1.0, hue, saturation * 0.5, 0.70).toColor()
        : HSLColor.fromAHSL(1.0, hue, saturation * 0.4, 0.35).toColor();

    // Error colors
    const error = Color(0xFFB3261E);
    const onError = Color(0xFFFFFFFF);
    final errorContainer = isDark
        ? const Color(0xFF8C1D18)
        : const Color(0xFFF9DEDC);
    final onErrorContainer = _contrastColor(errorContainer);

    // Other colors
    final outline = isDark
        ? HSLColor.fromAHSL(1.0, hue, saturation * 0.3, 0.40).toColor()
        : HSLColor.fromAHSL(1.0, hue, saturation * 0.4, 0.60).toColor();
    final outlineVariant = isDark
        ? HSLColor.fromAHSL(1.0, hue, saturation * 0.2, 0.25).toColor()
        : HSLColor.fromAHSL(1.0, hue, saturation * 0.3, 0.85).toColor();

    const shadow = Color(0xFF000000);
    const scrim = Color(0xFF000000);

    final inverseSurface = isDark
        ? HSLColor.fromAHSL(1.0, hue, saturation * 0.4, 0.95).toColor()
        : HSLColor.fromAHSL(1.0, hue, saturation * 0.4, 0.15).toColor();
    final onInverseSurface = _contrastColor(inverseSurface);
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
    );
  }

  /// Get a color that contrasts well with the given color.
  static Color _contrastColor(Color color) {
    final luminance = color.computeLuminance();
    return luminance > 0.5 ? Colors.black : Colors.white;
  }

  /// Adjust the lightness of a color.
  static Color _adjustLightness(Color color, double amount) {
    final hsl = HSLColor.fromColor(color);
    final newLightness = (hsl.lightness + amount).clamp(0.0, 1.0);
    return hsl.withLightness(newLightness).toColor();
  }

  /// Desaturate a color by a factor.
  static Color _desaturate(Color color, double factor) {
    final hsl = HSLColor.fromColor(color);
    final newSaturation = (hsl.saturation * (1 - factor)).clamp(0.0, 1.0);
    return hsl.withSaturation(newSaturation).toColor();
  }

  /// Calculate the relative luminance of a color.
  static double relativeLuminance(Color color) {
    return color.computeLuminance();
  }

  /// Calculate the contrast ratio between two colors.
  /// Returns a value between 1 and 21.
  static double contrastRatio(Color foreground, Color background) {
    final fgLuminance = relativeLuminance(foreground) + 0.05;
    final bgLuminance = relativeLuminance(background) + 0.05;
    return (fgLuminance > bgLuminance ? fgLuminance / bgLuminance : bgLuminance / fgLuminance);
  }

  /// Check if the contrast ratio meets WCAG AA standards.
  /// For normal text (4.5:1) or large text (3:1).
  static bool meetsContrastStandards(Color foreground, Color background, {bool isLargeText = false}) {
    final ratio = contrastRatio(foreground, background);
    return isLargeText ? ratio >= 3.0 : ratio >= 4.5;
  }

  /// Generate a light variant of the color scheme.
  static AppColorScheme generateLight(Color seedColor) {
    return generateFromSeed(seedColor, isDark: false);
  }

  /// Generate a dark variant of the color scheme.
  static AppColorScheme generateDark(Color seedColor) {
    return generateFromSeed(seedColor, isDark: true);
  }

  /// Generate both light and dark variants.
  static ({AppColorScheme light, AppColorScheme dark}) generateBoth(Color seedColor) {
    return (
      light: generateLight(seedColor),
      dark: generateDark(seedColor),
    );
  }

  /// Interpolate between two colors.
  static Color lerp(Color a, Color b, double t) {
    return Color.lerp(a, b, t) ?? a;
  }

  /// Rotate the hue of a color.
  static Color rotateHue(Color color, double degrees) {
    final hsl = HSLColor.fromColor(color);
    final newHue = (hsl.hue + degrees) % 360;
    return hsl.withHue(newHue < 0 ? newHue + 360 : newHue).toColor();
  }

  /// Create a complementary color.
  static Color complementary(Color color) {
    return rotateHue(color, 180);
  }

  /// Create analogous colors.
  static List<Color> analogous(Color color, {double spread = 30}) {
    return [
      rotateHue(color, -spread),
      color,
      rotateHue(color, spread),
    ];
  }

  /// Create triadic colors.
  static List<Color> triadic(Color color) {
    return [
      color,
      rotateHue(color, 120),
      rotateHue(color, 240),
    ];
  }

  /// Create a monochromatic scale.
  static List<Color> monochromatic(Color color, {int steps = 9}) {
    final hsl = HSLColor.fromColor(color);
    final colors = <Color>[];
    for (var i = 0; i < steps; i++) {
      final lightness = 0.1 + (0.8 * i / (steps - 1));
      colors.add(hsl.withLightness(lightness).toColor());
    }
    return colors;
  }
}

/// Extension to provide color utility methods.
extension ColorUtils on Color {
  /// Check if this color is considered dark.
  bool get isDark => computeLuminance() < 0.5;

  /// Check if this color is considered light.
  bool get isLight => !isDark;

  /// Get a lighter version of this color.
  Color lighter([double amount = 0.1]) {
    final hsl = HSLColor.fromColor(this);
    return hsl.withLightness((hsl.lightness + amount).clamp(0.0, 1.0)).toColor();
  }

  /// Get a darker version of this color.
  Color darker([double amount = 0.1]) {
    final hsl = HSLColor.fromColor(this);
    return hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0)).toColor();
  }

  /// Get a more saturated version of this color.
  Color saturate([double amount = 0.1]) {
    final hsl = HSLColor.fromColor(this);
    return hsl.withSaturation((hsl.saturation + amount).clamp(0.0, 1.0)).toColor();
  }

  /// Get a less saturated version of this color.
  Color desaturate([double amount = 0.1]) {
    final hsl = HSLColor.fromColor(this);
    return hsl.withSaturation((hsl.saturation - amount).clamp(0.0, 1.0)).toColor();
  }

  /// Get the complement of this color.
  Color get complement => AppColorGenerator.rotateHue(this, 180);

  /// Blend this color with another.
  Color blend(Color other, double amount) {
    return Color.lerp(this, other, amount) ?? this;
  }
}