import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../rates/application/selected_rate_provider.dart';

/// Qué campo editó el usuario por última vez; el otro se recalcula.
enum EditedField { foreign, bs }

class ConverterState {
  const ConverterState({
    required this.foreign,
    required this.bs,
    required this.lastEdited,
  });

  /// Monto en la moneda base (USD o EUR según la tasa).
  final double foreign;
  final double bs;
  final EditedField lastEdited;

  ConverterState copyWith({double? foreign, double? bs, EditedField? lastEdited}) =>
      ConverterState(
        foreign: foreign ?? this.foreign,
        bs: bs ?? this.bs,
        lastEdited: lastEdited ?? this.lastEdited,
      );
}

/// Lógica de la calculadora. Por defecto 1 USD = tasa activa en Bs.
/// Cuando cambia la tasa (por selección o refresco) se recalcula el campo
/// que el usuario NO editó por última vez.
class ConverterController extends Notifier<ConverterState> {
  @override
  ConverterState build() {
    // Escucha cambios de tasa sin reconstruir el estado (para no perder lo escrito).
    ref.listen(activeRateProvider, (_, next) => _onRateChanged(next?.value ?? 0));
    final rate = ref.read(activeRateProvider)?.value ?? 0;
    return ConverterState(foreign: 1, bs: rate, lastEdited: EditedField.foreign);
  }

  double get _rate => ref.read(activeRateProvider)?.value ?? 0;

  void _onRateChanged(double rate) {
    if (rate <= 0) return;
    state = state.lastEdited == EditedField.foreign
        ? state.copyWith(bs: state.foreign * rate)
        : state.copyWith(foreign: state.bs / rate);
  }

  void setForeign(double value) {
    state = ConverterState(foreign: value, bs: value * _rate, lastEdited: EditedField.foreign);
  }

  void setBs(double value) {
    final r = _rate;
    state = ConverterState(
      foreign: r > 0 ? value / r : 0,
      bs: value,
      lastEdited: EditedField.bs,
    );
  }

  void reset() => state = ConverterState(foreign: 1, bs: _rate, lastEdited: EditedField.foreign);
}

final converterProvider =
    NotifierProvider<ConverterController, ConverterState>(ConverterController.new);
