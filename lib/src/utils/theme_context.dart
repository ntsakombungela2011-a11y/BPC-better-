import 'package:flutter/material.dart';

class LichessTheme {
  final Color rowEven;
  final Color rowOdd;
  final Color cardBackground;
  final Color divider;

  const LichessTheme({
    required this.rowEven,
    required this.rowOdd,
    required this.cardBackground,
    required this.divider,
  });
}

extension ThemeContext on BuildContext {
  LichessTheme get lichessTheme {
    final colorScheme = Theme.of(this).colorScheme;
    final isDark = colorScheme.brightness == Brightness.dark;

    return LichessTheme(
      rowEven: colorScheme.surface,
      rowOdd: isDark
          ? colorScheme.surfaceContainerHigh
          : colorScheme.surfaceContainerLow,
      cardBackground: colorScheme.surfaceContainer,
      divider: colorScheme.outlineVariant,
    );
  }
}
