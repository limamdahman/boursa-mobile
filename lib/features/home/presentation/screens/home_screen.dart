import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/storage/locale_storage.dart';
import '../../../notifications/presentation/notification_providers.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/ui/brand/boursa_logo.dart';
import '../../../agencies/data/models/agency.dart';
import '../../../agencies/presentation/providers/agencies_provider.dart';
import '../../../vehicles/data/models/vehicle.dart';
import '../../../vehicles/presentation/providers/listing_providers.dart';
import '../../../vehicles/presentation/providers/vehicle_filter.dart';
import '../../../vehicles/presentation/widgets/vehicle_card.dart';
import '../widgets/home_sections.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(dealsProvider);
      ref.read(recentVehiclesProvider);
      ref.read(agenciesProvider.notifier).refresh();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: _HeroHeader()),
          SliverToBoxAdapter(
            child: Consumer(builder: (context, ref, _) {
              final isAr = ref.watch(localeProvider).languageCode == 'ar';
              return Column(children: [
                const SectionCategories(),
                _SectionAgencies(isAr: isAr),
                _SectionDeals(isAr: isAr),
                _SectionRecent(isAr: isAr),
                const SectionBrands(),
                const SectionLifestyle(),
                const SectionAgencyCta(),
                const SectionTrustBar(),
              ]);
            }),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 32)),
        ],
      ),
    );
  }
}

// ─── Hero Header ─────────────────────────────────────────────────────────────

class _HeroHeader extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeProvider);
    final isAr = locale.languageCode == 'ar';

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF064E3B), Color(0xFF052E22), Color(0xFF0A0A0A)],
          stops: [0.0, 0.55, 1.0],
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
        boxShadow: [BoxShadow(color: Color(0x2616A34A), blurRadius: 20, offset: Offset(0, 8))],
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top bar : logo + langue
              Row(
                children: [
                  Expanded(
                    child: BoursaLogo.horizontal(markHeight: 48, wordmarkSize: 32, dark: true),
                  ),
                  // Cloche notifications
                  _NotifBell(),
                  const SizedBox(width: 10),
                  // Switch langue
                  _LangSwitch(isAr: isAr, onToggle: () async {
                    final next = isAr ? const Locale('fr') : const Locale('ar');
                    await ref.read(localeProvider.notifier).setLocale(next);
                  }),
                ],
              ),
              const SizedBox(height: 20),
              // Titre
              Text(
                AppLocalizations.of(context)!.heroTitle,
                style: TextStyle(
                  fontSize: 26, fontWeight: FontWeight.w800,
                  height: 1.2, color: Colors.white, letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                AppLocalizations.of(context)!.heroSubtitle,
                style: TextStyle(fontSize: 13, color: Colors.white.withOpacity(0.7)),
              ),
              const SizedBox(height: 16),
              // Search bar
              _SearchBar(isAr: isAr),
              const SizedBox(height: 16),
              // Stats
              _StatsRow(isAr: isAr),
            ],
          ),
        ),
      ),
    );
  }
}

class _LangSwitch extends StatelessWidget {
  const _LangSwitch({required this.isAr, required this.onToggle});
  final bool isAr;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onToggle,
      child: Container(
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.12),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _LangBtn(label: 'FR', active: !isAr),
            const SizedBox(width: 2),
            _LangBtn(label: 'AR', active: isAr),
          ],
        ),
      ),
    );
  }
}

class _LangBtn extends StatelessWidget {
  const _LangBtn({required this.label, required this.active});
  final String label;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: active ? AppColors.primary : Colors.transparent,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(label, style: TextStyle(
        fontSize: 13, fontWeight: FontWeight.w700,
        color: active ? Colors.white : Colors.white.withOpacity(0.6),
      )),
    );
  }
}

class _SearchBar extends ConsumerWidget {
  const _SearchBar({required this.isAr});
  final bool isAr;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: () => context.go('/vehicules'),
      child: Container(
        height: 50,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          boxShadow: const [BoxShadow(color: Color(0x1A000000), blurRadius: 12, offset: Offset(0, 4))],
        ),
        child: Row(
          children: [
            const Icon(Icons.search, size: 20, color: AppColors.textSecondary),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                AppLocalizations.of(context)!.searchHint,
                style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
              ),
            ),
            Container(
              width: 36, height: 36,
              decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(10)),
              child: const Icon(Icons.tune, size: 18, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatsRow extends StatelessWidget {
  const _StatsRow({required this.isAr});
  final bool isAr;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _Stat(value: '850+', label: AppLocalizations.of(context)!.statVehicles),
        _divider(),
        _Stat(value: '6', label: AppLocalizations.of(context)!.statAgencies),
        _divider(),
        _Stat(value: '23', label: AppLocalizations.of(context)!.statCities),
      ],
    );
  }

  Widget _divider() => Container(
    width: 1, height: 28, color: Colors.white.withOpacity(0.15),
    margin: const EdgeInsets.symmetric(horizontal: 12),
  );
}

