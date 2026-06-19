import 'package:dartchess/dartchess.dart';
import 'package:lichess_mobile/src/model/common/chess.dart';
import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:lichess_mobile/src/model/common/id.dart';
import 'package:lichess_mobile/src/model/engine/evaluation_service.dart';
import 'package:lichess_mobile/src/model/engine/work.dart';
import 'package:multistockfish/multistockfish.dart';

class EngineSuggestion {
  const EngineSuggestion({
    required this.uci,
    required this.centipawns,
    required this.depth,
    required this.isMate,
  });

  final String uci;
  final int centipawns;
  final int depth;
  final bool isMate;
}

class EngineExplorerService {
  EngineExplorerService(this._evaluationService);

  final EvaluationService _evaluationService;

  Future<List<EngineSuggestion>> getTopMoves(String fen, {int n = 5}) async {
    _evaluationService.stop();
    final position = Chess.fromSetup(Setup.parseFen(fen));
    final work = EvalWork(
      id: StringId('offline-explorer'),
      stockfishFlavor: StockfishFlavor.latestNoNNUE,
      variant: Variant.standard,
      threads: 1,
      hashSize: 32,
      searchTime: const Duration(seconds: 20),
      multiPv: n,
      threatMode: false,
      initialPosition: position,
      steps: IList(const []),
    );
    final eval = await _evaluationService.findEval(
      work,
      depthThreshold: 18,
      minSearchTime: const Duration(milliseconds: 500),
    );
    if (eval == null) return const [];
    return eval.pvs.take(n).where((pv) => pv.moves.isNotEmpty).map((pv) {
      final isMate = pv.mate != null;
      return EngineSuggestion(
        uci: pv.moves.first,
        centipawns: pv.cp ?? pv.mate ?? 0,
        depth: eval.depth,
        isMate: isMate,
      );
    }).toList(growable: false);
  }

  void cancel() => _evaluationService.stop();
}
