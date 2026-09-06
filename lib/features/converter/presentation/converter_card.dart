import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/formatters.dart';
import '../../../core/widgets/glass_card.dart';
import '../../rates/application/selected_rate_provider.dart';
import '../../rates/domain/rate_source.dart';
import '../application/converter_controller.dart';

/// Calculadora bidireccional Bs <-> USD/EUR.
class ConverterCard extends ConsumerStatefulWidget {
  const ConverterCard({super.key});

  @override
  ConsumerState<ConverterCard> createState() => _ConverterCardState();
}

class _ConverterCardState extends ConsumerState<ConverterCard> {
  final _foreignCtrl = TextEditingController();
  final _bsCtrl = TextEditingController();
  final _foreignFocus = FocusNode();
  final _bsFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    final s = ref.read(converterProvider);
    _foreignCtrl.text = Formatters.editable(s.foreign);
    _bsCtrl.text = Formatters.editable(s.bs);
  }

  @override
  void dispose() {
    _foreignCtrl.dispose();
    _bsCtrl.dispose();
    _foreignFocus.dispose();
    _bsFocus.dispose();
    super.dispose();
  }

  /// Sincroniza los campos con el estado sin pisar el que el usuario está escribiendo.
  void _sync(ConverterState s) {
    if (!_foreignFocus.hasFocus || s.lastEdited == EditedField.bs) {
      final t = Formatters.editable(s.foreign);
      if (_foreignCtrl.text != t) _foreignCtrl.text = t;
    }
    if (!_bsFocus.hasFocus || s.lastEdited == EditedField.foreign) {
      final t = Formatters.editable(s.bs);
      if (_bsCtrl.text != t) _bsCtrl.text = t;
    }
  }

  void _swap() {
    HapticFeedback.lightImpact();
    final s = ref.read(converterProvider);
    // Intercambia el foco/prioridad: el campo Bs pasa a ser el "origen" con el valor actual en USD y viceversa.
    if (s.lastEdited == EditedField.foreign) {
      ref.read(converterProvider.notifier).setBs(s.foreign);
    } else {
      ref.read(converterProvider.notifier).setForeign(s.bs);
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(converterProvider, (_, next) => _sync(next));
    final state = ref.watch(converterProvider);
    final source = ref.watch(selectedRateProvider);
    final rate = ref.watch(activeRateProvider);
    final theme = Theme.of(context);

    // Primera construcción con tasa recién llegada.
    WidgetsBinding.instance.addPostFrameCallback((_) => _sync(state));

    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.calculate_rounded, color: theme.colorScheme.primary),
              const SizedBox(width: 10),
              Text('Calculadora',
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
              const Spacer(),
              TextButton.icon(
                onPressed: () {
                  HapticFeedback.selectionClick();
                  ref.read(converterProvider.notifier).reset();
                  _foreignFocus.unfocus();
                  _bsFocus.unfocus();
                },
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: const Text('Reiniciar'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _AmountField(
            controller: _foreignCtrl,
            focusNode: _foreignFocus,
            label: source.currencyCode,
            symbol: source.currencySymbol,
            active: state.lastEdited == EditedField.foreign,
            onChanged: (v) =>
                ref.read(converterProvider.notifier).setForeign(Formatters.parse(v) ?? 0),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: [
                Expanded(child: Divider(color: theme.dividerColor.withValues(alpha: 0.4))),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: _SwapButton(onTap: _swap),
                ),
                Expanded(child: Divider(color: theme.dividerColor.withValues(alpha: 0.4))),
              ],
            ),
          ),
          _AmountField(
            controller: _bsCtrl,
            focusNode: _bsFocus,
            label: 'VES',
            symbol: 'Bs',
            active: state.lastEdited == EditedField.bs,
            onChanged: (v) => ref.read(converterProvider.notifier).setBs(Formatters.parse(v) ?? 0),
          ),
          const SizedBox(height: 14),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            child: Text(
              rate == null
                  ? 'Esperando tasa…'
                  : '1 ${source.currencyCode} = Bs ${Formatters.rate(rate.value)}  ·  ${source.shortLabel}',
              key: ValueKey('${source.id}-${rate?.value}'),
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 120.ms, duration: 400.ms).slideY(begin: 0.06, end: 0);
  }
}

class _AmountField extends StatelessWidget {
  const _AmountField({
    required this.controller,
    required this.focusNode,
    required this.label,
    required this.symbol,
    required this.active,
    required this.onChanged,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final String label;
  final String symbol;
  final bool active;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return TextField(
      controller: controller,
      focusNode: focusNode,
      onChanged: onChanged,
      onTap: () {
        // Selecciona todo al enfocar para reemplazar rápido.
        controller.selection = TextSelection(baseOffset: 0, extentOffset: controller.text.length);
      },
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [const ThousandsInputFormatter()],
      style: theme.textTheme.headlineSmall?.copyWith(
        fontWeight: FontWeight.w700,
        fontFeatures: const [FontFeature.tabularFigures()],
      ),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Padding(
          padding: const EdgeInsets.only(left: 18, right: 10),
          child: AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 250),
            style: theme.textTheme.titleLarge!.copyWith(
              fontWeight: FontWeight.w800,
              color: active
                  ? theme.colorScheme.primary
                  : theme.colorScheme.onSurface.withValues(alpha: 0.45),
            ),
            child: Text(symbol),
          ),
        ),
        prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
      ),
    );
  }
}

class _SwapButton extends StatefulWidget {
  const _SwapButton({required this.onTap});
  final VoidCallback onTap;

  @override
  State<_SwapButton> createState() => _SwapButtonState();
}

class _SwapButtonState extends State<_SwapButton> with SingleTickerProviderStateMixin {
  late final _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 400));

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Material(
      color: scheme.primary.withValues(alpha: 0.12),
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: () {
          _ctrl.forward(from: 0);
          widget.onTap();
        },
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: RotationTransition(
            turns: CurvedAnimation(parent: _ctrl, curve: Curves.easeOutBack).drive(Tween<double>(begin: 0, end: 0.5)),
            child: Icon(Icons.swap_vert_rounded, color: scheme.primary, size: 22),
          ),
        ),
      ),
    );
  }
}