class _Stat extends StatelessWidget {
  const _Stat({required this.value, required this.label});
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Directionality(
          textDirection: TextDirection.ltr,
          child: Text(value, style: TextStyle(
            fontSize: 18, fontWeight: FontWeight.w800,
            color: AppColors.primary, letterSpacing: -0.3,
          )),
        ),
        Text(label, style: TextStyle(
          fontSize: 11, color: Colors.white.withOpacity(0.65),
        )),
      ],
    );
  }
}

// ─── Section header ───────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, required this.subtitle, required this.onSeeAll, this.isAr = false});
  final String title;
  final String subtitle;
  final VoidCallback onSeeAll;
  final bool isAr;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(
                  fontSize: 20, fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary, letterSpacing: -0.3)),
                const SizedBox(height: 2),
                Text(subtitle, style: TextStyle(
                  fontSize: 13, color: AppColors.textSecondary)),
              ],
            ),
          ),
          GestureDetector(
            onTap: onSeeAll,
            child: Row(children: [
              Text(AppLocalizations.of(context)!.seeAll, style: TextStyle(
                fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.primary)),
              const SizedBox(width: 2),
              const Icon(Icons.arrow_forward_ios, size: 12, color: AppColors.primary),
            ]),
          ),
        ],
      ),
    );
  }
}

// ─── Section Deals ────────────────────────────────────────────────────────────

class _SectionDeals extends ConsumerWidget {
  const _SectionDeals({required this.isAr});
  final bool isAr;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(dealsProvider);
    return async.when(
      loading: () => const SizedBox(height: 60,
          child: Center(child: CircularProgressIndicator(color: AppColors.primary, strokeWidth: 2))),
      error: (_, __) => const SizedBox.shrink(),
      data: (deals) {
        if (deals.isEmpty) return const SizedBox.shrink();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _DealsHeader(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2, mainAxisSpacing: 12,
                  crossAxisSpacing: 12, childAspectRatio: 0.55,
                ),
                itemCount: deals.length > 6 ? 6 : deals.length,
                itemBuilder: (context, i) => VehicleCard(
                  vehicle: deals[i],
                  onTap: () => context.push('/vehicle/${deals[i].id}'),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

// ─── Section Récents ──────────────────────────────────────────────────────────

class _SectionRecent extends ConsumerWidget {
  const _SectionRecent({required this.isAr});
  final bool isAr;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(recentVehiclesProvider);
    return async.when(
      loading: () => const SizedBox(height: 60,
          child: Center(child: CircularProgressIndicator(color: AppColors.primary, strokeWidth: 2))),
      error: (_, __) => const SizedBox.shrink(),
      data: (vehicles) {
        if (vehicles.isEmpty) return const SizedBox.shrink();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _SectionHeader(
              title: AppLocalizations.of(context)!.sectionRecentTitle,
              subtitle: AppLocalizations.of(context)!.sectionRecentSubtitle,
              onSeeAll: () => context.go('/vehicules', extra: const VehicleFilter(sort: 'recent')),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2, mainAxisSpacing: 12,
                  crossAxisSpacing: 12, childAspectRatio: 0.55,
                ),
                itemCount: vehicles.length > 6 ? 6 : vehicles.length,
                itemBuilder: (context, i) => VehicleCard(
                  vehicle: vehicles[i],
                  onTap: () => context.push('/vehicle/${vehicles[i].id}'),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

// ─── Section Agences ─────────────────────────────────────────────────────────

class _SectionAgencies extends ConsumerWidget {
  const _SectionAgencies({required this.isAr});
  final bool isAr;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(agenciesProvider);
    final agencies = [...state.items]..sort((a, b) {
      const order = {'business': 0, 'pro': 1, 'free': 2};
      return (order[a.subscriptionTier] ?? 2).compareTo(order[b.subscriptionTier] ?? 2);
    });
    final agenciesList = agencies.take(6).toList();
    if (state.isLoading && agenciesList.isEmpty) {
      return const SizedBox(height: 60,
          child: Center(child: CircularProgressIndicator(color: AppColors.primary, strokeWidth: 2)));
    }
    if (agenciesList.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeader(
          title: AppLocalizations.of(context)!.sectionAgenciesTitle,
          subtitle: AppLocalizations.of(context)!.sectionAgenciesSubtitle(agenciesList.length),
          onSeeAll: () => context.go('/agences'),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3, mainAxisSpacing: 12,
              crossAxisSpacing: 12, childAspectRatio: 0.95,
            ),
            itemCount: agencies.length,
            itemBuilder: (context, i) => _AgencyChip(
              agency: agencies[i],
              onTap: () => context.push('/agences/${agencies[i].slug}'),
            ),
          ),
        ),
      ],
    );
  }
}

class _AgencyChip extends StatefulWidget {
  const _AgencyChip({required this.agency, required this.onTap});
  final Agency agency;
  final VoidCallback onTap;
  @override
  State<_AgencyChip> createState() => _AgencyChipState();
}

class _AgencyChipState extends State<_AgencyChip> {
  bool _hovered = false;

  Color get _borderColor {
    if (widget.agency.subscriptionTier == 'business') return const Color(0xFFF59E0B);
    if (_hovered) return AppColors.primary;
    return AppColors.border;
  }

  Widget? get _badge {
    switch (widget.agency.subscriptionTier) {
      case 'business':
        return _TierBadge(label: 'GOLD ✦',
          gradient: const LinearGradient(colors: [Color(0xFFF59E0B), Color(0xFFD97706)]));
      case 'pro':
        return _TierBadge(label: 'PRO',
          bg: const Color(0xFFEFF6FF), textColor: const Color(0xFF2563EB));
      default: return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final badge = _badge;
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          transform: Matrix4.translationValues(0, _hovered ? -3 : 0, 0),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: _borderColor,
              width: widget.agency.subscriptionTier == 'business' ? 2 : 1,
            ),
            boxShadow: [BoxShadow(
              color: _hovered
                ? const Color(0x1A000000)
                : const Color(0x0A0F172A),
              blurRadius: _hovered ? 16 : 8,
              offset: const Offset(0, 3),
            )],
          ),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Center(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(6, 18, 6, 8),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Avatar
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                      width: 48, height: 48,
                      decoration: BoxDecoration(
                        color: const Color(0xFF0F172A),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: widget.agency.logoUrl != null
                        ? Image.network(
                            widget.agency.logoUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Center(
                              child: Text(widget.agency.initials,
                                style: const TextStyle(color: Colors.white,
                                  fontWeight: FontWeight.w800, fontSize: 16))),
                          )
                        : Center(child: Text(widget.agency.initials,
                            style: const TextStyle(color: Colors.white,
                              fontWeight: FontWeight.w800, fontSize: 16))),
                    )),
                    const SizedBox(height: 8),
                    Text(widget.agency.name,
                      maxLines: 2, textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary, height: 1.2)),
                    if (widget.agency.vehiclesCount != null) ...[
                      const SizedBox(height: 2),
                      Builder(builder: (ctx) => Text('${widget.agency.vehiclesCount} ${AppLocalizations.of(ctx)!.agencyVehiclesLabel}',
                        style: const TextStyle(fontSize: 10,
                          color: AppColors.textSecondary))),
                    ],
                  ],
                ),
              )),
              if (badge != null)
                Positioned(
                  top: -8, left: 0, right: 0,
                  child: Center(child: badge),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TierBadge extends StatelessWidget {
  const _TierBadge({required this.label, this.gradient, this.bg, this.textColor});
  final String label;
  final Gradient? gradient;
  final Color? bg;
  final Color? textColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        gradient: gradient,
        color: bg,
        borderRadius: BorderRadius.circular(100),
      ),
      child: Text(label,
        style: TextStyle(
          color: textColor ?? Colors.white,
          fontSize: 10, fontWeight: FontWeight.w800)),
    );
  }
}

