import 'package:chessground/chessground.dart';
import 'package:dartchess/dartchess.dart';
import 'package:deep_pick/deep_pick.dart';
import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:flutter/widgets.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:lichess_mobile/l10n/l10n.dart';
import 'package:lichess_mobile/src/model/settings/board_preferences.dart';
import 'package:lichess_mobile/src/styles/lichess_icons.dart';
import 'package:lichess_mobile/src/widgets/board.dart';

part 'chess.freezed.dart';
part 'chess.g.dart';

/// Move represented with UCI notation
typedef UCIMove = String;

/// Represents a [Move] with its associated SAN.
@Freezed(fromJson: true, toJson: true)
sealed class SanMove with _$SanMove {
  const SanMove._();
  const factory SanMove(String san, @MoveConverter() Move move) = _SanMove;

  factory SanMove.fromJson(Map<String, dynamic> json) => _$SanMoveFromJson(json);

  bool get isCheck => san.endsWith('+');
  bool get isCheckmate => san.endsWith('#');
  bool get isCapture => san.contains('x');
  bool get isCastles => san.startsWith('O-O');

  UCIMove normalizeUci(Variant variant) {
    if (variant == Variant.chess960) {
      return move.uci;
    }
    if (isCastles) {
      return kingTakesRookCastles[move.uci] ?? move.uci;
    } else {
      return move.uci;
    }
  }

  bool isIrreversible(Variant variant) {
    if (isCheck) return true;
    if (variant == Variant.crazyhouse) return false;
    if (isCapture) return true;
    if (san[0].toLowerCase() == san[0]) return true; // pawn move
    return variant == Variant.threeCheck && isCheck;
  }
}

class MoveConverter implements JsonConverter<Move, String> {
  const MoveConverter();

  @override
  Move fromJson(String json) => Move.parse(json)!;

  @override
  String toJson(Move object) => object.uci;
}

const altCastles = {'e1a1': 'e1c1', 'e1h1': 'e1g1', 'e8a8': 'e8c8', 'e8h8': 'e8g8'};
const kingTakesRookCastles = {'e1c1': 'e1a1', 'e1g1': 'e1h1', 'e8c8': 'e8a8', 'e8g8': 'e8h8'};

String normalizeUci(String uci) => kingTakesRookCastles[uci] ?? uci;

bool isPromotionPawnMove(Position position, NormalMove move) {
  return move.promotion == null &&
      position.board.roleAt(move.from) == Role.pawn &&
      ((move.to.rank == Rank.first && position.turn == Side.black) ||
          (move.to.rank == Rank.eighth && position.turn == Side.white));
}

String fenToEpd(String fen) {
  return fen.split(' ').take(4).join(' ');
}

const ISet<Variant> readSupportedVariants = ISetConst({
  Variant.standard,
  Variant.chess960,
  Variant.fromPosition,
  Variant.antichess,
  Variant.atomic,
  Variant.kingOfTheHill,
  Variant.threeCheck,
  Variant.racingKings,
  Variant.horde,
  Variant.crazyhouse,
});

const IList<Variant> playSupportedVariants = IListConst([
  Variant.standard,
  Variant.chess960,
  Variant.kingOfTheHill,
  Variant.threeCheck,
  Variant.crazyhouse,
  Variant.antichess,
  Variant.atomic,
  Variant.horde,
  Variant.racingKings,
  Variant.fromPosition,
]);

enum Variant {
  standard(LichessIcons.crown),
  chess960(LichessIcons.die_six),
  fromPosition(LichessIcons.feather),
  antichess(LichessIcons.antichess),
  kingOfTheHill(LichessIcons.flag),
  threeCheck(LichessIcons.three_check),
  atomic(LichessIcons.atom),
  horde(LichessIcons.horde),
  racingKings(LichessIcons.racing_kings),
  crazyhouse(LichessIcons.h_square);

  const Variant(this.icon);

  final IconData icon;

  String label(AppLocalizations l10n) {
    switch (this) {
      case Variant.standard: return l10n.variantStandard;
      case Variant.chess960: return l10n.variantChess960;
      case Variant.fromPosition: return l10n.variantFromPosition;
      case Variant.antichess: return l10n.variantAntichess;
      case Variant.kingOfTheHill: return l10n.variantKingOfTheHill;
      case Variant.threeCheck: return l10n.variantThreeCheck;
      case Variant.atomic: return l10n.variantAtomic;
      case Variant.horde: return l10n.variantHorde;
      case Variant.racingKings: return l10n.variantRacingKings;
      case Variant.crazyhouse: return l10n.variantCrazyhouse;
    }
  }

