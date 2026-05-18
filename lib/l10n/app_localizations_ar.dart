import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appTitle => 'بورصة';

  @override
  String get appTagline => 'سوق السيارات';

  @override
  String get navHome => 'الرئيسية';

  @override
  String get navFavorites => 'المفضلة';

  @override
  String get navProfile => 'الملف الشخصي';

  @override
  String get listingTitle => 'السيارات المتاحة';

  @override
  String get listingEmpty => 'لا توجد سيارات';

  @override
  String get listingLoading => 'جاري التحميل...';

  @override
  String get listingError => 'خطأ في التحميل';

  @override
  String get listingRetry => 'إعادة المحاولة';

  @override
  String get listingFilters => 'الفلاتر';

  @override
  String listingResultsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count نتائج',
      one: 'نتيجة واحدة',
      zero: 'لا توجد نتائج',
    );
    return '$_temp0';
  }

  @override
  String vehicleYear(int year) {
    return 'سنة $year';
  }

  @override
  String vehicleKm(String km) {
    return '$km كم';
  }

  @override
  String vehiclePriceMru(String price) {
    return '$price أوقية';
  }

  @override
  String get vehicleSpecsTitle => 'المواصفات';

  @override
  String get vehicleDescriptionTitle => 'الوصف';

  @override
  String get vehicleAgencyTitle => 'البائع';

  @override
  String get vehicleSimilarTitle => 'سيارات مماثلة';

  @override
  String get contactWhatsApp => 'واتساب';

  @override
  String get contactCall => 'اتصال';

  @override
  String get contactMessage => 'رسالة';

  @override
  String get fuelGasoline => 'بنزين';

  @override
  String get fuelDiesel => 'ديزل';

  @override
  String get fuelHybrid => 'هجين';

  @override
  String get fuelElectric => 'كهربائي';

  @override
  String get fuelGpl => 'غاز';

  @override
  String get transmissionManual => 'يدوي';

  @override
  String get transmissionAutomatic => 'أوتوماتيكي';

  @override
  String get languageLabel => 'اللغة';

  @override
  String get languageFr => 'Français';

  @override
  String get languageAr => 'العربية';
}
