/// Configuración global de la app.
///
/// Por defecto apunta al backend publicado en Render. Para desarrollo local
/// se sobreescribe en tiempo de compilación:
///   flutter run --dart-define=API_BASE_URL=http://10.0.2.2:3000/api   (emulador)
///   flutter run --dart-define=API_BASE_URL=http://192.168.1.20:3000/api (teléfono en tu WiFi)
class AppConfig {
  AppConfig._();

  static const apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://qlqeldolar-backend.onrender.com/api',
  );

  /// Cada cuánto la app vuelve a pedir las tasas al backend.
  static const refreshInterval = Duration(minutes: 5);
}
