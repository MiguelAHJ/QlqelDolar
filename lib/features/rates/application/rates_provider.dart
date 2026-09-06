import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/app_config.dart';
import '../../../core/config/shared_prefs_provider.dart';
import '../data/rates_api.dart';
import '../data/rates_repository.dart';
import '../domain/rate.dart';

final ratesRepositoryProvider = Provider<RatesRepository>(
  (ref) => RatesRepository(RatesApi(), ref.watch(sharedPrefsProvider)),
);

/// Estado de las tasas. Carga la caché al instante y luego pide al backend;
/// se auto-refresca cada [AppConfig.refreshInterval].
class RatesNotifier extends AsyncNotifier<RatesSnapshot> {
  Timer? _timer;

  @override
  Future<RatesSnapshot> build() async {
    _timer?.cancel();
    _timer = Timer.periodic(AppConfig.refreshInterval, (_) => refresh());
    ref.onDispose(() => _timer?.cancel());

    final repo = ref.read(ratesRepositoryProvider);
    final cached = repo.readCache();
    if (cached != null) {
      // Muestra la caché ya y actualiza en segundo plano.
      unawaited(refresh());
      return cached;
    }
    return repo.fetch();
  }

  /// Actualiza sin pasar por el estado de carga (conserva el valor previo).
  Future<void> refresh({bool force = false}) async {
    final repo = ref.read(ratesRepositoryProvider);
    final previous = state.valueOrNull;
    try {
      final snap = await repo.fetch(force: force);
      state = AsyncData(snap);
    } catch (e, st) {
      if (previous != null) {
        // Mantiene los datos anteriores pero reporta el error en `error`.
        state = AsyncError<RatesSnapshot>(e, st).copyWithPrevious(AsyncData(previous));
      } else {
        state = AsyncError(e, st);
      }
    }
  }
}

final ratesProvider = AsyncNotifierProvider<RatesNotifier, RatesSnapshot>(RatesNotifier.new);
