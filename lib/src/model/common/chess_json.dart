import 'package:deep_pick/deep_pick.dart';
import 'package:dartchess/dartchess.dart';
import 'package:lichess_mobile/src/model/common/chess.dart';

extension ChessJsonExtension on Pick {
  Side asSideOrThrow() {
    final value = required().value;
    if (value is Side) return value;
    if (value is String) {
      return value == 'white' ? Side.white : Side.black;
    }
    throw PickException("value $value at $debugParsingExit can't be casted to Side");
  }

  Side? asSideOrNull() {
    if (value == null) return null;
    try {
      return asSideOrThrow();
    } catch (_) {
      return null;
    }
  }

  Variant asVariantOrThrow() {
    final value = required().value;
    if (value is Variant) return value;
    if (value is String) {
      return Variant.nameMap[value] ?? Variant.standard;
    }
    throw PickException("value $value at $debugParsingExit can't be casted to Variant");
  }

  Variant? asVariantOrNull() {
    if (value == null) return null;
    try {
      return asVariantOrThrow();
    } catch (_) {
      return null;
    }
  }

  Move? asUciMoveOrNull() {
    final v = value;
    if (v == null) return null;
    if (v is Move) return v;
    if (v is String) return Move.parse(v);
    return null;
  }

  Move asUciMoveOrThrow() {
    final move = asUciMoveOrNull();
    if (move != null) return move;
    throw PickException("value $value at $debugParsingExit can't be casted to Move");
  }
}
