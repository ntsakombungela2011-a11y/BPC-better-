import 'dart:math' as math;
import 'package:flutter/material.dart';

class AnimatedTrainLogo extends StatefulWidget {
  final double size;
  final AnimationController? controller;
  final bool reverse;
  final VoidCallback? onFinish;

  const AnimatedTrainLogo({
    super.key,
    this.size = 200,
    this.controller,
    this.reverse = false,
    this.onFinish,
  });

  @override
  State<AnimatedTrainLogo> createState() => _AnimatedTrainLogoState();
}

class _AnimatedTrainLogoState extends State<AnimatedTrainLogo>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ??
        AnimationController(
          duration: const Duration(milliseconds: 800),
          vsync: this,
        );
    if (widget.controller == null) {
      _controller.forward();
    }
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOutCubic,
    );
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed && widget.reverse) {
        _controller.reverse();
      } else if (status == AnimationStatus.dismissed && widget.reverse) {
        _controller.forward();
      } else if (status == AnimationStatus.completed && !widget.reverse) {
        widget.onFinish?.call();
      }
    });
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return CustomPaint(
          size: Size(widget.size, widget.size * 0.55),
          painter: _TrainLogoPainter(
            progress: _animation.value,
            reverse: widget.reverse,
          ),
        );
      },
    );
  }
}

class _TrainLogoPainter extends CustomPainter {
  _TrainLogoPainter({required this.progress, this.reverse = false});

  final double progress;
  final bool reverse;

  static const _navy = Color(0xFF1A237E);
  static const _white = Color(0xFFFFFFFF);
  static const _orange = Color(0xFFFF6F00);
  static const _windowBlue = Color(0xFF90CAF9);
  static const _outline = Color(0xFF0D1137);

  double _p(double value, double max) => value * max;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final scale = w / 300;

    final outlinePaint = Paint()
      ..color = _outline
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5 * scale
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final fillPaint = Paint()
      ..style = PaintingStyle.fill
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final bodyPath = Path();
    _buildBodyPath(bodyPath, w, h);

    final whiteStripePaths = <Path>[
      _buildStripePath(w, h, scale, 0.30, 0.04),
      _buildStripePath(w, h, scale, 0.37, 0.04),
    ];

    final orangeStripePath = _buildStripePath(w, h, scale, 0.44, 0.04);

    final windowPath = Path();
    _buildWindowPath(windowPath, w, h, scale);

    final effectiveProgress = reverse ? 1.0 - progress : progress;

    final bodyFillProgress = _clampProgress(effectiveProgress, 0.0, 0.45);
    final whiteStripesProgress = _clampProgress(effectiveProgress, 0.35, 0.60);
    final orangeStripeProgress = _clampProgress(effectiveProgress, 0.55, 0.78);
    final windowProgress = _clampProgress(effectiveProgress, 0.72, 1.0);

    _drawProgressiveFill(canvas, bodyPath, fillPaint..color = _navy, bodyFillProgress);
    for (final sp in whiteStripePaths) {
      _drawProgressiveFill(canvas, sp, fillPaint..color = _white, whiteStripesProgress);
    }
    _drawProgressiveFill(canvas, orangeStripePath, fillPaint..color = _orange, orangeStripeProgress);
    _drawProgressiveFill(canvas, windowPath, fillPaint..color = _windowBlue, windowProgress);

    _drawFullPath(canvas, bodyPath, outlinePaint);
  }

  double _clampProgress(double total, double start, double end) {
    if (total <= start) return 0.0;
    if (total >= end) return 1.0;
    return (total - start) / (end - start);
  }

  void _buildBodyPath(Path path, double w, double h) {
    final topY = h * 0.10;
    final botY = h * 0.80;
    final midY = h * 0.45;
    final noseX = w * 0.08;
    final rearX = w * 0.92;

    path.moveTo(noseX, midY);
    path.cubicTo(
      w * 0.02, midY - h * 0.15,
      w * 0.04, topY + h * 0.02,
      w * 0.12, topY,
    );
    path.lineTo(rearX, topY);
    path.lineTo(rearX, botY);
    path.lineTo(w * 0.12, botY);
    path.cubicTo(
      w * 0.04, botY - h * 0.02,
      w * 0.02, midY + h * 0.15,
      noseX, midY,
    );
    path.close();
  }

  void _buildWindowPath(Path path, double w, double h, double scale) {
    final winLeft = w * 0.12 + 8 * scale;
    final winTop = h * 0.15;
    final winRight = w * 0.35;
    final winBot = h * 0.62;
    final winMidX = (winLeft + winRight) / 2;
    final winMidY = (winTop + winBot) / 2;

    path.moveTo(winLeft, winMidY);
    path.cubicTo(
      winLeft, winTop + h * 0.05,
      winLeft + (winRight - winLeft) * 0.2, winTop,
      winMidX, winTop,
    );
    path.cubicTo(
      winRight - (winRight - winLeft) * 0.2, winTop,
      winRight, winTop + h * 0.05,
      winRight, winMidY,
    );
    path.cubicTo(
      winRight, winBot - h * 0.05,
      winRight - (winRight - winLeft) * 0.2, winBot,
      winMidX, winBot,
    );
    path.cubicTo(
      winLeft + (winRight - winLeft) * 0.2, winBot,
      winLeft, winBot - h * 0.05,
      winLeft, winMidY,
    );
    path.close();
  }

  Path _buildStripePath(double w, double h, double scale, double yFrac, double heightFrac) {
    final path = Path();
    final y = h * yFrac;
    final stripeH = h * heightFrac;
    final left = w * 0.12 + 6 * scale;
    final right = w * 0.88;

    path.addRRect(RRect.fromRectAndRadius(
      Rect.fromLTRB(left, y, right, y + stripeH),
      Radius.circular(2 * scale),
    ));
    return path;
  }

  void _drawProgressiveFill(Canvas canvas, Path path, Paint paint, double localProgress) {
    if (localProgress <= 0) return;
    if (localProgress >= 1) {
      canvas.drawPath(path, paint);
      return;
    }

    final metrics = path.computeMetrics();
    for (final metric in metrics) {
      final totalLength = metric.length;
      final drawLength = totalLength * localProgress;
      final extract = metric.extractPath(0, drawLength);
      canvas.drawPath(extract, paint);
    }
  }

  void _drawFullPath(Canvas canvas, Path path, Paint paint) {
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_TrainLogoPainter oldDelegate) =>
      oldDelegate.progress != progress || oldDelegate.reverse != reverse;
}
