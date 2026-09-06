import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Tarjeta con borde sutil y sombra suave, usada en toda la app.
class GlassCard extends StatelessWidget {
  const GlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(20),
    this.gradient,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final Gradient? gradient;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        color: gradient == null ? theme.cardTheme.color : null,
        gradient: gradient,
        borderRadius: BorderRadius.circular(AppTheme.radius),
        border: Border.all(
          color: isDark ? Colors.white.withValues(alpha: 0.06) : Colors.black.withValues(alpha: 0.05),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.06),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Padding(padding: padding, child: child),
    );
  }
}
