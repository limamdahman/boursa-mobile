import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/ui/brand/boursa_logo.dart';
import '../../../../core/theme/app_font.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isAr = Localizations.localeOf(context).languageCode == 'ar';
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF064E3B), Color(0xFF052E22), Color(0xFF0A0A0A)],
            stops: [0.0, 0.55, 1.0],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Logo centré
              Padding(
                padding: const EdgeInsets.only(top: 40),
                child: BoursaLogo.mockup(
                    markSize: 32, wordmarkSize: 24, dark: true),
              ),
              // Hero — placeholder rayé + icône voiture
              Expanded(
                child: Stack(alignment: Alignment.center, children: [
                  // Halo radial vert
                  Container(
                    width: 260,
                    height: 260,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(colors: [
                        AppColors.primary.withOpacity(0.22),
                        Colors.transparent,
                      ]),
                    ),
                  ),
                  // Placeholder carte rayée
                  Container(
                    width: 260,
                    height: 180,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0xFF0A3D28), Color(0xFF072A1C)],
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: CustomPaint(
                        painter: _DarkStripePainter(),
                        child: const Center(
                          child: Icon(Icons.directions_car_outlined,
                              size: 72, color: Color(0x4016A34A)),
                        ),
                      ),
                    ),
                  ),
                ]),
              ),
              // Bloc bas
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 36),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Achetez & vendez vos\nvéhicules en Mauritanie',
                      style: appFont(
                        context,
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        height: 1.25,
                        color: Colors.white,
                        letterSpacing: -0.4,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'La première marketplace auto du pays. Des\nmilliers d\'annonces vérifiées, des agences de\nconfiance, en quelques clics.',
                      style: appFont(
                        context,
                        fontSize: 15,
                        height: 1.5,
                        color: Colors.white.withOpacity(0.7),
                      ),
                    ),
                    const SizedBox(height: 28),
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: Material(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(16),
                        child: InkWell(
                          onTap: () => context.go('/'),
                          borderRadius: BorderRadius.circular(16),
                          child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(isAr ? 'ابدأ' : 'Commencer',
                                    style: appFont(context,
                                        fontSize: 17,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.white)),
                                const SizedBox(width: 8),
                                const Icon(Icons.chevron_right,
                                    color: Colors.white, size: 22),
                              ]),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Center(
                      child: Text(
                          isAr
                              ? 'مجاني  •  بدون التزام'
                              : 'Gratuit  •  Sans engagement',
                          style: appFont(context,
                              fontSize: 13,
                              color: Colors.white.withOpacity(0.45))),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DarkStripePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0x1516A34A)
      ..strokeWidth = 12;
    for (double i = -size.height; i < size.width + size.height; i += 24) {
      canvas.drawLine(
          Offset(i, 0), Offset(i + size.height, size.height), paint);
    }
  }

  @override
  bool shouldRepaint(_) => false;
}
