import 'package:flutter/material.dart';

/// Texto numérico que interpola suavemente entre el valor anterior y el nuevo.
class AnimatedNumber extends StatelessWidget {
  const AnimatedNumber({
    super.key,
    required this.value,
    required this.format,
    this.style,
    this.duration = const Duration(milliseconds: 600),
  });

  final double value;
  final String Function(double) format;
  final TextStyle? style;
  final Duration duration;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(end: value),
      duration: duration,
      curve: Curves.easeOutCubic,
      builder: (_, v, __) => Text(format(v), style: style, maxLines: 1),
    );
  }
}
