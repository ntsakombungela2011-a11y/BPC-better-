import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:lichess_mobile/src/network/connectivity.dart';
import 'package:lichess_mobile/src/network/socket.dart';
import 'package:lichess_mobile/src/styles/styles.dart';
import 'package:lichess_mobile/src/utils/l10n_context.dart';
import 'package:lichess_mobile/src/widgets/buttons.dart';
import 'package:popover/popover.dart';
import 'package:signal_strength_indicator/signal_strength_indicator.dart';
import 'package:url_launcher/url_launcher.dart';

class AnimatedTrainLogo extends StatefulWidget {
  const AnimatedTrainLogo({this.size = 50, this.color, super.key});

  final double size;
  final Color? color;

  @override
  State<AnimatedTrainLogo> createState() => _AnimatedTrainLogoState();
}

class _AnimatedTrainLogoState extends State<AnimatedTrainLogo> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _drawAnimation;
  late Animation<double> _rotateAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 2500),
      vsync: this,
    )..repeat();

    _drawAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.0), weight: 40),
      TweenSequenceItem(tween: ConstantTween(1.0), weight: 20),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.0), weight: 40),
    ]).animate(CurvedAnimation(parent: _controller, curve: const Interval(0.0, 1.0)));

    _rotateAnimation = Tween<double>(begin: 0, end: 2 * math.pi).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.4, 1.0, curve: Curves.easeInOutCubic)),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.rotate(
          angle: _rotateAnimation.value,
          child: CustomPaint(
            size: Size(widget.size, widget.size),
            painter: _TrainPainter(
              progress: _drawAnimation.value,
              color: widget.color ?? ColorScheme.of(context).primary,
            ),
          ),
        );
      },
    );
  }
}

class _TrainPainter extends CustomPainter {
  _TrainPainter({required this.progress, required this.color});

  final double progress;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();
    final scale = size.width / 100;

    // Simplified train path based on SVG
    path.moveTo(25 * scale, 70 * scale);
    path.cubicTo(25 * scale, 75 * scale, 30 * scale, 80 * scale, 35 * scale, 80 * scale);
    path.lineTo(75 * scale, 80 * scale);
    path.cubicTo(80 * scale, 80 * scale, 85 * scale, 75 * scale, 85 * scale, 70 * scale);
    path.lineTo(85 * scale, 45 * scale);
    path.cubicTo(85 * scale, 40 * scale, 80 * scale, 35 * scale, 75 * scale, 35 * scale);
    path.lineTo(45 * scale, 35 * scale);
    path.lineTo(45 * scale, 25 * scale);
    path.cubicTo(45 * scale, 20 * scale, 40 * scale, 15 * scale, 35 * scale, 15 * scale);
    path.lineTo(25 * scale, 15 * scale);
    path.close();

    // Windows
    path.moveTo(35 * scale, 30 * scale);
    path.lineTo(40 * scale, 30 * scale);
    path.lineTo(40 * scale, 35 * scale);
    path.lineTo(35 * scale, 35 * scale);
    path.close();

    path.moveTo(55 * scale, 45 * scale);
    path.lineTo(75 * scale, 45 * scale);
    path.lineTo(75 * scale, 65 * scale);
    path.lineTo(55 * scale, 65 * scale);
    path.close();

    final metrics = path.computeMetrics();
    for (final metric in metrics) {
      final extractPath = metric.extractPath(0, metric.length * progress);
      canvas.drawPath(extractPath, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _TrainPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.color != color;
  }
}

/// A icon that shows the lag rating of the current socket connection.
class SocketPingRatingIcon extends ConsumerWidget {
  const SocketPingRatingIcon({this.socketUri, super.key});

  final Uri? socketUri;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ping = ref.watch(socketPingProvider(socketUri));

    return SemanticIconButton(
      semanticsLabel: 'PING: ${ping.averageLag.inMilliseconds}ms',
      icon: LagIndicator(lagRating: ping.rating, size: 24.0),
      onPressed: () {
        showPopover(
          context: context,
          bodyBuilder: (_) {
            return Consumer(
              builder: (_, ref, _) {
                final p = ref.watch(socketPingProvider(socketUri));
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: Text.rich(
                    TextSpan(
                      text: 'PING: ',
                      children: [
                        TextSpan(
                          text: p.averageLag > Duration.zero
                              ? '${p.averageLag.inMilliseconds}'
                              : '?',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        TextSpan(
                          text: ' ms',
                          style: TextStyle(color: ColorScheme.of(context).onSurface),
                        ),
                      ],
                    ),
                    style: TextStyle(color: ColorScheme.of(context).onSurface),
                  ),
                );
              },
            );
          },
          backgroundColor:
              DialogTheme.of(context).backgroundColor ??
              ColorScheme.of(context).surfaceContainerHigh,
          transitionDuration: Duration.zero,
          popoverTransitionBuilder: (_, child) => child,
        );
      },
    );
  }
}

