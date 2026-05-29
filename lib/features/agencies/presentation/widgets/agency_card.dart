import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_colors.dart';
import '../../data/models/agency.dart';

class AgencyCard extends StatelessWidget {
  const AgencyCard({super.key, required this.agency, required this.onTap});
  final Agency agency;
  final VoidCallback onTap;

  // Couleurs de gradient par index (basé sur le premier char du nom)
  static const _gradients = [
    [Color(0xFF16A34A), Color(0xFF0f766e)],
    [Color(0xFF0ea5e9), Color(0xFF1e40af)],
    [Color(0xFFf59e0b), Color(0xFFb45309)],
    [Color(0xFF8b5cf6), Color(0xFF6d28d9)],
    [Color(0xFFef4444), Color(0xFF991b1b)],
    [Color(0xFF06b6d4), Color(0xFF0e7490)],
  ];

  List<Color> get _avatarGradient {
    final idx = agency.name.isNotEmpty
        ? agency.name.codeUnitAt(0) % _gradients.length
        : 0;
    return _gradients[idx];
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
            boxShadow: const [
              BoxShadow(
                color: Color(0x0F0F172A),
                blurRadius: 12,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              // Avatar rond avec gradient + initiales ou logo
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: _avatarGradient,
                  ),
                ),
                clipBehavior: Clip.antiAlias,
                child: agency.logoUrl != null
                    ? CachedNetworkImage(
                        imageUrl: agency.logoUrl!,
                        fit: BoxFit.cover,
                        errorWidget: (_, __, ___) => _Initials(agency.initials),
                      )
                    : _Initials(agency.initials),
              ),
              const SizedBox(width: 13),
              // Infos
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Nom + badge vérifié
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            agency.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.sourceSans3(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                        if (agency.isVerified) ...[
                          const SizedBox(width: 5),
                          _VerifiedBadge(),
                        ],
                      ],
                    ),
                    // Localisation
                    if (agency.city != null) ...[
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          const Icon(Icons.place_outlined,
                              size: 13, color: AppColors.textSecondary),
                          const SizedBox(width: 3),
                          Flexible(
                            child: Text(
                              agency.city!.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.sourceSans3(
                                fontSize: 13,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                    // Stats
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _Stat(
                          icon: Icons.directions_car_outlined,
                          iconColor: AppColors.textSecondary,
                          value: '${agency.vehiclesCount}',
                          label: 'véhicules',
                        ),
                        const SizedBox(width: 14),
                        _Stat(
                          icon: Icons.star_rounded,
                          iconColor: AppColors.rating,
                          value: '4.8',
                          label: '',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.chevron_right,
                  size: 20, color: AppColors.border),
            ],
          ),
        ),
      ),
    );
  }
}

class _Initials extends StatelessWidget {
  const _Initials(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        text,
        style: GoogleFonts.sourceSans3(
          color: Colors.white,
          fontWeight: FontWeight.w700,
          fontSize: 18,
        ),
      ),
    );
  }
}

class _VerifiedBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 18,
      height: 18,
      decoration: const BoxDecoration(
        color: AppColors.primary,
        shape: BoxShape.circle,
      ),
      child: const Icon(Icons.check, size: 11, color: Colors.white),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({
    required this.icon,
    required this.iconColor,
    required this.value,
    required this.label,
  });
  final IconData icon;
  final Color iconColor;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 13, color: iconColor),
        const SizedBox(width: 3),
        Text(
          value,
          style: GoogleFonts.sourceSans3(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        if (label.isNotEmpty) ...[
          const SizedBox(width: 2),
          Text(
            label,
            style: GoogleFonts.sourceSans3(
                fontSize: 12, color: AppColors.textSecondary),
          ),
        ],
      ],
    );
  }
}
