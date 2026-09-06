import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../core/config/app_config.dart';

/// Pantalla de error cuando no hay ningún dato (ni caché).
class ErrorView extends StatelessWidget {
  const ErrorView({super.key, required this.onRetry});
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.wifi_off_rounded, size: 64, color: theme.colorScheme.primary)
                .animate(onPlay: (c) => c.repeat(reverse: true))
                .scale(begin: const Offset(1, 1), end: const Offset(1.08, 1.08), duration: 1200.ms),
            const SizedBox(height: 20),
            Text('No pudimos obtener las tasas',
                style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                textAlign: TextAlign.center),
            const SizedBox(height: 8),
            Text(
              'Revisa tu conexión y que el servidor esté disponible en\n${AppConfig.apiBaseUrl}',
              style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Reintentar'),
            ),
          ],
        ),
      ),
    );
  }
}
