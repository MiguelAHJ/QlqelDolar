import 'package:flutter/material.dart';

/// Fuentes de tasa disponibles. El `id` coincide con el enum del backend.
enum RateSource {
  bcv('bcv', 'BCV', 'Banco Central de Venezuela', Icons.account_balance_rounded),
  eur('eur', 'Euro', 'Euro oficial BCV', Icons.euro_rounded),
  binance('binance', 'Binance', 'Binance P2P · USDT/VES', Icons.currency_bitcoin_rounded),
  promedio('promedio', 'Promedio', 'Promedio BCV + Binance', Icons.balance_rounded);

  const RateSource(this.id, this.shortLabel, this.description, this.icon);

  final String id;
  final String shortLabel;
  final String description;
  final IconData icon;

  /// Símbolo de la moneda base de la tasa.
  String get currencySymbol => this == RateSource.eur ? '€' : r'$';
  String get currencyCode => this == RateSource.eur ? 'EUR' : 'USD';

  static RateSource fromId(String id) =>
      RateSource.values.firstWhere((s) => s.id == id, orElse: () => RateSource.bcv);
}
