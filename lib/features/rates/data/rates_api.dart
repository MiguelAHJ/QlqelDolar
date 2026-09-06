import 'package:dio/dio.dart';

import '../../../core/config/app_config.dart';
import '../domain/rate.dart';

/// Cliente HTTP del backend NestJS.
class RatesApi {
  RatesApi([Dio? dio])
      : _dio = dio ??
            Dio(BaseOptions(
              baseUrl: AppConfig.apiBaseUrl,
              // Render (plan free) duerme el servicio y tarda 30-60 s en despertar:
              // damos margen para que la primera petición no falle por timeout.
              connectTimeout: const Duration(seconds: 30),
              receiveTimeout: const Duration(seconds: 75),
            ));

  final Dio _dio;

  Future<RatesSnapshot> fetchRates() async {
    final res = await _dio.get<Map<String, dynamic>>('/rates');
    return RatesSnapshot.fromJson(res.data!);
  }

  Future<RatesSnapshot> forceRefresh() async {
    final res = await _dio.post<Map<String, dynamic>>('/rates/refresh');
    return RatesSnapshot.fromJson(res.data!);
  }
}
