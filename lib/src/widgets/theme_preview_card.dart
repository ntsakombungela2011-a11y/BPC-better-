import 'package:chessground/chessground.dart';
import 'package:dartchess/dartchess.dart';
import 'package:flutter/material.dart';
import 'package:lichess_mobile/src/model/theme/theme_palette.dart';
import 'package:lichess_mobile/src/styles/styles.dart';

/// A card widget that previews a theme palette.
class ThemePreviewCard extends StatelessWidget {
  const ThemePreviewCard({
    super.key,
    required this.palette,
    required this.isSelected,
    required this.isFavorite,
    required this.onTap,
    required this.onFavoriteToggle,
  });

  final ThemePalette palette;
  final bool isSelected;
  final bool isFavorite;
  final VoidCallback onTap;
  final VoidCallback onFavoriteToggle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          borderRadius: Styles.cardBorderRadius,
          border: Border.all(
            color: isSelected ? theme.colorScheme.primary : Colors.transparent,
            width: 2,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: theme.colorScheme.primary.withValues(alpha: 0.3),
                    blurRadius: 8,
                    spreadRadius: 1,
                  ),
                ]
              : null,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(Styles.cardBorderRadius.topRight.x - 2),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Chessboard preview
              SizedBox(
                height: 100,
                child: _ChessboardPreview(palette: palette, isDark: isDark),
              ),
              // Color palette strip
              SizedBox(
                height: 20,
                child: Row(
                  children: palette.colors.take(5).map((c) {
                    return Expanded(
                      child: Container(color: c.color),
                    );
                  }).toList(),
                ),
              ),
              // Theme info
              Container(
                padding: const EdgeInsets.all(8),
                color: theme.colorScheme.surfaceContainerLow,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            palette.name,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        GestureDetector(
                          onTap: onFavoriteToggle,
                          child: Icon(
                            isFavorite ? Icons.favorite : Icons.favorite_border,
                            size: 18,
                            color: isFavorite
                                ? Colors.red
                                : theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      palette.category.label,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ChessboardPreview extends StatelessWidget {
  const _ChessboardPreview({
    required this.palette,
    required this.isDark,
  });

  final ThemePalette palette;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    // Generate a board theme from the palette colors
    final primaryColor = palette.primaryColor;
    final secondaryColor = palette.secondaryColor;

    // Create board colors from palette
    final boardColors = ChessboardColorScheme(
      black: primaryColor,
      white: _lighten(primaryColor, 0.3),
      lastMove: secondaryColor.withValues(alpha: 0.5),
      validMove: secondaryColor.withValues(alpha: 0.3),
      premove: secondaryColor.withValues(alpha: 0.5),
      moveDot: secondaryColor.withValues(alpha: 0.7),
      check: Colors.red,
    );

    return StaticChessboard(
      size: double.infinity,
      orientation: Side.white,
      lastMove: const NormalMove(from: Square.d2, to: Square.d4),
      fen: 'rnbqkbnr/pppppppp/8/8/4P3/8/PPPP1PPP/RNBQKBNR b KQkq - 0 1',
      settings: StaticChessboardSettings(
        colorScheme: boardColors,
        orientation: Side.white,
      ),
    );
  }

  Color _lighten(Color color, double amount) {
    final hsl = HSLColor.fromColor(color);
    return hsl.withLightness((hsl.lightness + amount).clamp(0.0, 1.0)).toColor();
  }
}

/// A compact theme preview for lists.
class ThemePreviewTile extends StatelessWidget {
  const ThemePreviewTile({
    super.key,
    required this.palette,
    required this.isSelected,
    required this.onTap,
  });

  final ThemePalette palette;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListTile(
      onTap: onTap,
      leading: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? theme.colorScheme.primary : Colors.transparent,
            width: 2,
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: Row(
            children: palette.colors.take(4).map((c) {
              return Expanded(
                child: Container(color: c.color),
              );
            }).toList(),
          ),
        ),
      ),
      title: Text(palette.name),
      subtitle: Text(palette.category.label),
      trailing: isSelected
          ? Icon(Icons.check, color: theme.colorScheme.primary)
          : null,
    );
  }
}