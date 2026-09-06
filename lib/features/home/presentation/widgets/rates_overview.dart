import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/animated_number.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../../../core/widgets/shimmer_box.dart';
import '../../../rates/application/rates_provider.dart';
import '../../../rates/application/selected_rate_provider.dart';
import '../../../rates/domain/rate_source.dart';

/// Resumen compacto de todas las tasas; tocar una la selecciona.
class RatesOverview extends ConsumerWidget {
  const RatesOverview({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final snap = ref.watch(ratesProvider).valueOrNull;
    final selected = ref.watch(selectedRateProvider);
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 10),
          child: Text('Todas las tasas',
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
        ),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.55,
          children: [
            for (final (i, s) in RateSource.values.indexed)
              _MiniRateCard(
                source: s,
                value: snap?[s]?.value,
                stale: snap?[s]?.stale ?? false,
                selected: s == selected,
                onTap: () {
                  HapticFeedback.selectionClick();
                  ref.read(selectedRateProvider.notifier).select(s);
                },
              ).animate().fadeIn(delay: (200 + i * 60).ms, duration: 350.ms).slideY(begin: 0.1, end: 0),
          ],
        ),
      ],
    );
  }
}

class _MiniRateCard extends StatelessWidget {
  const _MiniRateCard({
    required this.source,
    required this.value,
    required this.stale,
    required this.selected,
    required this.onTap,
  });

  final RateSource source;
  final double? value;
  final bool stale;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? scheme.primary : Colors.transparent,
            width: 1.6,
          ),
        ),
        child: GlassCard(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(source.icon, size: 18, color: selected ? scheme.primary : scheme.onSurfaceVariant),
                  const SizedBox(width: 6),
                  Text(source.shortLabel,
                      style: theme.textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600)),
                  const Spacer(),
                  if (stale)
                    Icon(Icons.history_toggle_off_rounded, size: 14, color: scheme.onSurfaceVariant),
                ],
              ),
              if (value == null)
                const ShimmerBox(width: 90, height: 22)
              else
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: AnimatedNumber(
                    value: value!,
                    format: (v) => 'Bs ${Formatters.bs(v)}',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
