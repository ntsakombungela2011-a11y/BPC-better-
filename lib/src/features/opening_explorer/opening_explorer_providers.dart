import 'package:collection/collection.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lichess_mobile/src/features/opening_explorer/data/engine_explorer_service.dart';
import 'package:lichess_mobile/src/features/opening_explorer/data/opening_trie_reader.dart';
import 'package:lichess_mobile/src/model/engine/evaluation_service.dart';
import 'package:lichess_mobile/src/network/connectivity.dart';

final openingTrieProvider = FutureProvider<OpeningTrieReader>((ref) async {
  final reader = OpeningTrieReader();
  await reader.load();
  return reader;
}, name: 'OfflineOpeningTrieProvider');

final engineExplorerServiceProvider = Provider<EngineExplorerService>((ref) {
  final service = EngineExplorerService(ref.watch(evaluationServiceProvider));
  ref.onDispose(service.cancel);
  return service;
}, name: 'EngineExplorerServiceProvider');

final offlineExplorerProvider = FutureProvider.family<OfflineExplorerState, ExplorerRequest>((
  ref,
  request,
) async {
  final trie = await ref.watch(openingTrieProvider.future);
  final book = trie.query(request.moves);
  if (book != null) return OfflineExplorerStateBook(book);

  final service = ref.watch(engineExplorerServiceProvider);
  ref.onDispose(service.cancel);
  final suggestions = await service.getTopMoves(request.fen);
  return OfflineExplorerStateEngine(suggestions);
}, name: 'OfflineExplorerProvider');

final explorerSourceProvider = FutureProvider.family<ExplorerSource, ExplorerRequest>((
  ref,
  request,
) async {
  final connectivity = await ref.watch(connectivityChangesProvider.future);
  if (connectivity.isOnline) return const ExplorerSourceOnline();
  final offline = await ref.watch(offlineExplorerProvider(request).future);
  return ExplorerSourceOffline(offline);
}, name: 'ExplorerSourceProvider');

class ExplorerRequest {
  ExplorerRequest({required List<String> moves, required this.fen}) : moves = List.unmodifiable(moves);

  final List<String> moves;
  final String fen;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ExplorerRequest &&
          const ListEquality<String>().equals(moves, other.moves) &&
          fen == other.fen;

  @override
  int get hashCode => Object.hash(fen, const ListEquality<String>().hash(moves));
}

sealed class OfflineExplorerState {
  const OfflineExplorerState();
}

class OfflineExplorerStateBook extends OfflineExplorerState {
  const OfflineExplorerStateBook(this.result);

  final OpeningExplorerResult result;
}

class OfflineExplorerStateEngine extends OfflineExplorerState {
  const OfflineExplorerStateEngine(this.suggestions);

  final List<EngineSuggestion> suggestions;
}

sealed class ExplorerSource {
  const ExplorerSource();
}

class ExplorerSourceOnline extends ExplorerSource {
  const ExplorerSourceOnline();
}

class ExplorerSourceOffline extends ExplorerSource {
  const ExplorerSourceOffline(this.state);

  final OfflineExplorerState state;
}
