import 'package:flutter/material.dart';
import '../../../../l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isAuth = ref.watch(isAuthenticatedProvider);
    final user = ref.watch(currentUserProvider);

    final name = user?.name ?? AppLocalizations.of(context)!.authMyAccount;
    final phone = user?.phone ?? '';
    final initials = name
        .split(' ')
        .where((s) => s.isNotEmpty)
        .take(2)
        .map((s) => s[0].toUpperCase())
        .join();

    if (!isAuth) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: Column(children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight,
                colors: [Color(0xFF064E3B), Color(0xFF052E22), Color(0xFF0A0A0A)], stops: [0.0, 0.55, 1.0]),
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
            ),
            child: SafeArea(bottom: false, child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 26),
              child: Row(children: [
                Container(width: 52, height: 52,
                  decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withOpacity(0.12)),
                  child: const Icon(Icons.person_outline, color: Colors.white, size: 28)),
                const SizedBox(width: 14),
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(AppLocalizations.of(context)!.authMyAccount, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: Colors.white)),
                  Text(AppLocalizations.of(context)!.authConnectToAccess, style: TextStyle(fontSize: 13, color: Colors.white.withOpacity(0.7))),
                ]),
              ]),
            )),
          ),
          const SizedBox(height: 32),
          Padding(padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(children: [
              SizedBox(width: double.infinity, height: 54,
                child: FilledButton(onPressed: () => context.push('/login'),
                  child: Text(AppLocalizations.of(context)!.authSignIn, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)))),
              const SizedBox(height: 12),
              SizedBox(width: double.infinity, height: 54,
                child: OutlinedButton(onPressed: () => context.push('/login'),
                  child: Text(AppLocalizations.of(context)!.authCreateAccount, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)))),
            ])),
        ]),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header profil avec gradient
            _ProfileHeader(
              initials: initials,
              name: name,
              phone: phone,
            ),

            // CTA Vendre
            if (isAuth)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                child: _SellCta(onTap: () => context.push('/publier')),
              ),

            // Menu
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: _MenuCard(
                isAuth: isAuth,
                onLogout: () =>
                    ref.read(authProvider.notifier).logout(),
              ),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({
    required this.initials,
    required this.name,
    required this.phone,
  });
  final String initials;
  final String name;
  final String phone;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF064E3B), Color(0xFF052E22), Color(0xFF0A0A0A)],
          stops: [0.0, 0.55, 1.0],
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
              color: Color(0x2616A34A),
              blurRadius: 18,
              offset: Offset(0, 8)),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 26),
          child: Row(
            children: [
              // Avatar
              Container(
                width: 62,
                height: 62,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF16A34A), Color(0xFF0f766e)],
                  ),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.25),
                    width: 2.5,
                  ),
                ),
                child: Center(
                  child: Text(
                    initials,
                    style: GoogleFonts.sourceSans3(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 22,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              // Infos
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: GoogleFonts.sourceSans3(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    if (phone.isNotEmpty) ...[
                      const SizedBox(height: 3),
                      Row(
                        children: [
                          Icon(Icons.phone_outlined,
                              size: 14,
                              color: Colors.white.withOpacity(0.75)),
                          const SizedBox(width: 5),
                          Text(
                            phone,
                            style: GoogleFonts.sourceSans3(
                              fontSize: 14,
                              color: Colors.white.withOpacity(0.75),
                            ),
                          ),
                        ],
                      ),
                    ],
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

class _SellCta extends StatelessWidget {
  const _SellCta({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.primary,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.28),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            children: [
              // Icône dans carré translucide
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.add, color: Colors.white, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Vendre un véhicule',
                      style: GoogleFonts.sourceSans3(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 1),
                    Text(
                      'Publiez votre annonce en quelques minutes',
                      style: GoogleFonts.sourceSans3(
                        fontSize: 13,
                        color: Colors.white.withOpacity(0.85),
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Colors.white, size: 22),
            ],
          ),
        ),
      ),
    );
  }
}

class _MenuCard extends StatelessWidget {
  const _MenuCard({required this.isAuth, required this.onLogout});
  final bool isAuth;
  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    final items = [
      _MenuItem(
        icon: Icons.grid_view_outlined,
        label: 'Mes annonces',
        onTap: () => context.push('/mes-annonces'),
      ),
      _MenuItem(
        icon: Icons.people_outline,
        label: 'Mes suivis',
        onTap: () => context.push('/mes-suivis'),
      ),
      _MenuItem(
        icon: Icons.favorite_border,
        label: 'Mes favoris',
        onTap: () => context.go('/favorites'),
      ),
      _MenuItem(
        icon: Icons.settings_outlined,
        label: 'Paramètres',
        onTap: () => context.push('/parametres'),
      ),
      _MenuItem(
        icon: Icons.help_outline,
        label: 'Aide & support',
        onTap: () {},
      ),
    ];

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          ...items.map((item) => _MenuRow(item: item)),
          if (isAuth)
            _MenuRow(
              item: _MenuItem(
                icon: Icons.logout,
                label: 'Déconnexion',
                onTap: onLogout,
                isDanger: true,
              ),
            ),
          if (!isAuth)
            _MenuRow(
              item: _MenuItem(
                icon: Icons.login,
                label: AppLocalizations.of(context)!.authSignIn,
                onTap: () => context.push('/login'),
              ),
            ),
        ],
      ),
    );
  }
}

class _MenuItem {
  const _MenuItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isDanger = false,
  });
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isDanger;
}

class _MenuRow extends StatelessWidget {
  const _MenuRow({required this.item});
  final _MenuItem item;

  @override
  Widget build(BuildContext context) {
    final color = item.isDanger ? const Color(0xFFDC2626) : AppColors.primary;
    final bgColor = item.isDanger
        ? const Color(0x1ADC2626)
        : const Color(0x1F16A34A);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: item.onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
          decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: AppColors.border)),
          ),
          child: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Icon(item.icon, size: 20, color: color),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  item.label,
                  style: GoogleFonts.sourceSans3(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: item.isDanger
                        ? const Color(0xFFDC2626)
                        : AppColors.textPrimary,
                  ),
                ),
              ),
              const Icon(Icons.chevron_right,
                  size: 18, color: AppColors.border),
            ],
          ),
        ),
      ),
    );
  }
}
