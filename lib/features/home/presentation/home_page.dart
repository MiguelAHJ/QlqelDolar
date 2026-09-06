import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/widgets/brand_mark.dart';
import '../../converter/presentation/converter_card.dart';
import '../../rates/application/rates_provider.dart';
import '../../settings/application/theme_mode_provider.dart';
import 'widgets/error_view.dart';
import 'widgets/rate_hero_card.dart';
import 'widgets/rate_selector.dart';
import 'widgets/rates_overview.dart';
import 'widgets/status_banner.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(ratesProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final hasData = async.valueOrNull != null;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
      child: Scaffold(
        appBar: AppBar(
          title: const BrandWordmark(markSize: 34),
          actions: [
            IconButton(
              tooltip: isDark ? 'Modo claro' : 'Modo oscuro',
              onPressed: () {
                HapticFeedback.lightImpact();
                ref.read(themeModeProvider.notifier).toggle(theme.brightness);
              },
              icon: AnimatedSwitcher(
                duration: const Duration(milliseconds: 350),
                transitionBuilder: (child, anim) => RotationTransition(
                  turns: Tween(begin: 0.75, end: 1.0).animate(anim),
                  child: FadeTransition(opacity: anim, child: child),
                ),
                child: Icon(
                  isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                  key: ValueKey(isDark),
                ),
              ),
            ),
            const SizedBox(width: 4),
          ],
        ),
        body: GestureDetector(
          onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
          child: !hasData && async.hasError
              ? ErrorView(onRetry: () => ref.invalidate(ratesProvider))
              : RefreshIndicator(
                  onRefresh: () => ref.read(ratesProvider.notifier).refresh(force: true),
                  edgeOffset: 8,
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(20, 4, 20, 32),
                    keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                    children: const [
                      StatusBanner(),
                      RateSelector(),
                      SizedBox(height: 16),
                      RateHeroCard(),
                      SizedBox(height: 16),
                      ConverterCard(),
                      SizedBox(height: 24),
                      RatesOverview(),
                    ],
                  ),
                ),
        ),
      ),
    );
  }
}