class SocketPingRatingListTile extends ConsumerWidget {
  const SocketPingRatingListTile({this.socketUri, super.key});

  final Uri? socketUri;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ping = ref.watch(socketPingProvider(socketUri));

    return ListTile(
      leading: LagIndicator(lagRating: ping.rating),
      title: ping.averageLag > Duration.zero
          ? Text.rich(
              TextSpan(
                text: 'PING ',
                children: [
                  TextSpan(
                    text: '${ping.averageLag.inMilliseconds}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: ColorScheme.of(context).onSurface,
                    ),
                  ),
                  const TextSpan(text: ' ms'),
                ],
              ),
              style: TextStyle(color: ColorScheme.of(context).onSurface.withValues(alpha: 0.7)),
            )
          : Text(
              context.l10n.noNetwork,
              style: TextStyle(color: ColorScheme.of(context).onSurface.withValues(alpha: 0.7)),
            ),
      enabled: ping.averageLag > Duration.zero,
      onTap: () {
        launchUrl(Uri.parse('https://lichess.org/lag'));
      },
    );
  }
}

class LagIndicator extends StatelessWidget {
  const LagIndicator({required this.lagRating, this.size = 20.0, super.key})
    : assert(lagRating >= 0 && lagRating <= 4);

  final int lagRating;
  final double size;

  static const inactiveColor = Color(0x339E9E9E);

  static const materialLevels = {
    0: inactiveColor,
    1: Colors.red,
    2: Colors.yellow,
    3: Colors.green,
    4: Colors.green,
  };

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: size,
      child: Stack(
        children: [
          SignalStrengthIndicator.bars(
            barCount: 4,
            minValue: 0,
            maxValue: 4,
            value: lagRating,
            size: size,
            inactiveColor: inactiveColor,
            levels: materialLevels,
          ),
          if (lagRating == 0)
            Center(
              child: AnimatedTrainLogo(size: size, color: Colors.grey),
            ),
        ],
      ),
    );
  }
}

class OfflineBanner extends ConsumerWidget {
  const OfflineBanner();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isOnlineAsync = ref.watch(onlineStatusProvider);
    final theme = Theme.of(context);
    return isOnlineAsync.when(
      data: (isOnline) {
        if (isOnline) {
          return const SizedBox.shrink();
        }
        return Material(
          child: Container(
            height: 40,
            color: theme.colorScheme.tertiaryContainer,
            child: Padding(
              padding: Styles.horizontalBodyPadding,
              child: Row(
                children: [
                  Icon(Icons.report_outlined, color: theme.colorScheme.onTertiaryContainer),
                  const SizedBox(width: 5),
                  Flexible(
                    child: Text(
                      'Network connectivity unavailable.',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: theme.colorScheme.onTertiaryContainer),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (error, stack) => const SizedBox.shrink(),
    );
  }
}

class ButtonLoadingIndicator extends StatelessWidget {
  const ButtonLoadingIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      height: 20,
      width: 20,
      child: AnimatedTrainLogo(size: 20),
    );
  }
}

class CenterLoadingIndicator extends StatelessWidget {
  const CenterLoadingIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(child: AnimatedTrainLogo());
  }
}

class FullScreenRetryRequest extends StatelessWidget {
  const FullScreenRetryRequest({super.key, required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(context.l10n.mobileSomethingWentWrong, style: Styles.sectionTitle),
          const SizedBox(height: 10),
          FilledButton.tonal(onPressed: onRetry, child: Text(context.l10n.retry)),
        ],
      ),
    );
  }
}

enum SnackBarType { error, info, success }

void showSnackBar(BuildContext context, String message, {SnackBarType type = SnackBarType.info}) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(
        message,
        style: type == SnackBarType.error ? const TextStyle(color: Colors.white) : null,
      ),
      backgroundColor: type == SnackBarType.error ? context.lichessColors.error : null,
    ),
  );
}

class TrainSpinner extends StatelessWidget {
  const TrainSpinner({this.size = 50, this.color, super.key});

  final double size;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return AnimatedTrainLogo(size: size, color: color);
  }
}
