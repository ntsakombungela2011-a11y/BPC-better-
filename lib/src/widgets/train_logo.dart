import 'package:flutter/material.dart';

class TrainLogo extends StatelessWidget {
  const TrainLogo({this.size = 24.0, this.color, super.key});

  final double size;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Icon(
      Icons.train,
      size: size,
      color: color ?? Theme.of(context).colorScheme.primary,
    );
  }
}
