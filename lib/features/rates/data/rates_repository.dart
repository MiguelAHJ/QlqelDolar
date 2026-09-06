import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../domain/rate.dart';
import 'rates_api.dart';

/// Combina la API con una caché local para que la app abra con datos
/// aunque no haya conexión.
class RatesRepository {
  RatesRepository(this._api, this._prefs);

  static const _cacheKey = 'rates_cache_v1';

  final RatesApi _api;
  final SharedPreferences _prefs;

  RatesSnapshot? readCache() {
    final raw = _prefs.getString(_cacheKey);
    if (raw == null) return null;
    try {
      return RatesSnapshot.fromJson(jsonDecode(raw) as Map<String, dynamic>, fromCache: true);
    } catch (_) {
      return null;
    }
  }

  Future<RatesSnapshot> fetch({bool force = false}) async {
    final snap = force ? await _api.forceRefresh() : await _api.fetchRates();
    await _prefs.setString(_cacheKey, jsonEncode(snap.toJson()));
    return snap;
  }
}
