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
  String get fuelElectric => 'كهر.';

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

  @override
  String get navVehicles => 'السيارات';

  @override
  String get navAgencies => 'الوكالات';

  @override
  String get navChat => 'المحادثات';

  @override
  String get filterFuel => 'الوقود';

  @override
  String get filterTransmission => 'ناقل الحركة';

  @override
  String get listingReset => 'إعادة تعيين';

  @override
  String get listingResetFilters => 'إعادة تعيين الفلاتر';

  @override
  String get vehicleCurrencyUnit => 'أوقية';

  @override
  String get heroTitle => 'اشترِ وبع سيارتك\nفي موريتانيا';

  @override
  String get heroSubtitle => 'أكثر من 850 سيارة مدققة من شركاء موثوقين';

  @override
  String get searchHint => 'Toyota كامري، أقل من ١.٥ م...';

  @override
  String get statVehicles => 'سيارة';

  @override
  String get statAgencies => 'وكالة';

  @override
  String get statCities => 'مدينة';

  @override
  String get seeAll => 'عرض الكل →';

  @override
  String get sectionDealsTitle => 'أحسن الصفقات';

  @override
  String sectionDealsSubtitle(int count) {
    return '$count صفقة اليوم';
  }

  @override
  String get sectionRecentTitle => 'آخر الإعلانات';

  @override
  String get sectionRecentSubtitle => 'أضيفت مؤخراً';

  @override
  String get sectionAgenciesTitle => 'الوكالات الشريكة';

  @override
  String sectionAgenciesSubtitle(int count) {
    return '$count وكالة موثقة';
  }

  @override
  String get navMessages => 'الرسائل';

  @override
  String get messagesSubtitle => 'محادثاتك';

  @override
  String get vehicleSellerPrivate => 'بائع خاص';

  @override
  String get vehicleFuelLabel => 'الوقود';

  @override
  String get filterSortRecent => 'الأحدث';

  @override
  String get filterSortPriceAsc => 'السعر تصاعدي';

  @override
  String get filterSortPriceDesc => 'السعر تنازلي';

  @override
  String get filterSortYearDesc => 'السنة تنازلي';

  @override
  String get filterSortKmAsc => 'الكم تصاعدي';

  @override
  String get filterShowVehicles => 'عرض السيارات';

  @override
  String filterApply(int count, String plural) {
    return 'تطبيق ($count فلتر$plural)';
  }

  @override
  String get filterBrand => 'الماركة';

  @override
  String get filterAllBrands => 'كل الماركات';

  @override
  String get filterModel => 'الموديل';

  @override
  String get filterAllModels => 'كل الموديلات';

  @override
  String get filterCity => 'المدينة';

  @override
  String get filterAllCities => 'كل المدن';

  @override
  String get filterPriceMru => 'السعر (أوقية)';

  @override
  String get filterYearLabel => 'السنة';

  @override
  String get filterSortBy => 'ترتيب حسب';

  @override
  String get filterSortRecentHint => 'الأحدث';

  @override
  String get agencyAnnouncements => 'إعلانات';

  @override
  String get navAgenciesTitle => 'الوكالات';

  @override
  String get vehicleYearLabel => 'السنة';

  @override
  String get authSignIn => 'تسجيل الدخول';

  @override
  String get authCreateAccount => 'إنشاء حساب';

  @override
  String get authMyAccount => 'حسابي';

  @override
  String get authConnectToAccess => 'سجل دخولك للوصول';

  @override
  String get authConnectForMessages => 'سجل دخولك للوصول\nإلى رسائلك';

  @override
  String get authConnectForFavorites => 'سجل دخولك لعرض\nمفضلتك';

  @override
  String get authConnectForVehicle => 'سجل دخولك لحفظ هذه السيارة';

  @override
  String get authPhoneTitle => 'أدخل رقم هاتفك';

  @override
  String get authPhoneLabel => 'الهاتف';

  @override
  String get authReceiveCode => 'استلام الرمز';

  @override
  String get authContinueWithout => 'المتابعة بدون حساب';

  @override
  String favoritesCount(int count) {
    return '$count سيارة محفوظة';
  }

  @override
  String get priceRatingVeryGood => 'ممتاز';

  @override
  String get priceRatingGood => 'جيد';

  @override
  String get priceRatingFair => 'عادل';

  @override
  String get priceRatingHigh => 'مرتفع';

  @override
  String get priceRatingVeryHigh => 'مرتفع جداً';

  @override
  String get agencyVerified => 'وكالة موثقة';

  @override
  String agenciesVerifiedCount(int count) {
    return '$count وكالة موثقة في موريتانيا';
  }

  @override
  String get agencyVehiclesLabel => 'سيارات';

  @override
  String get favoritesEmpty => 'احفظ سياراتك المفضلة بالضغط\nعلى القلب في أي إعلان.';

  @override
  String get favoritesBrowse => 'تصفح السيارات';

  @override
  String favoritesCountLabel(int count) {
    return '$count سيارة محفوظة';
  }

  @override
  String get loginTitle => 'تسجيل الدخول';

  @override
  String get loginSmsHint => 'سنرسل لك رمز التحقق عبر SMS';

  @override
  String get featuredLabel => 'مميز';

  @override
  String get categoriesTitle => 'تصفح حسب الفئة';

  @override
  String get categoriesViewAll => 'عرض الكل';

  @override
  String get catSedan => 'سيدان';

  @override
  String get catSuv => 'سيارات الدفع الرباعي';

  @override
  String get catPickup => 'بيك أب';

  @override
  String get catVan => 'مركبات تجارية';

  @override
  String get catHatchback => 'مدمجة';

  @override
  String get catElectric => 'هجينة / كهربائية';

  @override
  String get brandsTitle => 'أشهر الماركات';

  @override
  String get brandsSubtitle => 'تصفح سياراتنا حسب الماركة';

  @override
  String get brandsViewAll => 'عرض الماركات';

  @override
  String get lifestyleTitle => 'اختر ما يناسبك';

  @override
  String get lifestyleSubtitle => 'فئات منتقاة خصيصاً لك';

  @override
  String get lifestyleFrom => 'ابتداء من';

  @override
  String get lifestyleVehicles => 'سيارة';

  @override
  String get lifeFamilyTitle => 'سيارات عائلية';

  @override
  String get lifeFamilyDesc => 'دفع رباعي رحب لكل أفراد العائلة';

  @override
  String get lifeFamilyBadge => 'عائلي';

  @override
  String get lifePremiumTitle => 'سيارات فاخرة';

  @override
  String get lifePremiumDesc => 'لاند كروزر، مرسيدس، رينج روفر مختارة';

  @override
  String get lifePremiumBadge => 'فاخر';

  @override
  String get lifeFirstTitle => 'سيارتك الأولى';

  @override
  String get lifeFirstDesc => 'سيارة مدمجة بسعر مناسب لبدايتك';

  @override
  String get lifeFirstBadge => 'أول شراء';

  @override
  String get lifePickupTitle => 'بيك أب للعمل';

  @override
  String get lifePickupDesc => 'بيك أب 4x4 ديزل للعمل والصحراء';

  @override
  String get lifePickupBadge => 'كل التضاريس';

  @override
  String get agencyCtaTitle => 'هل أنت وكالة؟';

  @override
  String get agencyCtaSubtitle => 'انشر مخزونك لأكثر من 12 ألف مشتري شهرياً.';

  @override
  String get agencyCtaButton => 'كن وكالة شريكة';

  @override
  String get agencyStatPartners => 'وكالة شريكة';

  @override
  String get agencyStatListings => 'إعلان نشط';

  @override
  String get agencyStatVisitors => 'زائر شهرياً';

  @override
  String get trustVerifiedTitle => 'وكالات معتمدة';

  @override
  String get trustVerifiedDesc => 'جميع شركائنا تم التحقق منهم يدوياً';

  @override
  String get trustPricesTitle => 'أسعار شفافة';

  @override
  String get trustPricesDesc => 'قارن فوراً مع السوق';

  @override
  String get trustContactTitle => 'تواصل مباشر';

  @override
  String get trustContactDesc => 'واتساب وهاتف، بدون وسيط';

  @override
  String get trustLocalTitle => '100% موريتانيا';

  @override
  String get trustLocalDesc => 'من نواكشوط إلى ازويرات، في كل أنحاء البلاد';

  @override
  String get priceNegotiable => 'قابل للتفاوض';

  @override
  String get vehicleSold => '🚗 هذه السيارة تم بيعها';

  @override
  String get vehicleTransmission => 'ناقل الحركة';

  @override
  String get vehicleBodyType => 'نوع الهيكل';

  @override
  String get vehicleCityLabel => 'المدينة';

  @override
  String whatsappMessage(String brand, String model, int year) {
    return 'مرحباً، أنا مهتم بسيارتك $brand $model $year. هل لا تزال متوفرة؟';
  }

  @override
  String get announcedBy => 'إعلان من';

  @override
  String get verifiedAgencyDot => 'وكالة موثقة';

  @override
  String get transmissionManualShort => 'يدوي';

  @override
  String get transmissionAutoShort => 'أوتو';

  @override
  String get aboutAgency => 'عن الوكالة';

  @override
  String get agencyActiveListings => 'إعلان نشط';

  @override
  String get allPhotos => 'جميع الصور';

  @override
  String get similarVehicles => 'سيارات مشابهة';

  @override
  String get otherAgencyVehicles => 'سيارات أخرى من نفس الوكالة';

  @override
  String get viewAll => 'عرض الكل';

  @override
  String get agencyAddress => 'العنوان';

  @override
  String get agencyEmail => 'البريد';

  @override
  String get thumbnailsGallery => 'الصور';

  @override
  String get agencyLocation => 'الموقع';

  @override
  String get otherVehicles => 'سيارات من نفس الوكالة';

  @override
  String get reviewsTitle => 'تقييمات هذا البائع';

  @override
  String get reviewsNone => 'لا توجد تقييمات حاليا';

  @override
  String get reviewsLeave => 'اترك تقييما';

  @override
  String get reviewsEdit => 'تعديل تقييمي';

  @override
  String get reviewsRating => 'التقييم';

  @override
  String get reviewsComment => 'تعليق (اختياري)';

  @override
  String get reviewsCommentHint => 'شارك تجربتك...';

  @override
  String get reviewsSubmit => 'نشر التقييم';

  @override
  String get reviewsSubmitting => 'جاري النشر...';

  @override
  String get reviewsSuccess => 'تم نشر التقييم';

  @override
  String get reviewsError => 'خطأ أثناء النشر';

  @override
  String get reviewsNoLead => 'يجب الاتصال بالبائع قبل ترك تقييم';

  @override
  String get reviewsOwnVehicle => 'لا يمكنك تقييم إعلانك الخاص';

  @override
  String get reviewsLogin => 'سجل دخولك لترك تقييم';

  @override
  String get reviewsBasedOn => 'بناء على';

  @override
  String get reviewsCancel => 'إلغاء';

  @override
  String reviewsCount(int count) {
    return '$count تقييم';
  }

  @override
  String get registerTitle => 'التسجيل';

  @override
  String get registerHeading => 'إنشاء حساب';

  @override
  String get registerSubtitle => 'أدخل معلوماتك لتلقي رمز التحقق';

  @override
  String get registerNameLabel => 'الاسم الكامل';

  @override
  String get registerNameRequired => 'الرجاء إدخال اسمك';

  @override
  String get registerHaveAccount => 'لدي حساب بالفعل';
}
