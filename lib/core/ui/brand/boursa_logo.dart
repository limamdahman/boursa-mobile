import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../theme/app_colors.dart';

/// Logo Boursa — 4 variantes :
/// - `horizontal` : mark PNG + wordmark "boursa." (asset existant)
/// - `mockup`     : rond vert + icône voiture + "Boursa" simple (fidèle au mockup)
/// - `markOnly`   : juste le mark PNG
/// - `wordmarkOnly` : juste le texte "boursa."
class BoursaLogo extends StatelessWidget {
  const BoursaLogo._({
    required this.layout,
    this.markHeight = 22,
    this.wordmarkSize = 22,
    this.dark = false,
  });

  factory BoursaLogo.horizontal({
    double markHeight = 22,
    double wordmarkSize = 22,
    bool dark = false,
  }) =>
      BoursaLogo._(
        layout: _Layout.horizontal,
        markHeight: markHeight,
        wordmarkSize: wordmarkSize,
        dark: dark,
      );

  /// Variante mockup — rond vert + icône voiture blanche + texte simple.
  /// Utilisée dans le header dégradé du listing et la landing.
  factory BoursaLogo.mockup({
    double markSize = 30,
    double wordmarkSize = 22,
    bool dark = true,
  }) =>
      BoursaLogo._(
        layout: _Layout.mockup,
        markHeight: markSize,
        wordmarkSize: wordmarkSize,
        dark: dark,
      );

  factory BoursaLogo.markOnly({double height = 32}) =>
      BoursaLogo._(layout: _Layout.markOnly, markHeight: height);

  factory BoursaLogo.wordmarkOnly({double size = 24, bool dark = false}) =>
      BoursaLogo._(layout: _Layout.wordmarkOnly, wordmarkSize: size, dark: dark);

  final _Layout layout;
  final double markHeight;
  final double wordmarkSize;
  final bool dark;

  @override
  Widget build(BuildContext context) {
    switch (layout) {
      case _Layout.horizontal:
        return _buildHorizontal();
      case _Layout.mockup:
        return _buildMockup();
      case _Layout.markOnly:
        return _buildPngMark();
      case _Layout.wordmarkOnly:
        return _BoursaWordmark(
          size: wordmarkSize,
          color: dark ? AppColors.textOnDark : AppColors.textPrimary,
        );
    }
  }

  Widget _buildPngMark() {
    final img = Image.asset(
      'assets/brand/boursa_mark.png',
      height: markHeight,
      fit: BoxFit.contain,
      filterQuality: FilterQuality.high,
    );
    if (dark) {
      return ColorFiltered(
        colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
        child: img,
      );
    }
    return img;
  }

  Widget _buildHorizontal() {
    final wordmarkColor =
        dark ? AppColors.textOnDark : AppColors.textPrimary;
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _buildPngMark(),
        SizedBox(width: markHeight * 0.35),
        _BoursaWordmark(size: wordmarkSize, color: wordmarkColor),
      ],
    );
  }

  /// Layout mockup-fidèle :
  /// - Rond vert `primary` (30px) avec icône voiture blanche
  /// - Texte "Boursa" w700, blanc 22px (dark) ou textPrimary (light)
  Widget _buildMockup() {
    final textColor =
        dark ? Colors.white : AppColors.textPrimary;
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: markHeight,
          height: markHeight,
          decoration: const BoxDecoration(
            color: AppColors.primary,
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: Icon(
            Icons.directions_car_outlined,
            color: Colors.white,
            size: markHeight * 0.6,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          'Boursa',
          style: GoogleFonts.sourceSans3(
            color: textColor,
            fontSize: wordmarkSize,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.2,
            height: 1.0,
          ),
        ),
      ],
    );
  }
}

enum _Layout { horizontal, mockup, markOnly, wordmarkOnly }

class _BoursaWordmark extends StatelessWidget {
  const _BoursaWordmark({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        style: TextStyle(
          fontSize: size,
          fontWeight: FontWeight.w800,
          height: 1.0,
          letterSpacing: -size * 0.045,
          color: color,
        ),
        children: [
          const TextSpan(text: 'boursa'),
          TextSpan(
            text: '.',
            style: TextStyle(color: AppColors.primary, fontSize: size * 1.1),
          ),
        ],
      ),
    );
  }
}
