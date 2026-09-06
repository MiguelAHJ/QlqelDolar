import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../rates/application/selected_rate_provider.dart';
import '../../../rates/domain/rate_source.dart';

/// Selector tipo "segmented control" con indicador deslizante animado.
class RateSelector extends ConsumerWidget {
  const RateSelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(selectedRateProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final sources = RateSource.values;
    final index = sources.indexOf(selected);

    return Container(
      height: 52,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final w = constraints.maxWidth / sources.length;
          return Stack(
            children: [
              AnimatedPositioned(
                duration: const Duration(milliseconds: 320),
                curve: Curves.easeOutBack,
                left: index * w,
                top: 0,
                bottom: 0,
                width: w,
                child: Container(
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: theme.colorScheme.primary.withValues(alpha: 0.35),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                ),
              ),
              Row(
                children: [
                  for (final s in sources)
                    Expanded(
                      child: _SegmentButton(
                        source: s,
                        selected: s == selected,
                        onTap: () {
                          HapticFeedback.selectionClick();
                          ref.read(selectedRateProvider.notifier).select(s);
                        },
                      ),
                    ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}

class _SegmentButton extends StatelessWidget {
  const _SegmentButton({required this.source, required this.selected, required this.onTap});

  final RateSource source;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final color = selected ? scheme.onPrimary : scheme.onSurface.withValues(alpha: 0.7);
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Center(
        child: AnimatedDefaultTextStyle(
          duration: const Duration(milliseconds: 250),
          style: Theme.of(context).textTheme.labelLarge!.copyWith(
                color: color,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(source.icon, size: 16, color: color),
              const SizedBox(width: 5),
              Text(source.shortLabel),
            ],
          ),
        ),
      ),
    );
  }
}