  String get pgnName {
    switch (this) {
      case Variant.standard: return 'Standard';
      case Variant.chess960: return 'Chess960';
      case Variant.fromPosition: return 'From Position';
      case Variant.antichess: return 'Antichess';
      case Variant.kingOfTheHill: return 'King of the Hill';
      case Variant.threeCheck: return 'Three Check';
      case Variant.atomic: return 'Atomic';
      case Variant.horde: return 'Horde';
      case Variant.racingKings: return 'Racing Kings';
      case Variant.crazyhouse: return 'Crazyhouse';
    }
  }

  bool sideCanCastle(Side side) {
    if (this == Variant.racingKings) return false;
    if (this == Variant.antichess) return false;
    if (side == Side.white && this == Variant.horde) return false;
    return true;
  }

  bool get hasEnPassant => this != Variant.racingKings;
  bool get isReadSupported => readSupportedVariants.contains(this);
  bool get isPlaySupported => playSupportedVariants.contains(this);
  bool get hasDropMoves => this == Variant.crazyhouse;

  static final IMap<String, Variant> nameMap = IMap(values.asNameMap());

  static Variant fromRule(Rule rule) {
    switch (rule) {
      case Rule.chess: return Variant.standard;
      case Rule.antichess: return Variant.antichess;
      case Rule.kingofthehill: return Variant.kingOfTheHill;
      case Rule.threecheck: return Variant.threeCheck;
      case Rule.atomic: return Variant.atomic;
      case Rule.horde: return Variant.horde;
      case Rule.racingKings: return Variant.racingKings;
      case Rule.crazyhouse: return Variant.crazyhouse;
    }
  }

  Position get initialPosition {
    switch (this) {
      case Variant.standard: return Chess.initial;
      case Variant.chess960: throw ArgumentError('Chess960 has no single initial position');
      case Variant.fromPosition: throw ArgumentError('FromPosition has no defined initial position');
      case Variant.antichess: return Antichess.initial;
      case Variant.kingOfTheHill: return KingOfTheHill.initial;
      case Variant.threeCheck: return ThreeCheck.initial;
      case Variant.atomic: return Atomic.initial;
      case Variant.crazyhouse: return Crazyhouse.initial;
      case Variant.horde: return Horde.initial;
      case Variant.racingKings: return RacingKings.initial;
    }
  }

  Rule get rule {
    switch (this) {
      case Variant.standard:
      case Variant.chess960:
      case Variant.fromPosition:
        return Rule.chess;
      default:
        return Rule.values.byName(name);
    }
  }
}

sealed class Opening {
  String get eco;
  String get name;
}

@Freezed(fromJson: true, toJson: true)
sealed class LightOpening with _$LightOpening implements Opening {
  const LightOpening._();
  const factory LightOpening({required String eco, required String name}) = _LightOpening;
  factory LightOpening.fromJson(Map<String, dynamic> json) => _$LightOpeningFromJson(json);
}

@Freezed(fromJson: true, toJson: true)
sealed class Division with _$Division {
  const factory Division({int? middlegame, int? endgame}) = _Division;
  factory Division.fromJson(Map<String, dynamic> json) => _$DivisionFromJson(json);
}

@freezed
sealed class FullOpening with _$FullOpening implements Opening {
  const FullOpening._();
  const factory FullOpening({
    required String eco,
    required String name,
    required String fen,
    required String pgnMoves,
    required String uciMoves,
  }) = _FullOpening;
}

GameData buildGameData({
  required String fen,
  required Variant variant,
  required Position position,
  required PlayerSide playerSide,
  required CastlingMethod castlingMethod,
  required bool boardHighlights,
  Move? lastMove,
}) {
  return GameData(
    fen: fen,
    playerSide: playerSide,
    sideToMove: position.turn,
    validMoves: computeValidMoves(position, castlingMethod),
    lastMove: lastMove,
  );
}

void tryExecutePremove(ChessboardController ctrl, Position position, void Function(Move)? onPremove) {
  final premove = ctrl.premove;
  if (premove != null && onPremove != null) {
    final move = position.legalMoves.values.firstWhereOrNull(
      (m) => m.from == premove.from && m.to == premove.to,
    );
    if (move != null) {
      onPremove(move);
      ctrl.setFullState(ctrl.state.copyWith(premove: null));
    } else {
      ctrl.setFullState(ctrl.state.copyWith(premove: null));
    }
  }
}
