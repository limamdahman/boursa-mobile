import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/storage/locale_storage.dart';
import '../../../../core/theme/app_font.dart';

class PricingScreen extends ConsumerWidget {
  const PricingScreen({super.key});

  static const _waNumber = '22240000000';

  Future<void> _wa(String planFr) async {
    final uri = Uri.parse(
      'https://wa.me/$_waNumber?text=${Uri.encodeComponent('Bonjour Boursa, je souhaite passer au plan $planFr.')}',
    );
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isAr = ref.watch(localeProvider).languageCode == 'ar';

    final plans = <_Plan>[
      _Plan(
        name: isAr ? 'مجاني' : 'Gratuit',
        price: isAr ? '0 أوقية/شهر' : '0 MRU/mois',
        desc: isAr
            ? 'للبدء واختبار المنصة'
            : 'Pour démarrer et tester la plateforme',
        features: [
          _Feat(isAr ? 'حتى 10 إعلانات' : "Jusqu'à 10 annonces", true),
          _Feat(isAr ? 'صفحة وكالة عامة' : 'Page agence publique', true),
          _Feat(isAr ? 'تواصل واتساب' : 'Contacts WhatsApp', true),
          _Feat(isAr ? 'إحصاءات متقدمة' : 'Statistiques avancées', false),
          _Feat(isAr ? 'إبراز الإعلانات' : 'Mise en avant', false),
          _Feat(isAr ? 'محادثة العملاء' : 'Chat prospects', false),
        ],
        ctaLabel: isAr ? 'ابدأ مجاناً' : 'Commencer gratuitement',
        onCta: (_) => _wa('Gratuit'),
        dark: false,
        popular: false,
      ),
      _Plan(
        name: isAr ? 'احترافي' : 'Pro',
        price: isAr ? 'حسب الطلب' : 'Sur devis',
        desc: isAr
            ? 'للوكالات النشطة التي تريد النمو'
            : 'Pour les agences actives qui veulent croître',
        features: [
          _Feat(isAr ? 'إعلانات غير محدودة' : 'Annonces illimitées', true),
          _Feat(isAr ? 'صفحة وكالة مميزة' : 'Page agence premium', true),
          _Feat(isAr ? 'واتساب + مكالمات' : 'Contacts WhatsApp + appels', true),
          _Feat(isAr ? 'إحصاءات متقدمة' : 'Statistiques avancées', true),
          _Feat(isAr ? 'إبراز أولوية' : 'Mise en avant prioritaire', false),
          _Feat(isAr ? 'محادثة العملاء' : 'Chat prospects', true),
        ],
        ctaLabel: isAr ? 'طلب عرض سعر' : 'Demander un devis',
        onCta: (_) => _wa('Pro'),
        dark: false,
        popular: true,
      ),
      _Plan(
        name: isAr ? 'أعمال' : 'Business',
        price: isAr ? 'حسب الطلب' : 'Sur devis',
        desc: isAr
            ? 'للمجموعات الكبرى والوكلاء الرسميين'
            : 'Pour les grands groupes et concessionnaires',
        features: [
          _Feat(isAr ? 'كل مزايا الاحترافي' : 'Tout le plan Pro', true),
          _Feat(isAr ? 'إبراز أولوية' : 'Mise en avant prioritaire', true),
          _Feat(
              isAr ? 'شارة "شريك رسمي"' : 'Badge "Partenaire officiel"', true),
          _Feat(isAr ? 'مدير حساب مخصص' : 'Account manager dédié', true),
          _Feat(isAr ? 'تكامل API المخزون' : 'Intégration API stock', true),
          _Feat(isAr ? 'تقارير شهرية' : 'Rapports mensuels', true),
          _Feat(isAr ? 'إعلانات Facebook مجانية 🎁' : 'Facebook Ads offerts 🎁',
              true),
        ],
        ctaLabel: isAr ? 'تواصل معنا' : 'Nous contacter',
        onCta: (_) => _wa('Business'),
        dark: true,
        popular: false,
      ),
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(isAr ? 'أسعار الوكالات' : 'Tarifs agences'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        children: [
          Text(
            isAr
                ? 'اختر الباقة المناسبة لنشاطك'
                : 'Choisissez la formule adaptée à votre activité',
            style:
                appFont(context, fontSize: 14, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 20),
          ...plans.map((p) => _PlanCard(plan: p)),
        ],
      ),
    );
  }
}

class _Plan {
  _Plan({
    required this.name,
    required this.price,
    required this.desc,
    required this.features,
    required this.ctaLabel,
    required this.onCta,
    required this.dark,
    required this.popular,
  });
  final String name, price, desc, ctaLabel;
  final List<_Feat> features;
  final void Function(BuildContext) onCta;
  final bool dark, popular;
}

class _Feat {
  _Feat(this.label, this.included);
  final String label;
  final bool included;
}

class _PlanCard extends StatelessWidget {
  const _PlanCard({required this.plan});
  final _Plan plan;

  @override
  Widget build(BuildContext context) {
    final isAr = Localizations.localeOf(context).languageCode == 'ar';
    final dark = plan.dark;
    final textPrimary = dark ? Colors.white : AppColors.textPrimary;
    final textSecondary =
        dark ? const Color(0xFF94A3B8) : AppColors.textSecondary;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: dark ? const Color(0xFF0F172A) : AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: plan.popular ? AppColors.primary : AppColors.border,
          width: plan.popular ? 2 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (plan.popular) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(100),
              ),
              child: Text(
                isAr ? 'الأكثر شعبية' : 'Le plus populaire',
                style: appFont(context,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Colors.white),
              ),
            ),
            const SizedBox(height: 12),
          ],
          Text(
            plan.name.toUpperCase(),
            style: appFont(
              context,
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: dark ? const Color(0xFF64748B) : AppColors.textSecondary,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            plan.price,
            style: appFont(context,
                fontSize: 30, fontWeight: FontWeight.w800, color: textPrimary),
          ),
          const SizedBox(height: 4),
          Text(plan.desc,
              style: appFont(context, fontSize: 13, color: textSecondary)),
          const SizedBox(height: 18),
          Divider(color: dark ? const Color(0xFF1E293B) : AppColors.border),
          const SizedBox(height: 14),
          ...plan.features.map((f) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  children: [
                    Icon(
                      f.included ? Icons.check : Icons.close,
                      size: 18,
                      color: f.included
                          ? AppColors.primary
                          : (dark
                              ? const Color(0xFF475569)
                              : const Color(0xFFCBD5E1)),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        f.label,
                        style: appFont(
                          context,
                          fontSize: 14,
                          color: f.included
                              ? (dark
                                  ? const Color(0xFFE2E8F0)
                                  : const Color(0xFF374151))
                              : (dark
                                  ? const Color(0xFF64748B)
                                  : const Color(0xFF94A3B8)),
                        ),
                      ),
                    ),
                  ],
                ),
              )),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () => plan.onCta(context),
              style: FilledButton.styleFrom(
                backgroundColor: plan.dark || plan.popular
                    ? AppColors.primary
                    : const Color(0xFFF1F5F9),
                foregroundColor: plan.dark || plan.popular
                    ? Colors.white
                    : const Color(0xFF374151),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: Text(plan.ctaLabel,
                  style: const TextStyle(fontWeight: FontWeight.w700)),
            ),
          ),
        ],
      ),
    );
  }
}
