import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/shared_prefs_provider.dart';

class ThemeModeNotifier extends Notifier<ThemeMode> {
  static const _key = 'theme_mode';

  @override
  ThemeMode build() {
    final saved = ref.read(sharedPrefsProvider).getString(_key);
    return ThemeMode.values.firstWhere((m) => m.name == saved, orElse: () => ThemeMode.system);
  }

  /// Alterna claro/oscuro tomando como referencia el brillo actual de la UI.
  void toggle(Brightness current) {
    set(current == Brightness.dark ? ThemeMode.light : ThemeMode.dark);
  }

  void set(ThemeMode mode) {
    state = mode;
    ref.read(sharedPrefsProvider).setString(_key, mode.name);
  }
}

final themeModeProvider = NotifierProvider<ThemeModeNotifier, ThemeMode>(ThemeModeNotifier.new);
