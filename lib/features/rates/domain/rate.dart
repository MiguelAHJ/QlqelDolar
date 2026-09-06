import 'rate_source.dart';

class Rate {
  const Rate({
    required this.source,
    required this.value,
    required this.fetchedAt,
    this.sourceDate,
    this.stale = false,
  });

  final RateSource source;

  /// Bolívares por 1 unidad de la moneda base (USD o EUR).
  final double value;
  final DateTime fetchedAt;
  final DateTime? sourceDate;
  final bool stale;

  factory Rate.fromJson(Map<String, dynamic> json) => Rate(
        source: RateSource.fromId(json['source'] as String),
        value: (json['value'] as num).toDouble(),
        fetchedAt: DateTime.parse(json['fetchedAt'] as String),
        sourceDate:
            json['sourceDate'] != null ? DateTime.tryParse(json['sourceDate'] as String) : null,
        stale: json['stale'] as bool? ?? false,
      );

  Map<String, dynamic> toJson() => {
        'source': source.id,
        'value': value,
        'fetchedAt': fetchedAt.toIso8601String(),
        'sourceDate': sourceDate?.toIso8601String(),
        'stale': stale,
      };
}

class RatesSnapshot {
  const RatesSnapshot({required this.rates, required this.updatedAt, this.fromCache = false});

  final Map<RateSource, Rate> rates;
  final DateTime updatedAt;

  /// true cuando se cargó desde el almacenamiento local (sin red).
  final bool fromCache;

  Rate? operator [](RateSource s) => rates[s];

  factory RatesSnapshot.fromJson(Map<String, dynamic> json, {bool fromCache = false}) {
    final list = (json['rates'] as List).cast<Map<String, dynamic>>().map(Rate.fromJson);
    return RatesSnapshot(
      rates: {for (final r in list) r.source: r},
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      fromCache: fromCache,
    );
  }

  Map<String, dynamic> toJson() => {
        'rates': rates.values.map((r) => r.toJson()).toList(),
        'updatedAt': updatedAt.toIso8601String(),
      };
}
