import 'dart:ui' as ui;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../../../l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/ui/icons/boursa_icons.dart';
import '../../data/models/agency.dart';
import '../providers/agencies_provider.dart';
import '../../../follows/presentation/follow_button.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../chat/presentation/providers/chat_provider.dart';
import '../../../vehicles/presentation/widgets/vehicle_card.dart';
import '../../../vehicles/data/models/vehicle.dart';
import '../../../vehicles/presentation/providers/listing_providers.dart';

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
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
                child: Align(
                  alignment: AlignmentDirectional.centerStart,
                  child:
                      FollowButton(sellerType: 'agency', sellerId: agency.id),
                ),
              ),
              _InfoCard(agency: agency),
              if (agency.description != null && agency.description!.isNotEmpty)
                _DescCard(text: agency.description!),
              if (agency.lat != null && agency.lng != null)
                _AgencyLocationMap(
                  lat: agency.lat!,
                  lng: agency.lng!,
                  name: agency.name,
                  address: agency.address,
                ),
              _StatsRow(agency: agency),
              _AgencyVehicles(agencyId: agency.id),
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
        onPressed: () =>
            context.canPop() ? context.pop() : context.go('/agences'),
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            // Banner
            agency.bannerUrl != null
                ? CachedNetworkImage(
                    imageUrl: agency.bannerUrl!, fit: BoxFit.cover)
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
              bottom: 16,
              left: 16,
              right: 16,
              child: Row(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.border, width: 2),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: agency.logoUrl != null
                        ? CachedNetworkImage(
                            imageUrl: agency.logoUrl!, fit: BoxFit.cover)
                        : Container(
                            color: AppColors.textPrimary,
                            alignment: Alignment.center,
                            child: Text(
                              agency.initials,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                                fontSize: 18,
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
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                            if (agency.isVerified) ...[
                              const SizedBox(width: 6),
                              Icon(Icons.verified,
                                  size: 18,
                                  color: agency.isBusiness
                                      ? const Color(0xFFF59E0B)
                                      : AppColors.primary),
                            ],
                          ],
                        ),
                        if (agency.city != null)
                          Text(
                            agency.city!.name,
                            style: const TextStyle(
                                color: Colors.white70, fontSize: 12),
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

class _InfoCard extends ConsumerWidget {
  const _InfoCard({required this.agency});
  final Agency agency;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final canChat = agency.subscriptionTier == 'pro' ||
        agency.subscriptionTier == 'business';
    return Container(
      color: AppColors.surface,
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          if (agency.address != null)
            _InfoRow(
                customIcon:
                    const BoursaPinIcon(size: 16, color: AppColors.textMuted),
                text: agency.address!),
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
          if (canChat) ...[
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: _CtaBtn(
                icon: Icons.chat_bubble_outline,
                label: AppLocalizations.of(context)!.localeName == 'ar'
                    ? 'مراسلة الوكالة'
                    : "Envoyer un message",
                color: AppColors.primary,
                onTap: () => _openChat(context, ref),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _openChat(BuildContext context, WidgetRef ref) async {
    final isAr = Localizations.localeOf(context).languageCode == 'ar';
    if (!ref.read(isAuthenticatedProvider)) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(isAr
            ? 'سجل دخولك لإرسال رسالة'
            : 'Connectez-vous pour envoyer un message'),
      ));
      return;
    }
    try {
      final repo = ref.read(chatRepositoryProvider);
      final conv = await repo.getOrCreateConversation(agency.id);
      if (context.mounted) {
        context.push('/chat/${conv.id}', extra: agency.name);
      }
    } catch (_) {}
  }

  Future<void> _openWhatsApp(String phone) async {
    final clean = phone.replaceAll(RegExp(r'\D'), '');
    final uri = Uri.parse('https://wa.me/$clean');
    if (await canLaunchUrl(uri))
      await launchUrl(uri, mode: LaunchMode.externalApplication);
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
              style:
                  const TextStyle(fontSize: 13, color: AppColors.textSecondary),
            ),
          ),
        ],
      ),
    );
  }
}

