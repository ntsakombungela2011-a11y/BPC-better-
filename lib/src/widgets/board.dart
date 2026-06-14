import 'dart:async';

import 'package:chessground/chessground.dart';
import 'package:dartchess/dartchess.dart';
import 'package:flutter/material.dart';
import 'package:lichess_mobile/src/model/common/chess.dart';
import 'package:lichess_mobile/src/model/settings/board_preferences.dart';

/// A widget that displays an interactive chessboard driven by a [ChessboardController].
///
/// For a non-interactive board, use [StaticChessboard] instead. To disable user
/// interaction on this board (e.g. at the end of a game), drive the [controller]
/// with game data whose `playerSide` is [PlayerSide.none].
class BoardWidget extends StatelessWidget {
  const BoardWidget({
    required this.size,
    required this.orientation,
    required this.settings,
    required this.controller,
    this.onMove,
    this.shapes = const {},
    this.annotations = const {},
    this.boardOverlay,
    this.error,
    this.boardKey,
  });

  final double size;
  final Side orientation;
  final ChessboardSettings settings;

  /// Controller that drives the board position and game state.
  final ChessboardController controller;

  /// Called when the user completes a move on the board.
  final void Function(Move, {bool? viaDragAndDrop})? onMove;

  /// External shapes to draw on the board (engine arrows, analysis annotations, etc.).
  final Set<Shape> shapes;

  /// Move annotations to display on the board.
  final Map<Square, Annotation> annotations;

  final String? error;
  final Widget? boardOverlay;
  final GlobalKey? boardKey;

  @override
  Widget build(BuildContext context) {
    final board = RepaintBoundary(
      child: Chessboard(
        key: boardKey,
        controller: controller,
        size: size,
        orientation: orientation,
        onMove: onMove,
        shapes: shapes,
        annotations: annotations,
        settings: settings,
      ),
    );

    final overlay = boardOverlay ?? (error != null ? _ErrorWidget(errorMessage: error!) : null);

    if (overlay != null) {
      return Stack(
        clipBehavior: Clip.none,
        children: [
          board,
          Positioned(
            left: 16.0,
            right: 16.0,
            top: 0,
            bottom: 0,
            child: Center(
              child: OverflowBox(maxHeight: double.infinity, child: overlay),
            ),
          ),
        ],
      );
    }

    return board;
  }
}

class _ErrorWidget extends StatelessWidget {
  const _ErrorWidget({required this.errorMessage});
  final String errorMessage;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.all(Radius.circular(10.0)),
      ),
      padding: const EdgeInsets.all(10.0),
      child: Text(errorMessage),
    );
  }
}

/// Computes the valid moves for the board based on the current position and
/// the user's preferences.
Map<Square, Set<Square>> computeValidMoves(
  Position position,
  CastlingMethod castlingMethod,
) {
  final Map<Square, Set<Square>> result = {};
  if (position.isGameOver) {
    return result;
  }
  for (final move in position.legalMoves) {
    final from = move.from;
    final to = move.to;
    if (result.containsKey(from)) {
      result[from]!.add(to);
    } else {
      result[from] = {to};
    }
  }

  // Handle king-over-rook castling if kingTwoSquares is disabled.
  if (castlingMethod == CastlingMethod.kingOverRook ||
      castlingMethod == CastlingMethod.kingTwoSquares) {
    for (final entry in result.entries) {
      final from = entry.key;
      final destSet = entry.value;
      final piece = position.board.pieceAt(from);
      if (piece != null &&
          piece.role == Role.king &&
          (from == Square.e1 || from == Square.e8) &&
          entry.key.file == 4) {
        final dests = position.legalMoves
            .where((m) => m.from == from)
            .map((m) => m.to)
            .toSet();
        if (dests.contains(Square.a1)) {
          destSet.add(Square.c1);
        } else if (dests.contains(Square.a8)) {
          destSet.add(Square.c8);
        }
        if (dests.contains(Square.h1)) {
          destSet.add(Square.g1);
        } else if (dests.contains(Square.h8)) {
          destSet.add(Square.g8);
        }
        if (castlingMethod == CastlingMethod.kingTwoSquares) {
          destSet.removeAll([Square.a1, Square.h1, Square.a8, Square.h8]);
        }
      }
      result[from] = destSet;
    }
  }
  return result;
}
