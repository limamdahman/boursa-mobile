import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appTitle => 'Boursa';

  @override
  String get appTagline => 'Marketplace véhicules';

  @override
  String get navHome => 'Accueil';

  @override
  String get navFavorites => 'Favoris';

  @override
  String get navProfile => 'Profil';

  @override
  String get listingTitle => 'Véhicules disponibles';

  @override
  String get listingEmpty => 'Aucun véhicule trouvé';

  @override
  String get listingLoading => 'Chargement...';

  @override
  String get listingError => 'Erreur de chargement';

  @override
  String get listingRetry => 'Réessayer';

  @override
  String get listingFilters => 'Filtres';

  @override
  String listingResultsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count résultats',
      one: '1 résultat',
      zero: 'Aucun résultat',
    );
    return '$_temp0';
  }

  @override
  String vehicleYear(int year) {
    return 'Année $year';
  }

  @override
  String vehicleKm(String km) {
    return '$km km';
  }

  @override
  String vehiclePriceMru(String price) {
    return '$price MRU';
  }

  @override
  String get vehicleSpecsTitle => 'Caractéristiques';

  @override
  String get vehicleDescriptionTitle => 'Description';

  @override
  String get vehicleAgencyTitle => 'Vendeur';

  @override
  String get vehicleSimilarTitle => 'Véhicules similaires';

  @override
  String get contactWhatsApp => 'WhatsApp';

  @override
  String get contactCall => 'Appeler';

  @override
  String get contactMessage => 'Message';

  @override
  String get fuelGasoline => 'Essence';

  @override
  String get fuelDiesel => 'Diesel';

  @override
  String get fuelHybrid => 'Hybride';

  @override
  String get fuelElectric => 'Électrique';

  @override
  String get fuelGpl => 'GPL';

  @override
  String get transmissionManual => 'Manuelle';

  @override
  String get transmissionAutomatic => 'Automatique';

  @override
  String get languageLabel => 'Langue';

  @override
  String get languageFr => 'Français';

  @override
  String get languageAr => 'العربية';
}