class _CtaBtn extends StatelessWidget {
  const _CtaBtn(
      {required this.icon,
      required this.label,
      required this.color,
      required this.onTap});
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
              Text(label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
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
          const Text('À propos',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              )),
          const SizedBox(height: 8),
          Text(text,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
                height: 1.5,
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
          _Stat(
              value: '${agency.vehiclesCount}',
              label: AppLocalizations.of(context)!.agencyAnnouncements),
          _divider(),
          _Stat(
            value: agency.isBusiness
                ? 'Business'
                : agency.isPro
                    ? 'Pro'
                    : 'Gratuit',
            label: Localizations.localeOf(context).languageCode == 'ar'
                ? 'شريك'
                : 'Partenaire',
            valueColor:
                agency.isBusiness ? const Color(0xFFF59E0B) : AppColors.primary,
          ),
          _divider(),
          _Stat(
            value: agency.isVerified
                ? (Localizations.localeOf(context).languageCode == 'ar'
                    ? 'نعم'
                    : 'Oui')
                : (Localizations.localeOf(context).languageCode == 'ar'
                    ? 'لا'
                    : 'Non'),
            label: Localizations.localeOf(context).languageCode == 'ar'
                ? 'موثقة'
                : 'Vérifiée',
            valueColor:
                agency.isVerified ? AppColors.primary : AppColors.textMuted,
          ),
        ],
      ),
    );
  }

  Widget _divider() => Container(
        width: 1,
        height: 36,
        color: AppColors.border,
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
          Text(value,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: valueColor ?? AppColors.textPrimary,
              )),
          const SizedBox(height: 2),
          Text(label,
              style: const TextStyle(
                fontSize: 11,
                color: AppColors.textMuted,
              )),
        ],
      ),
    );
  }
}

class _AgencyVehicles extends ConsumerStatefulWidget {
  const _AgencyVehicles({required this.agencyId});
  final String agencyId;
  @override
  ConsumerState<_AgencyVehicles> createState() => _AgencyVehiclesState();
}

class _AgencyVehiclesState extends ConsumerState<_AgencyVehicles> {
  String _sort = 'recent';
  String? _bodyType;
  String? _fuel;
  String? _condition;
  int? _yearFrom;
  int? _yearTo;
  bool _showFilters = false;

  int get _activeCount {
    var n = 0;
    if (_bodyType != null) n++;
    if (_fuel != null) n++;
    if (_condition != null) n++;
    if (_yearFrom != null) n++;
    if (_yearTo != null) n++;
    return n;
  }

  void _reset() => setState(() {
        _bodyType = null;
        _fuel = null;
        _condition = null;
        _yearFrom = null;
        _yearTo = null;
        _sort = 'recent';
      });

