import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_fr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('fr')
  ];

  /// No description provided for @appTitle.
  ///
  /// In fr, this message translates to:
  /// **'Boursa'**
  String get appTitle;

  /// No description provided for @appTagline.
  ///
  /// In fr, this message translates to:
  /// **'Marketplace véhicules'**
  String get appTagline;

  /// No description provided for @navHome.
  ///
  /// In fr, this message translates to:
  /// **'Accueil'**
  String get navHome;

  /// No description provided for @navFavorites.
  ///
  /// In fr, this message translates to:
  /// **'Favoris'**
  String get navFavorites;

  /// No description provided for @navProfile.
  ///
  /// In fr, this message translates to:
  /// **'Profil'**
  String get navProfile;

  /// No description provided for @listingTitle.
  ///
  /// In fr, this message translates to:
  /// **'Véhicules disponibles'**
  String get listingTitle;

  /// No description provided for @listingEmpty.
  ///
  /// In fr, this message translates to:
  /// **'Aucun véhicule trouvé'**
  String get listingEmpty;

  /// No description provided for @listingLoading.
  ///
  /// In fr, this message translates to:
  /// **'Chargement...'**
  String get listingLoading;

  /// No description provided for @listingError.
  ///
  /// In fr, this message translates to:
  /// **'Erreur de chargement'**
  String get listingError;

  /// No description provided for @listingRetry.
  ///
  /// In fr, this message translates to:
  /// **'Réessayer'**
  String get listingRetry;

  /// No description provided for @listingFilters.
  ///
  /// In fr, this message translates to:
  /// **'Filtres'**
  String get listingFilters;

  /// No description provided for @listingResultsCount.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, =0{Aucun résultat} =1{1 résultat} other{{count} résultats}}'**
  String listingResultsCount(int count);

  /// No description provided for @vehicleYear.
  ///
  /// In fr, this message translates to:
  /// **'Année {year}'**
  String vehicleYear(int year);

  /// No description provided for @vehicleKm.
  ///
  /// In fr, this message translates to:
  /// **'{km} km'**
  String vehicleKm(String km);

  /// No description provided for @vehiclePriceMru.
  ///
  /// In fr, this message translates to:
  /// **'{price} MRU'**
  String vehiclePriceMru(String price);

  /// No description provided for @vehicleSpecsTitle.
  ///
  /// In fr, this message translates to:
  /// **'Caractéristiques'**
  String get vehicleSpecsTitle;

  /// No description provided for @vehicleDescriptionTitle.
  ///
  /// In fr, this message translates to:
  /// **'Description'**
  String get vehicleDescriptionTitle;

  /// No description provided for @vehicleAgencyTitle.
  ///
  /// In fr, this message translates to:
  /// **'Vendeur'**
  String get vehicleAgencyTitle;

  /// No description provided for @vehicleSimilarTitle.
  ///
  /// In fr, this message translates to:
  /// **'Véhicules similaires'**
  String get vehicleSimilarTitle;

  /// No description provided for @contactWhatsApp.
  ///
  /// In fr, this message translates to:
  /// **'WhatsApp'**
  String get contactWhatsApp;

  /// No description provided for @contactCall.
  ///
  /// In fr, this message translates to:
  /// **'Appeler'**
  String get contactCall;

  /// No description provided for @contactMessage.
  ///
  /// In fr, this message translates to:
  /// **'Message'**
  String get contactMessage;

  /// No description provided for @fuelGasoline.
  ///
  /// In fr, this message translates to:
  /// **'Essence'**
  String get fuelGasoline;

  /// No description provided for @fuelDiesel.
  ///
  /// In fr, this message translates to:
  /// **'Diesel'**
  String get fuelDiesel;

  /// No description provided for @fuelHybrid.
  ///
  /// In fr, this message translates to:
  /// **'Hybride'**
  String get fuelHybrid;

  /// No description provided for @fuelElectric.
  ///
  /// In fr, this message translates to:
  /// **'Électrique'**
  String get fuelElectric;

  /// No description provided for @fuelGpl.
  ///
  /// In fr, this message translates to:
  /// **'GPL'**
  String get fuelGpl;

  /// No description provided for @transmissionManual.
  ///
  /// In fr, this message translates to:
  /// **'Manuelle'**
  String get transmissionManual;

  /// No description provided for @transmissionAutomatic.
  ///
  /// In fr, this message translates to:
  /// **'Automatique'**
  String get transmissionAutomatic;

  /// No description provided for @languageLabel.
  ///
  /// In fr, this message translates to:
  /// **'Langue'**
  String get languageLabel;

  /// No description provided for @languageFr.
  ///
  /// In fr, this message translates to:
  /// **'Français'**
  String get languageFr;

  /// No description provided for @languageAr.
  ///
  /// In fr, this message translates to:
  /// **'العربية'**
  String get languageAr;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['ar', 'fr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar': return AppLocalizationsAr();
    case 'fr': return AppLocalizationsFr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
