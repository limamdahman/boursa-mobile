import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/storage/locale_storage.dart';
import '../../../../core/theme/app_font.dart';

class HelpScreen extends ConsumerWidget {
  const HelpScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isAr = ref.watch(localeProvider).languageCode == 'ar';

    final steps = <(String, String)>[
      isAr
          ? (
              'حدد ميزانيتك',
              'قبل البحث، ضع ميزانية واقعية تشمل سعر الشراء، رسوم نقل الملكية (حوالي 2-3%)، التأمين والإصلاحات المحتملة. استخدم أداة التقدير لدينا لمقارنة أسعار السوق.'
            )
          : (
              'Définissez votre budget',
              "Avant de chercher, fixez un budget réaliste incluant le prix d'achat, les frais de transfert (environ 2-3%), l'assurance et les éventuelles réparations. Utilisez notre outil d'estimation pour comparer les prix du marché."
            ),
      isAr
          ? (
              'اختر النوع المناسب',
              'SUV للطرق الموريتانية الوعرة، سيارة عائلية للمدينة، بيك أب للاحتياجات المهنية. فكر في توافر قطع الغيار محلياً (تويوتا وهيونداي ممثلتان جيداً).'
            )
          : (
              'Choisissez le bon type de véhicule',
              'SUV pour les routes mauritaniennes difficiles, berline pour la ville, pickup pour les besoins professionnels. Pensez à la disponibilité des pièces de rechange localement (Toyota et Hyundai sont très bien représentés).'
            ),
      isAr
          ? (
              'تحقق من الإعلان والبائع',
              'فضّل الوكالات الموثقة في بورصة (الشارة الخضراء). اطلب دائماً رخصة السير، دفتر الصيانة وتاريخ السيارة. احذر من الأسعار المنخفضة بشكل غير طبيعي.'
            )
          : (
              "Vérifiez l'annonce et le vendeur",
              'Préférez les agences vérifiées Boursa (badge vert). Demandez toujours la carte grise, le carnet d\'entretien et l\'historique du véhicule. Méfiez-vous des prix anormalement bas.'
            ),
      isAr
          ? (
              'الفحص قبل الشراء',
              'افحص السيارة دائماً مع ميكانيكي موثوق. تحقق من: الهيكل (صدأ، حوادث)، المحرك (أصوات، دخان)، ناقل الحركة، الفرامل، الإطارات والتكييف.'
            )
          : (
              'Inspection avant achat',
              'Faites toujours inspecter le véhicule par un mécanicien de confiance. Vérifiez : carrosserie (rouille, accidents), moteur (bruits, fumée), boîte de vitesses, freins, pneus et climatisation.'
            ),
      isAr
          ? (
              'أتمم الصفقة بأمان',
              'لا تدفع أبداً دون استلام السيارة. اطلب عقد بيع مكتوب يتضمن بيانات البائع والسعر والتاريخ وتوقيع الطرفين. قم بنقل الملكية فوراً.'
            )
          : (
              'Finalisez la transaction en sécurité',
              'Ne payez jamais sans avoir le véhicule en main. Exigez un contrat de vente écrit avec les informations du vendeur, le prix, la date et la signature des deux parties. Effectuez le transfert de carte grise immédiatement.'
            ),
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: Text(isAr ? 'دليل الشراء' : "Guide d'achat")),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        children: [
          Text(
            isAr
                ? 'كل ما تحتاج معرفته لشراء سيارة في موريتانيا'
                : "Tout ce que vous devez savoir pour acheter une voiture en Mauritanie",
            style:
                appFont(context, fontSize: 14, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 20),
          for (var i = 0; i < steps.length; i++) ...[
            _StepCard(number: i + 1, title: steps[i].$1, body: steps[i].$2),
            const SizedBox(height: 16),
          ],
        ],
      ),
    );
  }
}

class _StepCard extends StatelessWidget {
  const _StepCard(
      {required this.number, required this.title, required this.body});
  final int number;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            color: const Color(0xFF0F172A),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Container(
                  width: 28,
                  height: 28,
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                  child: Text('$number',
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 14)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(title,
                      style: appFont(context,
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w700)),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(body,
                style: appFont(context,
                    fontSize: 14, color: AppColors.textSecondary, height: 1.6)),
          ),
        ],
      ),
    );
  }
}
