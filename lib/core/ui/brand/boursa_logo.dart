import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';

/// Logo Boursa : silhouette voiture sport (PNG asset) + wordmark "boursa."
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
    final wordmarkColor = dark ? AppColors.textOnDark : AppColors.textPrimary;

    final mark = Image.asset(
      'assets/brand/boursa_mark.png',
      height: markHeight,
      fit: BoxFit.contain,
      filterQuality: FilterQuality.high,
    );

    final wordmark = _BoursaWordmark(size: wordmarkSize, color: wordmarkColor);

    switch (layout) {
      case _Layout.horizontal:
        return Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            mark,
            SizedBox(width: markHeight * 0.35),
            wordmark,
          ],
        );
      case _Layout.markOnly:
        return mark;
      case _Layout.wordmarkOnly:
        return wordmark;
    }
  }
}

enum _Layout { horizontal, markOnly, wordmarkOnly }

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
