import 'package:chessground/chessground.dart';
import 'package:dartchess/dartchess.dart';
import 'package:flutter/material.dart';
import 'package:lichess_mobile/src/model/theme/theme_palette.dart';
import 'package:lichess_mobile/src/model/theme/theme_colors.dart';

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
    final appColorScheme = AppColorGenerator.generateFromPalette(
      palette,
      isDark: theme.brightness == Brightness.dark,
    );

    // Create board colors from palette
    final boardColors = ChessboardColorScheme(
      lightSquare: palette.colors.length > 1 ? palette.colors[1].color : palette.primaryColor.withValues(alpha: 0.3),
      darkSquare: palette.primaryColor,
      background: SolidColorChessboardBackground(
        lightSquare: palette.colors.length > 1 ? palette.colors[1].color : palette.primaryColor.withValues(alpha: 0.3),
        darkSquare: palette.primaryColor,
      ),
      whiteCoordBackground: SolidColorChessboardBackground(
        lightSquare: palette.colors.length > 1 ? palette.colors[1].color : palette.primaryColor.withValues(alpha: 0.3),
        darkSquare: palette.primaryColor,
        coordinates: true,
      ),
      blackCoordBackground: SolidColorChessboardBackground(
        lightSquare: palette.colors.length > 1 ? palette.colors[1].color : palette.primaryColor.withValues(alpha: 0.3),
        darkSquare: palette.primaryColor,
        coordinates: true,
        orientation: Side.black,
      ),
      lastMove: HighlightDetails(
        solidColor: palette.secondaryColor.withValues(alpha: 0.5),
      ),
      selected: HighlightDetails(
        solidColor: palette.secondaryColor.withValues(alpha: 0.7),
      ),
      validMoves: palette.secondaryColor.withValues(alpha: 0.3),
      validPremoves: palette.secondaryColor.withValues(alpha: 0.5),
    );

    return Card(
      elevation: isSelected ? 4 : 1,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isSelected
            ? BorderSide(color: appColorScheme.primary, width: 2)
            : BorderSide(color: theme.dividerColor.withValues(alpha: 0.1)),
      ),
      color: appColorScheme.surface,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Chessboard preview
            Expanded(
              flex: 3,
              child: Stack(
                children: [
                  AbsorbPointer(
                    child: StaticChessboard(
                      size: double.infinity,
                      orientation: Side.white,
                      lastMove: const NormalMove(from: Square.d2, to: Square.d4),
                      fen: 'rnbqkbnr/pppppppp/8/8/4P3/8/PPPP1PPP/RNBQKBNR b KQkq - 0 1',
                      settings: StaticChessboardSettings(
                        colorScheme: boardColors,
                      ),
                    ),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: IconButton(
                      icon: Icon(
                        isFavorite ? Icons.favorite : Icons.favorite_border,
                        color: isFavorite ? Colors.red : Colors.white70,
                        shadows: const [Shadow(color: Colors.black45, blurRadius: 4)],
                      ),
                      onPressed: onFavoriteToggle,
                    ),
                  ),
                  if (isSelected)
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: appColorScheme.primary,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.check,
                          size: 16,
                          color: appColorScheme.onPrimary,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            // UI Sample section
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          palette.name,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: appColorScheme.onSurface,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    palette.category.label,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: appColorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Small UI element previews
                  Row(
                    children: [
                      Container(
                        width: 40,
                        height: 12,
                        decoration: BoxDecoration(
                          color: appColorScheme.primary,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(width: 4),
                      Container(
                        width: 24,
                        height: 12,
                        decoration: BoxDecoration(
                          color: appColorScheme.secondary,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(width: 4),
                      if (palette.colors.length > 2)
                        Container(
                          width: 24,
                          height: 12,
                          decoration: BoxDecoration(
                            color: appColorScheme.tertiary,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
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
    final appColorScheme = AppColorGenerator.generateFromPalette(
      palette,
      isDark: theme.brightness == Brightness.dark,
    );

    return ListTile(
      onTap: onTap,
      leading: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? appColorScheme.primary : Colors.transparent,
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
      title: Text(
        palette.name,
        style: TextStyle(color: isSelected ? appColorScheme.primary : null),
      ),
      subtitle: Text(palette.category.label),
      trailing: isSelected
          ? Icon(Icons.check, color: appColorScheme.primary)
          : null,
    );
  }
}
