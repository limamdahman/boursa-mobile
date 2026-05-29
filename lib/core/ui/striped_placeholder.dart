import 'package:flutter/material.dart';

/// Placeholder rayé diagonal à 45° reproduit du mockup CSS
/// `repeating-linear-gradient(45deg, #eef2f6 0 10px, #e6ebf1 10px 20px)`.
class StripedPlaceholder extends StatelessWidget {
  const StripedPlaceholder({
    super.key,
    this.icon,
    this.iconSize = 46,
    this.iconColor = const Color(0x8094A3B8), // slate-400 ~50%
    this.stripeLight = const Color(0xFFEEF2F6),
    this.stripeDark = const Color(0xFFE6EBF1),
    this.stripeWidth = 10,
  });

  final IconData? icon;
  final double iconSize;
  final Color iconColor;
  final Color stripeLight;
  final Color stripeDark;
  final double stripeWidth;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _StripePainter(
        light: stripeLight,
        dark: stripeDark,
        stripeWidth: stripeWidth,
      ),
      child: Center(
        child: Icon(
          icon ?? Icons.directions_car_outlined,
          size: iconSize,
          color: iconColor,
        ),
      ),
    );
  }
}

class _StripePainter extends CustomPainter {
  _StripePainter({
    required this.light,
    required this.dark,
    required this.stripeWidth,
  });

  final Color light;
  final Color dark;
  final double stripeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    // Fond clair.
    canvas.drawRect(
      Offset.zero & size,
      Paint()..color = light,
    );

    final paintDark = Paint()..color = dark;
    final diag = size.width + size.height;
    final step = stripeWidth * 2;

    // Bandes à 45° : on dessine des parallélogrammes en clip.
    canvas.save();
    canvas.clipRect(Offset.zero & size);
    for (double i = -size.height; i < diag; i += step) {
      final path = Path()
        ..moveTo(i, 0)
        ..lineTo(i + stripeWidth, 0)
        ..lineTo(i + stripeWidth + size.height, size.height)
        ..lineTo(i + size.height, size.height)
        ..close();
      canvas.drawPath(path, paintDark);
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _StripePainter old) =>
      old.light != light || old.dark != dark || old.stripeWidth != stripeWidth;
}
