import 'package:flutter/material.dart';

/// Paleta de la app. Acento teal/verde "fintech" con soporte claro/oscuro.
class AppColors {
  AppColors._();

  static const seed = Color(0xFF14B8A6); // teal
  static const accent = Color(0xFF2DD4BF);
  static const accentDeep = Color(0xFF0F766E);
  static const gold = Color(0xFFF5B301);

  // Fondos oscuros
  static const darkBg = Color(0xFF0B1220);
  static const darkSurface = Color(0xFF111A2E);
  static const darkCard = Color(0xFF16213A);

  // Fondos claros
  static const lightBg = Color(0xFFF3F6FB);
  static const lightSurface = Color(0xFFFFFFFF);
  static const lightCard = Color(0xFFFFFFFF);

  static const success = Color(0xFF22C55E);
  static const warning = Color(0xFFF59E0B);
  static const danger = Color(0xFFEF4444);

  /// Gradiente principal (tarjeta de tasa).
  static const heroGradientDark = [Color(0xFF0F766E), Color(0xFF115E59), Color(0xFF1E3A8A)];
  static const heroGradientLight = [Color(0xFF14B8A6), Color(0xFF0D9488), Color(0xFF2563EB)];
}
