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
    // Generate a board theme from the palette colors
    final primaryColor = palette.primaryColor;
    final lightSquare = _lighten(primaryColor, 0.3);
    final darkSquare = primaryColor;
    final secondaryColor = palette.secondaryColor;

    // Create board colors from palette
    final boardColors = ChessboardColorScheme(
      lightSquare: lightSquare,
      darkSquare: darkSquare,
      background: SolidColorChessboardBackground(lightSquare: lightSquare, darkSquare: darkSquare),
      whiteCoordBackground: SolidColorChessboardBackground(
        lightSquare: lightSquare,
        darkSquare: darkSquare,
        coordinates: true,
      ),
      blackCoordBackground: SolidColorChessboardBackground(
        lightSquare: lightSquare,
        darkSquare: darkSquare,
        coordinates: true,
        orientation: Side.black,
      ),
      lastMove: HighlightDetails(
        solidColor: secondaryColor.withValues(alpha: 0.5),
      ),
      selected: HighlightDetails(
        solidColor: secondaryColor.withValues(alpha: 0.7),
      ),
      validMoves: secondaryColor.withValues(alpha: 0.3),
      validPremoves: secondaryColor.withValues(alpha: 0.5),
    );

    return StaticChessboard(
      size: double.infinity,
      orientation: Side.white,
      lastMove: const NormalMove(from: Square.d2, to: Square.d4),
      fen: 'rnbqkbnr/pppppppp/8/8/4P3/8/PPPP1PPP/RNBQKBNR b KQkq - 0 1',
      settings: StaticChessboardSettings(
        colorScheme: boardColors,
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