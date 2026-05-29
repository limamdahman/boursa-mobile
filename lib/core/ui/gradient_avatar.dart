import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Avatar rond avec dégradé 135° + initiales en blanc.
///
/// Reproduit `linear-gradient(135deg, #c1, #c2)` du mockup HTML.
class GradientAvatar extends StatelessWidget {
  const GradientAvatar({
    super.key,
    required this.name,
    required this.colors,
    this.size = 52,
    this.fontSize = 18,
    this.border,
  });

  final String name;
  final List<Color> colors;
  final double size;
  final double fontSize;
  final BoxBorder? border;

  /// Génère 2 initiales à partir du nom : "Sahara Auto" → "SA".
  static String initialsOf(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    final letters = parts
        .take(2)
        .map((w) => w.isEmpty ? '' : w[0].toUpperCase())
        .join();
    return letters.isEmpty ? '?' : letters;
  }

  /// Palette stable basée sur le hash du nom (mêmes couleurs à chaque rendu).
  static List<Color> paletteFor(String seed) {
    const palettes = <List<Color>>[
      [Color(0xFF16A34A), Color(0xFF0F766E)],
      [Color(0xFF0EA5E9), Color(0xFF1E40AF)],
      [Color(0xFFF59E0B), Color(0xFFB45309)],
      [Color(0xFF8B5CF6), Color(0xFF6D28D9)],
      [Color(0xFFEF4444), Color(0xFF991B1B)],
      [Color(0xFFEC4899), Color(0xFFBE185D)],
      [Color(0xFF14B8A6), Color(0xFF0F766E)],
    ];
    final h = seed.codeUnits.fold<int>(0, (a, c) => (a + c) % 1000);
    return palettes[h % palettes.length];
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: colors,
        ),
        border: border,
      ),
      alignment: Alignment.center,
      child: Text(
        initialsOf(name),
        style: GoogleFonts.sourceSans3(
          color: Colors.white,
          fontSize: fontSize,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
