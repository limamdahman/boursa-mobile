import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Badge d'abonnement agence, aligné sur le web :
/// - business -> "GOLD ✦" dégradé ambre
/// - pro      -> "PRO" bleu clair
/// - free/null -> rien
class TierBadge extends StatelessWidget {
  const TierBadge({super.key, required this.tier});
  final String? tier;

  @override
  Widget build(BuildContext context) {
    if (tier == null || tier == 'free') return const SizedBox.shrink();
    final isBusiness = tier == 'business';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        gradient: isBusiness
            ? const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFFF59E0B), Color(0xFFD97706)],
              )
            : null,
        color: isBusiness ? null : const Color(0xFFEFF6FF),
        borderRadius: BorderRadius.circular(5),
      ),
      child: Text(
        isBusiness ? 'GOLD ✦' : 'PRO',
        style: GoogleFonts.sourceSans3(
          fontSize: 9,
          fontWeight: FontWeight.w800,
          color: isBusiness ? Colors.white : const Color(0xFF2563EB),
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}
