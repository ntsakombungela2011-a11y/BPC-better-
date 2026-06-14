import 'package:chessground/chessground.dart';
import 'package:dartchess/dartchess.dart';
import 'package:flutter/widgets.dart';
import 'dart:isolate';

/// Computes the set of squares that should have an atomic explosion animation
/// after [move] was played from [positionBefore].
///
/// Returns `null` if [positionBefore] is not an atomic position, [move] is
/// null, or the move was not a capture (no explosion occurs).
Set<Square>? atomicExplosionSquares(Position positionBefore, Move? move) {
  if (move == null || positionBefore is! Atomic) return null;
  final squareSet = positionBefore.explosionSquares(move);
  return squareSet.isEmpty ? null : squareSet.squares.toSet();
}

/// Preload piece images from the specified [PieceSet] into Chessground's image cache.
///
/// This method clears the cache before loading the images.
Future<void> precachePieceImages(PieceSet pieceSet) async {
  try {
    final devicePixelRatio =
        WidgetsBinding.instance.platformDispatcher.implicitView?.devicePixelRatio ?? 1.0;

    ChessgroundImages.instance.clear();

    // Use Future.wait to parallelize image loading
    await Future.wait(pieceSet.assets.values.map((asset) =>
      ChessgroundImages.instance.load(asset, devicePixelRatio: devicePixelRatio)
        .then((_) => debugPrint('Preloaded piece image: ${asset.assetName}'))
    ));
  } catch (e) {
    debugPrint('Failed to preload piece images: $e');
  }
}
