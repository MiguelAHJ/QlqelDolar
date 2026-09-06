import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Glifo de marca "q$" (propuesta 5) dibujado en vectores.
///
/// [size] es el lado del cuadrado. Con [withBackground] pinta el degradado
/// teal → azul con esquinas redondeadas detrás del glifo (como el ícono de la app).
class BrandMark extends StatelessWidget {
  const BrandMark({
    super.key,
    this.size = 34,
    this.withBackground = true,
    this.color,
    this.accentColor,
  });

  final double size;
  final bool withBackground;

  /// Color del glifo. Por defecto blanco con fondo, o el color primario del tema sin fondo.
  final Color? color;

  /// Color de las barritas del "$". Por defecto igual a [color].
  final Color? accentColor;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final glyph = color ?? (withBackground ? Colors.white : scheme.primary);
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _BrandMarkPainter(
          glyph: glyph,
          accent: accentColor ?? glyph,
          withBackground: withBackground,
        ),
      ),
    );
  }
}

class _BrandMarkPainter extends CustomPainter {
  _BrandMarkPainter({required this.glyph, required this.accent, required this.withBackground});

  final Color glyph;
  final Color accent;
  final bool withBackground;

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width; // unidad: 1 = 1/100 del lado
    final u = s / 100;

    if (withBackground) {
      final rect = Rect.fromLTWH(0, 0, s, s);
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, Radius.circular(22 * u)),
        Paint()
          ..shader = const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.seed, Color(0xFF2563EB)],
          ).createShader(rect),
      );
    }

    // Glifo centrado, ocupando ~72% del lado (mismo encuadre que el ícono).
    final scale = withBackground ? 0.72 : 0.9;
    canvas.save();
    canvas.translate(s / 2, s / 2);
    canvas.scale(scale);
    canvas.translate(-50 * u, -51.4 * u);

    final stroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..color = glyph;

    // Cuenco de la q
    stroke.strokeWidth = 11 * u;
    canvas.drawCircle(Offset(46 * u, 46 * u), 22 * u, stroke);
    // Descendente de la q
    canvas.drawLine(Offset(68 * u, 46 * u), Offset(68 * u, 86 * u), stroke);
    // Barras del $
    stroke
      ..strokeWidth = 5.5 * u
      ..color = accent;
    canvas.drawLine(Offset(46 * u, 14 * u), Offset(46 * u, 24 * u), stroke);
    canvas.drawLine(Offset(46 * u, 68 * u), Offset(46 * u, 78 * u), stroke);

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _BrandMarkPainter old) =>
      old.glyph != glyph || old.accent != accent || old.withBackground != withBackground;
}

/// Lockup horizontal: glifo + "Qlq el Dólar" (+ subtítulo opcional).
class BrandWordmark extends StatelessWidget {
  const BrandWordmark({
    super.key,
    this.markSize = 34,
    this.subtitle,
    this.textStyle,
  });

  final double markSize;
  final String? subtitle;
  final TextStyle? textStyle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final title = textStyle ??
        theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800, letterSpacing: -0.5);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        BrandMark(size: markSize),
        SizedBox(width: markSize * 0.3),
        Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Qlq el Dólar', style: title),
            if (subtitle != null)
              Text(
                subtitle!.toUpperCase(),
                style: theme.textTheme.labelSmall?.copyWith(
                  letterSpacing: 1.6,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
          ],
        ),
      ],
    );
  }
}
