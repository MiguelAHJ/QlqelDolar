import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// Placeholder con efecto shimmer para estados de carga.
class ShimmerBox extends StatelessWidget {
  const ShimmerBox({super.key, this.width, this.height = 16, this.radius = 10});

  final double? width;
  final double height;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(radius),
      ),
    ).animate(onPlay: (c) => c.repeat()).shimmer(
          duration: 1400.ms,
          color: isDark ? Colors.white.withValues(alpha: 0.12) : Colors.white.withValues(alpha: 0.7),
        );
  }
}
