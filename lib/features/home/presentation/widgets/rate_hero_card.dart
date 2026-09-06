import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/animated_number.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../../../core/widgets/shimmer_box.dart';
import '../../../rates/application/rates_provider.dart';
import '../../../rates/application/selected_rate_provider.dart';
import '../../../rates/domain/rate.dart';

/// Tarjeta principal con la tasa seleccionada en grande.
class RateHeroCard extends ConsumerWidget {
  const RateHeroCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final source = ref.watch(selectedRateProvider);
    final rate = ref.watch(activeRateProvider);
    final isLoading = ref.watch(ratesProvider).isLoading && rate == null;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return GlassCard(
      padding: const EdgeInsets.fromLTRB(22, 22, 22, 20),
      gradient: LinearGradient(
        colors: isDark ? AppColors.heroGradientDark : AppColors.heroGradientLight,
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      child: DefaultTextStyle(
        style: const TextStyle(color: Colors.white),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(source.icon, color: Colors.white, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: Column(
                      key: ValueKey(source),
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Tasa ${source.shortLabel}',
                            style: theme.textTheme.titleMedium?.copyWith(
                                color: Colors.white, fontWeight: FontWeight.w700)),
                        Text(source.description,
                            style: theme.textTheme.bodySmall
                                ?.copyWith(color: Colors.white.withValues(alpha: 0.75))),
                      ],
                    ),
                  ),
                ),
                if (rate?.stale == true)
                  Tooltip(
                    message: 'La fuente no respondió; se muestra el último valor conocido.',
                    child: Icon(Icons.history_toggle_off_rounded,
                        color: Colors.white.withValues(alpha: 0.85), size: 20),
                  ),
              ],
            ),
            const SizedBox(height: 22),
            if (isLoading)
              const ShimmerBox(width: 220, height: 48, radius: 12)
            else
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text('Bs ',
                      style: theme.textTheme.titleLarge?.copyWith(
                          color: Colors.white.withValues(alpha: 0.8), fontWeight: FontWeight.w600)),
                  Flexible(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: AnimatedNumber(
                        value: rate?.value ?? 0,
                        format: Formatters.rate,
                        style: theme.textTheme.displayMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -1.5,
                          fontFeatures: const [FontFeature.tabularFigures()],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            const SizedBox(height: 6),
            Text(
              'por 1 ${source.currencyCode}',
              style: theme.textTheme.bodyMedium?.copyWith(color: Colors.white.withValues(alpha: 0.75)),
            ),
            const SizedBox(height: 16),
            _Footer(rate: rate),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.06, end: 0, curve: Curves.easeOutCubic);
  }
}

class _Footer extends StatelessWidget {
  const _Footer({required this.rate});
  final Rate? rate;

  @override
  Widget build(BuildContext context) {
    final r = rate;
    if (r == null) return const ShimmerBox(width: 160, height: 12);
    final style = Theme.of(context)
        .textTheme
        .bodySmall
        ?.copyWith(color: Colors.white.withValues(alpha: 0.7));
    final sourceDate = r.sourceDate;
    return Row(
      children: [
        Icon(Icons.schedule_rounded, size: 14, color: Colors.white.withValues(alpha: 0.7)),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            sourceDate != null
                ? 'Fecha valor: ${Formatters.shortDate(sourceDate)} · actualizado ${Formatters.timeAgo(r.fetchedAt)}'
                : 'Actualizado ${Formatters.timeAgo(r.fetchedAt)}',
            style: style,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
