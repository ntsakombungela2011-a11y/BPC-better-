import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lichess_mobile/src/model/analysis/analysis_preferences.dart';
import 'package:lichess_mobile/src/model/engine/engine_evaluation.dart';
import 'package:lichess_mobile/src/styles/styles.dart';
import 'package:lichess_mobile/src/widgets/feedback.dart';

class EngineButton extends ConsumerWidget {
  const EngineButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final eval = ref.watch(engineEvaluationProvider);
    final theme = Theme.of(context);
    final textColor = theme.colorScheme.onSurface;

    final loadingIndicator = SizedBox(
      width: 10,
      height: 10,
      child: AnimatedTrainLogo(size: 10, color: textColor.withValues(alpha: 0.7)),
    );

    return ListTile(
      leading: Image.asset('assets/images/stockfish/icon.png', width: 44, height: 44),
      title: const Text('Stockfish'),
      subtitle: eval.maybeWhen(
        loading: () => loadingIndicator,
        data: (data) => Text(data.label),
        orElse: () => null,
      ),
      onTap: () {
        ref.read(engineEvaluationPreferencesProvider.notifier).toggleEvaluation();
      },
    );
  }
}
