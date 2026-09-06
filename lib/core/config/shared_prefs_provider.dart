import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Se sobreescribe en `main()` con la instancia real.
final sharedPrefsProvider = Provider<SharedPreferences>(
  (ref) => throw UnimplementedError('sharedPrefsProvider debe sobreescribirse en main()'),
);
