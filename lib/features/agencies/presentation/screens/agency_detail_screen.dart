import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../../../l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/ui/icons/boursa_icons.dart';
import '../../data/models/agency.dart';
import '../providers/agencies_provider.dart';

class AgencyDetailScreen extends ConsumerWidget {
  const AgencyDetailScreen({super.key, required this.slug});
  final String slug;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(agencyDetailProvider(slug));
    return Scaffold(
      backgroundColor: AppColors.background,
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: AppColors.error),
              const SizedBox(height: 12),
              Text('Erreur: $e', textAlign: TextAlign.center),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () => ref.invalidate(agencyDetailProvider(slug)),
                child: Text(AppLocalizations.of(context)!.listingRetry),
              ),
            ],
          ),
        ),
        data: (agency) => _AgencyBody(agency: agency),
      ),
    );
  }
}

class _AgencyBody extends StatelessWidget {
  const _AgencyBody({required this.agency});
  final Agency agency;

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        _AgencyAppBar(agency: agency),
        SliverToBoxAdapter(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _InfoCard(agency: agency),
              if (agency.description != null && agency.description!.isNotEmpty)
                _DescCard(text: agency.description!),
              _StatsRow(agency: agency),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ],
    );
  }
}

class _AgencyAppBar extends StatelessWidget {
  const _AgencyAppBar({required this.agency});
  final Agency agency;

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 180,
      pinned: true,
      backgroundColor: AppColors.surface,
      foregroundColor: AppColors.textPrimary,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => context.canPop() ? context.pop() : context.go('/agences'),
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            // Banner
            agency.bannerUrl != null
                ? CachedNetworkImage(imageUrl: agency.bannerUrl!, fit: BoxFit.cover)
                : Container(color: AppColors.textPrimary),
            // Gradient
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.black54],
                ),
              ),
            ),
            // Logo + name
            Positioned(
              bottom: 16, left: 16, right: 16,
              child: Row(
                children: [
                  Container(
                    width: 56, height: 56,
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.border, width: 2),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: agency.logoUrl != null
                        ? CachedNetworkImage(imageUrl: agency.logoUrl!, fit: BoxFit.cover)
                        : Container(
                            color: AppColors.textPrimary,
                            alignment: Alignment.center,
                            child: Text(
                              agency.initials,
                              style: const TextStyle(
                                color: Colors.white, fontWeight: FontWeight.w800, fontSize: 18,
                              ),
                            ),
                          ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                agency.name,
                                style: const TextStyle(
                                  color: Colors.white, fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                            if (agency.isVerified) ...[
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppColors.primary,
                                  borderRadius: BorderRadius.circular(3),
                                ),
                                child: const Text(
                                  'VÉRIFIÉ',
                                  style: TextStyle(
                                    color: Colors.white, fontSize: 9,
                                    fontWeight: FontWeight.w800, letterSpacing: 0.4,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        if (agency.city != null)
                          Text(
                            agency.city!.name,
                            style: const TextStyle(color: Colors.white70, fontSize: 12),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.agency});
  final Agency agency;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.surface,
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          if (agency.address != null)
            _InfoRow(customIcon: const BoursaPinIcon(size: 16, color: AppColors.textMuted), text: agency.address!),
          if (agency.email != null)
            _InfoRow(icon: Icons.email_outlined, text: agency.email!),
          if (agency.phoneCall != null)
            _InfoRow(icon: Icons.phone_outlined, text: agency.phoneCall!),
          const SizedBox(height: 12),
          Row(
            children: [
              if (agency.phoneWhatsapp != null)
                Expanded(
                  child: _CtaBtn(
                    icon: Icons.chat_bubble_outline,
                    label: AppLocalizations.of(context)!.contactWhatsApp,
                    color: AppColors.whatsapp,
                    onTap: () => _openWhatsApp(agency.phoneWhatsapp!),
                  ),
                ),
              if (agency.phoneWhatsapp != null && agency.phoneCall != null)
                const SizedBox(width: 8),
              if (agency.phoneCall != null)
                Expanded(
                  child: _CtaBtn(
                    icon: Icons.phone,
                    label: AppLocalizations.of(context)!.contactCall,
                    color: AppColors.primary,
                    onTap: () => _call(agency.phoneCall!),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _openWhatsApp(String phone) async {
    final clean = phone.replaceAll(RegExp(r'\D'), '');
    final uri = Uri.parse('https://wa.me/$clean');
    if (await canLaunchUrl(uri)) await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  Future<void> _call(String phone) async {
    final uri = Uri.parse('tel:$phone');
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({this.icon, this.customIcon, required this.text})
      : assert(icon != null || customIcon != null,
            'Fournir soit icon, soit customIcon');
  final IconData? icon;
  final Widget? customIcon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          customIcon ?? Icon(icon, size: 16, color: AppColors.textMuted),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
            ),
          ),
        ],
      ),
    );
  }
}

class _CtaBtn extends StatelessWidget {
  const _CtaBtn({required this.icon, required this.label, required this.color, required this.onTap});
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          height: 44,
          alignment: Alignment.center,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.white, size: 16),
              const SizedBox(width: 6),
              Text(label, style: const TextStyle(
                color: Colors.white, fontSize: 13, fontWeight: FontWeight.w700,
              )),
            ],
          ),
        ),
      ),
    );
  }
}

class _DescCard extends StatelessWidget {
  const _DescCard({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.surface,
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('À propos', style: TextStyle(
            fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textPrimary,
          )),
          const SizedBox(height: 8),
          Text(text, style: const TextStyle(
            fontSize: 13, color: AppColors.textSecondary, height: 1.5,
          )),
        ],
      ),
    );
  }
}

class _StatsRow extends StatelessWidget {
  const _StatsRow({required this.agency});
  final Agency agency;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.surface,
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          _Stat(value: '${agency.vehiclesCount}', label: AppLocalizations.of(context)!.agencyAnnouncements),
          _divider(),
          _Stat(
            value: agency.subscriptionTier.toUpperCase(),
            label: 'Abonnement',
            valueColor: agency.isBusiness ? const Color(0xFFF59E0B) : AppColors.primary,
          ),
          _divider(),
          _Stat(
            value: agency.isVerified ? 'Oui' : 'Non',
            label: 'Vérifiée',
            valueColor: agency.isVerified ? AppColors.primary : AppColors.textMuted,
          ),
        ],
      ),
    );
  }

  Widget _divider() => Container(
    width: 1, height: 36, color: AppColors.border,
    margin: const EdgeInsets.symmetric(horizontal: 16),
  );
}

class _Stat extends StatelessWidget {
  const _Stat({required this.value, required this.label, this.valueColor});
  final String value;
  final String label;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(value, style: TextStyle(
            fontSize: 16, fontWeight: FontWeight.w800,
            color: valueColor ?? AppColors.textPrimary,
          )),
          const SizedBox(height: 2),
          Text(label, style: const TextStyle(
            fontSize: 11, color: AppColors.textMuted,
          )),
        ],
      ),
    );
  }
}