class _DealsHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final isAr = Localizations.localeOf(context).languageCode == 'ar';
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            SvgPicture.string(
              '<svg viewBox="0 0 24 24" fill="none" stroke="#EF4444" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><path d="M9.5 2H4a2 2 0 0 0-2 2v5.5L12.5 20a2 2 0 0 0 2.83 0l5.17-5.17a2 2 0 0 0 0-2.83Z"/><circle cx="7" cy="7" r="1.5" fill="#EF4444" stroke="none"/></svg>',
              width: 18, height: 18),
            const SizedBox(width: 6),
            Expanded(child: Text(l.sectionDealsTitle,
              style: const TextStyle(fontSize: 18,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary, letterSpacing: -0.3))),
            GestureDetector(
              onTap: () => context.go('/vehicules', extra: const VehicleFilter(isDeal: true)),
              child: Text(l.seeAll,
                style: const TextStyle(fontSize: 12,
                  fontWeight: FontWeight.w700, color: AppColors.primary))),
          ]),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFEF4444), Color(0xFFDC2626)]),
              borderRadius: BorderRadius.circular(100)),
            child: Text(
              isAr ? 'سيارات بأسعار مخفضة' : 'Véhicules avec prix réduits',
              style: const TextStyle(color: Colors.white,
                fontSize: 10, fontWeight: FontWeight.w700))),
        ],
      ),
    );
  }
}

class _NotifBell extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final count = ref.watch(unreadCountProvider).valueOrNull ?? 0;
    return GestureDetector(
      onTap: () => context.push('/notifications'),
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 40,
        height: 40,
        child: Stack(
          alignment: Alignment.center,
          children: [
            const Icon(Icons.notifications_none, color: Colors.white, size: 26),
            if (count > 0)
              Positioned(
                top: 4,
                right: 4,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                  constraints: const BoxConstraints(minWidth: 16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEF4444),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    count > 9 ? '9+' : '$count',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w700),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
