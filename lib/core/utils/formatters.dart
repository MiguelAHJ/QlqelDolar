import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

/// Formateo/parseo de números al estilo venezolano: 1.234,56
class Formatters {
  Formatters._();

  static final _bs = NumberFormat('#,##0.00', 'es');
  static final _usd = NumberFormat('#,##0.00', 'es');
  static final _rate = NumberFormat('#,##0.00##', 'es');

  static String bs(num value) => _bs.format(value);
  static String usd(num value) => _usd.format(value);
  static String rate(num value) => _rate.format(value);

  /// Acepta "1.234,56", "1234.56", "1234,56" o "1,234.56".
  static double? parse(String raw) {
    var s = raw.trim().replaceAll(' ', '');
    if (s.isEmpty) return null;
    final lastComma = s.lastIndexOf(',');
    final lastDot = s.lastIndexOf('.');
    if (lastComma >= 0 && lastDot >= 0) {
      if (lastComma > lastDot) {
        s = s.replaceAll('.', '').replaceAll(',', '.');
      } else {
        s = s.replaceAll(',', '');
      }
    } else if (lastComma >= 0) {
      s = s.replaceAll(',', '.');
    }
    return double.tryParse(s);
  }

  /// Agrupa la parte entera de un string numérico (solo dígitos) con puntos de millar.
  static String _groupThousands(String digits) {
    if (digits.isEmpty) return digits;
    final buffer = StringBuffer();
    final len = digits.length;
    for (var i = 0; i < len; i++) {
      if (i > 0 && (len - i) % 3 == 0) buffer.write('.');
      buffer.write(digits[i]);
    }
    return buffer.toString();
  }

  /// Formato para escribir dentro de un campo de texto (con miles, coma decimal).
  static String editable(num value, {int decimals = 2}) {
    if (value == 0) return '0';
    var s = value.toStringAsFixed(decimals);
    if (s.contains('.')) {
      s = s.replaceFirst(RegExp(r'0+$'), '').replaceFirst(RegExp(r'\.$'), '');
    }
    final parts = s.split('.');
    final intPart = _groupThousands(parts[0]);
    if (parts.length > 1) {
      return '$intPart,${parts[1]}';
    }
    return intPart;
  }

  static String timeAgo(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inMinutes < 1) return 'hace un momento';
    if (diff.inMinutes < 60) return 'hace ${diff.inMinutes} min';
    if (diff.inHours < 24) return 'hace ${diff.inHours} h';
    return DateFormat('d MMM, HH:mm', 'es').format(date.toLocal());
  }

  /// Hora local corta: 18:05
  static String clock(DateTime date) => DateFormat('HH:mm', 'es').format(date.toLocal());

  static String shortDate(DateTime date) =>
      DateFormat('EEEE d MMM', 'es').format(date.toLocal());
}

/// TextInputFormatter estilo "calculadora de banco/POS": los dígitos se
/// escriben de derecha a izquierda, los últimos [decimals] siempre son la
/// parte decimal y el resto va formando la parte entera con separadores de
/// miles. El cursor siempre queda al final (no se edita en medio del texto).
class ThousandsInputFormatter extends TextInputFormatter {
  const ThousandsInputFormatter({this.decimals = 2});

  final int decimals;

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');

    if (digits.isEmpty) {
      return const TextEditingValue(text: '');
    }

    // Evita overflow con números absurdamente largos.
    const maxDigits = 15;
    final trimmed = digits.length > maxDigits ? digits.substring(digits.length - maxDigits) : digits;

    final value = int.parse(trimmed);
    final divisor = _pow10(decimals);
    final intPart = (value ~/ divisor).toString();
    final fracPart = (value % divisor).toString().padLeft(decimals, '0');

    final groupedInt = Formatters._groupThousands(intPart);
    final formatted = decimals > 0 ? '$groupedInt,$fracPart' : groupedInt;

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }

  static int _pow10(int n) {
    var r = 1;
    for (var i = 0; i < n; i++) {
      r *= 10;
    }
    return r;
  }
}
