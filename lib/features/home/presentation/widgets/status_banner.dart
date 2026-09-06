import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../rates/application/rates_provider.dart';

/// Aviso no intrusivo cuando no se pudo actualizar (se muestran datos guardados).
class StatusBanner extends ConsumerWidget {
  const StatusBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(ratesProvider);
    final hasData = async.valueOrNull != null;
    final showOffline = async.hasError && hasData;
    final scheme = Theme.of(context).colorScheme;

    return AnimatedSize(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
      alignment: Alignment.topCenter,
      child: showOffline
          ? Container(
              margin: const EdgeInsets.only(bottom: 14),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: scheme.errorContainer.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  Icon(Icons.cloud_off_rounded, size: 18, color: scheme.onErrorContainer),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Sin conexión con el servidor. Mostrando las últimas tasas guardadas.',
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(color: scheme.onErrorContainer),
                    ),
                  ),
                  TextButton(
                    onPressed: () => ref.read(ratesProvider.notifier).refresh(),
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            )
          : const SizedBox(width: double.infinity),
    );
  }
}