  List<Vehicle> _apply(List<Vehicle> source) {
    var list = source.where((v) {
      if (_bodyType != null && v.bodyType != _bodyType) return false;
      if (_fuel != null && v.fuel != _fuel) return false;
      if (_condition != null && v.condition != _condition) return false;
      if (_yearFrom != null && v.year < _yearFrom!) return false;
      if (_yearTo != null && v.year > _yearTo!) return false;
      return true;
    }).toList();
    if (_sort == 'price_asc') {
      list.sort((a, b) => a.priceMru.compareTo(b.priceMru));
    } else if (_sort == 'price_desc') {
      list.sort((a, b) => b.priceMru.compareTo(a.priceMru));
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    final isAr = AppLocalizations.of(context)!.localeName == 'ar';
    final async = ref.watch(agencyAllVehiclesProvider(widget.agencyId));
    return async.when(
      loading: () => const Padding(
        padding: EdgeInsets.all(24),
        child:
            Center(child: CircularProgressIndicator(color: AppColors.primary)),
      ),
      error: (_, __) => const SizedBox.shrink(),
      data: (allVehicles) {
        final vehicles = _apply(allVehicles);
        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: Text(
                      isAr ? 'سيارات هذه الوكالة' : 'Véhicules de cette agence',
                      style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary),
                    ),
                  ),
                  Text(
                    '${vehicles.length} ${isAr ? 'إعلان' : 'annonces'}',
                    style: const TextStyle(
                        fontSize: 12, color: AppColors.textSecondary),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Bouton Filtrer
              GestureDetector(
                onTap: () => setState(() => _showFilters = !_showFilters),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                        color: _activeCount > 0
                            ? AppColors.primary
                            : AppColors.border),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.tune,
                          size: 18, color: AppColors.primary),
                      const SizedBox(width: 8),
                      Text(
                        isAr ? 'تصفية' : 'Filtrer',
                        style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary),
                      ),
                      if (_activeCount > 0) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 1),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(100),
                          ),
                          child: Text('$_activeCount',
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700)),
                        ),
                      ],
                      const Spacer(),
                      Icon(
                          _showFilters
                              ? Icons.keyboard_arrow_up
                              : Icons.keyboard_arrow_down,
                          color: AppColors.textSecondary),
                    ],
                  ),
                ),
              ),
              // Panneau de filtres
              if (_showFilters) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _group(isAr ? 'الترتيب' : 'Trier par', [
                        _chip(isAr ? 'الأحدث' : 'Récent', _sort == 'recent',
                            () => setState(() => _sort = 'recent')),
                        _chip(isAr ? 'السعر ↑' : 'Prix ↑', _sort == 'price_asc',
                            () => setState(() => _sort = 'price_asc')),
                        _chip(
                            isAr ? 'السعر ↓' : 'Prix ↓',
                            _sort == 'price_desc',
                            () => setState(() => _sort = 'price_desc')),
                      ]),
                      _group(isAr ? 'الهيكل' : 'Carrosserie', [
                        _chip(isAr ? 'الكل' : 'Tous', _bodyType == null,
                            () => setState(() => _bodyType = null)),
                        for (final e in <String, String>{
                          'sedan': isAr ? 'سيدان' : 'Berline',
                          'suv': 'SUV',
                          'pickup': 'Pickup',
                          'hatchback': isAr ? 'هاتشباك' : 'Compacte',
                          'van': isAr ? 'فان' : 'Van',
                          'coupe': isAr ? 'كوبيه' : 'Coupé',
                        }.entries)
                          _chip(e.value, _bodyType == e.key,
                              () => setState(() => _bodyType = e.key)),
                      ]),
                      _group(isAr ? 'الوقود' : 'Carburant', [
                        _chip(isAr ? 'الكل' : 'Tous', _fuel == null,
                            () => setState(() => _fuel = null)),
                        for (final e in <String, String>{
                          'gasoline': isAr ? 'بنزين' : 'Essence',
                          'diesel': isAr ? 'ديزل' : 'Diesel',
                          'hybrid': isAr ? 'هايبرد' : 'Hybride',
                          'electric': isAr ? 'كهربائي' : 'Électrique',
                          'lpg': isAr ? 'غاز' : 'GPL',
                        }.entries)
                          _chip(e.value, _fuel == e.key,
                              () => setState(() => _fuel = e.key)),
                      ]),
                      _group(isAr ? 'الحالة' : 'État', [
                        _chip(isAr ? 'الكل' : 'Tous', _condition == null,
                            () => setState(() => _condition = null)),
                        for (final e in <String, String>{
                          'used': isAr ? 'مستعمل' : 'Occasion',
                          'new': isAr ? 'جديد' : 'Neuf',
                          'imported': isAr ? 'مستورد' : 'Import',
                        }.entries)
                          _chip(e.value, _condition == e.key,
                              () => setState(() => _condition = e.key)),
                      ]),
                      // Année (de ... à ...)
                      Padding(
                        padding: const EdgeInsets.only(top: 12),
                        child: Text(isAr ? 'السنة' : 'Année',
                            style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary)),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: _yearDropdown(
                              hint: isAr ? 'من' : 'De',
                              value: _yearFrom,
                              onChanged: (v) => setState(() => _yearFrom = v),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _yearDropdown(
                              hint: isAr ? 'إلى' : 'À',
                              value: _yearTo,
                              onChanged: (v) => setState(() => _yearTo = v),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Align(
                        alignment: AlignmentDirectional.centerEnd,
                        child: TextButton(
                          onPressed: _reset,
                          child: Text(isAr ? 'إعادة تعيين' : 'Réinitialiser'),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 14),
              if (vehicles.isEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 48),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    children: [
                      const Icon(Icons.car_crash_outlined,
                          size: 36, color: Color(0xFFCBD5E1)),
                      const SizedBox(height: 12),
                      Text(
                        isAr ? 'لا توجد سيارات' : 'Aucun véhicule',
                        style: const TextStyle(
                            fontSize: 14, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                )
              else
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 0.58,
                  ),
                  itemCount: vehicles.length,
                  itemBuilder: (context, i) => VehicleCard(
                    vehicle: vehicles[i],
                    onTap: () => context.push('/vehicle/${vehicles[i].id}'),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _group(String title, List<Widget> chips) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary)),
          const SizedBox(height: 8),
          Wrap(spacing: 8, runSpacing: 8, children: chips),
          const SizedBox(height: 4),
        ],
      ),
    );
  }

  Widget _yearDropdown({
    required String hint,
    required int? value,
    required ValueChanged<int?> onChanged,
  }) {
    final now = DateTime.now().year;
    return DropdownButtonFormField<int>(
      value: value,
      isExpanded: true,
      decoration: InputDecoration(
        hintText: hint,
        border: const OutlineInputBorder(),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      items: [
        for (var y = now; y >= 1980; y--)
          DropdownMenuItem(value: y, child: Text('$y')),
      ],
      onChanged: onChanged,
    );
  }

  Widget _chip(String label, bool active, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: active ? AppColors.primary : AppColors.background,
          borderRadius: BorderRadius.circular(100),
          border:
              Border.all(color: active ? AppColors.primary : AppColors.border),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: active ? Colors.white : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}

class _AgencyLocationMap extends StatefulWidget {
  const _AgencyLocationMap(
      {required this.lat, required this.lng, required this.name, this.address});
  final double lat;
  final double lng;
  final String name;
  final String? address;

  @override
  State<_AgencyLocationMap> createState() => _AgencyLocationMapState();
}

class _AgencyLocationMapState extends State<_AgencyLocationMap> {
  bool _showPopup = true;
  final MapController _mapController = MapController();

  @override
  Widget build(BuildContext context) {
    final isAr = Localizations.localeOf(context).languageCode == 'ar';
    final title = isAr ? 'الموقع' : 'Localisation';
    final locationLabel = isAr ? 'موقع الوكالة' : "Position de l'agence";
    final directionsLabel = isAr ? 'الاتجاهات' : 'Itinéraire';

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            const Icon(Icons.map_outlined,
                size: 16, color: AppColors.textSecondary),
            const SizedBox(width: 6),
            Text(title,
                style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary)),
          ]),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Container(
              height: 360,
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.border),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Stack(
                children: [
                  FlutterMap(
                    mapController: _mapController,
                    options: MapOptions(
                      initialCenter: LatLng(widget.lat, widget.lng),
                      initialZoom: 16,
                      onMapReady: () {
                        _mapController.move(LatLng(widget.lat, widget.lng), 16);
                      },
                      interactionOptions: const InteractionOptions(
                        flags: InteractiveFlag.pinchZoom | InteractiveFlag.drag,
                      ),
                    ),
                    children: [
                      TileLayer(
                        urlTemplate:
                            'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                        userAgentPackageName: 'com.boursa.mobile',
                      ),
                      MarkerLayer(markers: [
                        Marker(
                          point: LatLng(widget.lat, widget.lng),
                          width: 230,
                          height: 240,
                          alignment: Alignment.bottomCenter,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (_showPopup) _callout(),
                              // Pin (sa pointe est sur la coordonnée)
                              GestureDetector(
                                onTap: () =>
                                    setState(() => _showPopup = !_showPopup),
                                child: SvgPicture.string(
                                  '<svg xmlns="http://www.w3.org/2000/svg" width="34" height="42" viewBox="0 0 34 42"><path d="M17 0C7.6 0 0 7.6 0 17c0 12.5 17 25 17 25s17-12.5 17-25c0-9.4-7.6-17-17-17z" fill="#16A34A" stroke="white" stroke-width="2.5"/><circle cx="17" cy="17" r="6" fill="white"/></svg>',
                                  width: 34,
                                  height: 42,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ]),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _callout() {
    final isAr = Localizations.localeOf(context).languageCode == 'ar';
    final locationLabel = isAr ? 'موقع الوكالة' : "Position de l'agence";
    final directionsLabel = isAr ? 'الاتجاهات' : 'Itinéraire';
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          constraints: const BoxConstraints(maxWidth: 210),
          padding: const EdgeInsets.fromLTRB(10, 8, 8, 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            boxShadow: const [
              BoxShadow(
                  color: Color(0x33000000),
                  blurRadius: 8,
                  offset: Offset(0, 2)),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text('📍 $locationLabel',
                        style: const TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary,
                            letterSpacing: 0.3)),
                  ),
                  GestureDetector(
                    onTap: () => setState(() => _showPopup = false),
                    child: const Icon(Icons.close,
                        size: 15, color: AppColors.textSecondary),
                  ),
                ],
              ),
              const SizedBox(height: 2),
              Text(widget.name,
                  style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary)),
              if (widget.address != null && widget.address!.isNotEmpty) ...[
                const SizedBox(height: 2),
                Text(widget.address!,
                    style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                        height: 1.3)),
              ],
              const SizedBox(height: 8),
              GestureDetector(
                onTap: () async {
                  final uri = Uri.parse(
                      'https://www.google.com/maps/dir/?api=1&destination=${widget.lat},${widget.lng}');
                  if (await canLaunchUrl(uri)) {
                    launchUrl(uri, mode: LaunchMode.externalApplication);
                  }
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 7),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.arrow_forward,
                          color: Colors.white, size: 11),
                      const SizedBox(width: 5),
                      Text(directionsLabel,
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w700)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        CustomPaint(
          size: const Size(18, 9),
          painter: _CalloutArrow(),
        ),
      ],
    );
  }
}

class _CalloutArrow extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white;
    final path = ui.Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width / 2, size.height)
      ..close();
    // Légère ombre
    canvas.drawShadow(path, const Color(0x33000000), 2, false);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
