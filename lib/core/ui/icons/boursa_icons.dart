import 'package:flutter/material.dart';

/// Icônes custom fidèles au mockup HTML `Boursa_Apercu.html`.
///
/// Reproduisent les SVG inline du mockup via CustomPainter — aucune dépendance.

// ─── 1. Voiture stylisée (placeholder photo) ─────────────────────────────────

class BoursaCarIcon extends StatelessWidget {
  const BoursaCarIcon({
    super.key,
    this.size = 46,
    this.color = const Color(0x8094A3B8),
    this.strokeWidth = 1.3,
  });

  final double size;
  final Color color;
  final double strokeWidth;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: size,
      child: CustomPaint(
        painter: _CarPainter(color: color, strokeWidth: strokeWidth),
      ),
    );
  }
}

class _CarPainter extends CustomPainter {
  _CarPainter({required this.color, required this.strokeWidth});
  final Color color;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width / 24;
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final body = Path()
      ..moveTo(5 * s, 11 * s)
      ..relativeLineTo(1.5 * s, -4.5 * s)
      ..arcToPoint(Offset(8.4 * s, 5 * s), radius: Radius.circular(2 * s))
      ..lineTo(15.6 * s, 5 * s)
      ..arcToPoint(Offset(17.5 * s, 6.5 * s), radius: Radius.circular(2 * s))
      ..lineTo(19 * s, 11 * s);
    canvas.drawPath(body, paint);

    canvas.drawLine(Offset(5 * s, 11 * s), Offset(19 * s, 11 * s), paint);

    final leftWing = Path()
      ..moveTo(5 * s, 11 * s)
      ..arcToPoint(Offset(3 * s, 13 * s),
          radius: Radius.circular(2 * s), clockwise: false)
      ..lineTo(3 * s, 16 * s)
      ..lineTo(5 * s, 16 * s);
    canvas.drawPath(leftWing, paint);

    final rightWing = Path()
      ..moveTo(19 * s, 11 * s)
      ..arcToPoint(Offset(21 * s, 13 * s), radius: Radius.circular(2 * s))
      ..lineTo(21 * s, 16 * s)
      ..lineTo(19 * s, 16 * s);
    canvas.drawPath(rightWing, paint);

    canvas.drawLine(Offset(7 * s, 16 * s), Offset(17 * s, 16 * s), paint);

    final wheelFill = Paint()..color = color..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(7.5 * s, 15.5 * s), 1.2 * s, wheelFill);
    canvas.drawCircle(Offset(16.5 * s, 15.5 * s), 1.2 * s, wheelFill);
  }

  @override
  bool shouldRepaint(covariant _CarPainter old) =>
      old.color != color || old.strokeWidth != strokeWidth;
}

// ─── 2. Coeur (favori) ───────────────────────────────────────────────────────

class BoursaHeartIcon extends StatelessWidget {
  const BoursaHeartIcon({
    super.key,
    this.size = 18,
    this.filled = false,
    this.activeColor = const Color(0xFF16A34A),
    this.inactiveColor = const Color(0xFF475569),
  });

  final double size;
  final bool filled;
  final Color activeColor;
  final Color inactiveColor;

  @override
  Widget build(BuildContext context) {
    final color = filled ? activeColor : inactiveColor;
    return SizedBox.square(
      dimension: size,
      child: CustomPaint(painter: _HeartPainter(color: color, filled: filled)),
    );
  }
}

class _HeartPainter extends CustomPainter {
  _HeartPainter({required this.color, required this.filled});
  final Color color;
  final bool filled;

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width / 24;
    // Cœur symétrique : 2 lobes ronds en haut, V centré en bas (12, 21).
    // Path conçu pour respecter le viewBox 24×24 du mockup.
    final path = Path()
      ..moveTo(12 * s, 21 * s)
      // Côté gauche : pointe → bord gauche en passant par le creux du lobe
      ..cubicTo(2 * s, 13 * s, 2 * s, 6 * s, 6 * s, 5 * s)
      // Lobe gauche : bord gauche → milieu (creux entre les 2 lobes)
      ..cubicTo(10 * s, 4 * s, 12 * s, 6 * s, 12 * s, 8 * s)
      // Lobe droit : milieu → bord droit
      ..cubicTo(12 * s, 6 * s, 14 * s, 4 * s, 18 * s, 5 * s)
      // Côté droit : bord droit → pointe basse
      ..cubicTo(22 * s, 6 * s, 22 * s, 13 * s, 12 * s, 21 * s)
      ..close();

    if (filled) {
      canvas.drawPath(
          path, Paint()..color = color..style = PaintingStyle.fill);
    }
    canvas.drawPath(
      path,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );
  }

  @override
  bool shouldRepaint(covariant _HeartPainter old) =>
      old.color != color || old.filled != filled;
}

// ─── 3. Pin de localisation ──────────────────────────────────────────────────

class BoursaPinIcon extends StatelessWidget {
  const BoursaPinIcon({
    super.key,
    this.size = 13,
    this.color = const Color(0xFF475569),
    this.strokeWidth = 2,
  });

  final double size;
  final Color color;
  final double strokeWidth;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: size,
      child: CustomPaint(
        painter: _PinPainter(color: color, strokeWidth: strokeWidth),
      ),
    );
  }
}

