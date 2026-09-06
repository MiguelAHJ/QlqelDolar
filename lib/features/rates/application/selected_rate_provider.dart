import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/shared_prefs_provider.dart';
import '../domain/rate.dart';
import '../domain/rate_source.dart';
import 'rates_provider.dart';

/// Tasa seleccionada por el usuario (persistida). Por defecto BCV.
class SelectedRateNotifier extends Notifier<RateSource> {
  static const _key = 'selected_rate';

  @override
  RateSource build() {
    final saved = ref.read(sharedPrefsProvider).getString(_key);
    return saved != null ? RateSource.fromId(saved) : RateSource.bcv;
  }

  void select(RateSource source) {
    state = source;
    ref.read(sharedPrefsProvider).setString(_key, source.id);
  }
}

final selectedRateProvider =
    NotifierProvider<SelectedRateNotifier, RateSource>(SelectedRateNotifier.new);

/// La tasa activa (objeto completo) o null si aún no hay datos.
final activeRateProvider = Provider<Rate?>((ref) {
  final source = ref.watch(selectedRateProvider);
  return ref.watch(ratesProvider).valueOrNull?[source];
});
