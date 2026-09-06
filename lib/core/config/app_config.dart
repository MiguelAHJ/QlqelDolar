/// Configuración global de la app.
///
/// La URL del backend se puede sobreescribir en tiempo de compilación:
///   flutter run --dart-define=API_BASE_URL=http://192.168.1.20:3000/api
class AppConfig {
  AppConfig._();

  /// 10.0.2.2 es el host de la PC desde el emulador de Android.
  /// En un teléfono físico usa la IP de tu PC en la red local.
  static const apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.0.2.2:3000/api',
  );

  /// Cada cuánto la app vuelve a pedir las tasas al backend.
  static const refreshInterval = Duration(minutes: 5);
}