class _PinPainter extends CustomPainter {
  _PinPainter({required this.color, required this.strokeWidth});
  final Color color;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width / 24;
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final path = Path()
      ..moveTo(12 * s, 21 * s)
      ..cubicTo(12 * s, 21 * s, 5 * s, 15.5 * s, 5 * s, 10 * s)
      ..arcToPoint(Offset(19 * s, 10 * s),
          radius: Radius.circular(7 * s), largeArc: false)
      ..cubicTo(19 * s, 15.5 * s, 12 * s, 21 * s, 12 * s, 21 * s)
      ..close();
    canvas.drawPath(path, paint);

    canvas.drawCircle(Offset(12 * s, 10 * s), 2.5 * s, paint);
  }

  @override
  bool shouldRepaint(covariant _PinPainter old) =>
      old.color != color || old.strokeWidth != strokeWidth;
}

// ─── 4. Badge vérifié (étoile + coche) ──────────────────────────────────────

class BoursaVerifiedIcon extends StatelessWidget {
  const BoursaVerifiedIcon({
    super.key,
    this.size = 16,
    this.color = const Color(0xFF16A34A),
  });

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: size,
      child: CustomPaint(painter: _VerifiedPainter(color: color)),
    );
  }
}

class _VerifiedPainter extends CustomPainter {
  _VerifiedPainter({required this.color});
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width / 24;

    final star = Path()
      ..moveTo(12 * s, 2 * s)
      ..relativeLineTo(2.4 * s, 1.8 * s)
      ..relativeLineTo(3 * s, -0.3 * s)
      ..relativeLineTo(1 * s, 2.8 * s)
      ..relativeLineTo(2.5 * s, 1.7 * s)
      ..relativeLineTo(-1 * s, 2.8 * s)
      ..relativeLineTo(1 * s, 2.8 * s)
      ..relativeLineTo(-2.5 * s, 1.7 * s)
      ..relativeLineTo(-1 * s, 2.8 * s)
      ..relativeLineTo(-3 * s, -0.3 * s)
      ..lineTo(12 * s, 22 * s)
      ..relativeLineTo(-2.4 * s, -1.8 * s)
      ..relativeLineTo(-3 * s, 0.3 * s)
      ..relativeLineTo(-1 * s, -2.8 * s)
      ..lineTo(3.1 * s, 16 * s)
      ..relativeLineTo(1 * s, -2.8 * s)
      ..relativeLineTo(-1 * s, -2.8 * s)
      ..relativeLineTo(2.5 * s, -1.7 * s)
      ..relativeLineTo(1 * s, -2.8 * s)
      ..relativeLineTo(3 * s, 0.3 * s)
      ..close();
    canvas.drawPath(star, Paint()..color = color..style = PaintingStyle.fill);

    final check = Path()
      ..moveTo(9 * s, 12 * s)
      ..relativeLineTo(2 * s, 2 * s)
      ..relativeLineTo(4 * s, -4 * s);
    canvas.drawPath(
      check,
      Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );
  }

  @override
  bool shouldRepaint(covariant _VerifiedPainter old) => old.color != color;
}

// ─── 5. Bulle de chat ────────────────────────────────────────────────────────

class BoursaChatIcon extends StatelessWidget {
  const BoursaChatIcon({
    super.key,
    this.size = 22,
    this.filled = false,
    this.color = const Color(0xFF475569),
    this.strokeWidth = 2,
  });

  final double size;
  final bool filled;
  final Color color;
  final double strokeWidth;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: size,
      child: CustomPaint(
        painter: _ChatPainter(
          color: color,
          filled: filled,
          strokeWidth: strokeWidth,
        ),
      ),
    );
  }
}

class _ChatPainter extends CustomPainter {
  _ChatPainter({
    required this.color,
    required this.filled,
    required this.strokeWidth,
  });
  final Color color;
  final bool filled;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width / 24;

    // SVG path exact du mockup (Lucide MessageCircle) :
    // M21 12 a8 8 0 0 1 -11.5 7.2 L4 20 l.9 -5.2 A8 8 0 1 1 21 12 z
    // Cercle parfait rayon 8 avec queue fine triangulaire bas-gauche.
    final bubble = Path()
      ..moveTo(21 * s, 12 * s)
      // Arc relatif a8 8 0 0 1 -11.5 7.2  →  fin : (9.5, 19.2)
      ..arcToPoint(
        Offset(9.5 * s, 19.2 * s),
        radius: Radius.circular(8 * s),
      )
      // Queue : line to (4, 20)
      ..lineTo(4 * s, 20 * s)
      // Line relatif (0.9, -5.2)  →  fin : (4.9, 14.8)
      ..relativeLineTo(0.9 * s, -5.2 * s)
      // Arc absolu A8 8 0 1 1 21 12 (largeArc=true)
      ..arcToPoint(
        Offset(21 * s, 12 * s),
        radius: Radius.circular(8 * s),
        largeArc: true,
      )
      ..close();

    if (filled) {
      canvas.drawPath(
        bubble,
        Paint()..color = color..style = PaintingStyle.fill,
      );
    }
    canvas.drawPath(
      bubble,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );
  }

  @override
  bool shouldRepaint(covariant _ChatPainter old) =>
      old.color != color ||
      old.filled != filled ||
      old.strokeWidth != strokeWidth;
}
