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
  /// **'Appel'**
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
  /// **'Élec.'**
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

  /// No description provided for @navVehicles.
  ///
  /// In fr, this message translates to:
  /// **'Véhicules'**
  String get navVehicles;

  /// No description provided for @navAgencies.
  ///
  /// In fr, this message translates to:
  /// **'Agences'**
  String get navAgencies;

  /// No description provided for @navChat.
  ///
  /// In fr, this message translates to:
  /// **'Chat'**
  String get navChat;

  /// No description provided for @filterFuel.
  ///
  /// In fr, this message translates to:
  /// **'Carburant'**
  String get filterFuel;

  /// No description provided for @filterTransmission.
  ///
  /// In fr, this message translates to:
  /// **'Transmission'**
  String get filterTransmission;

  /// No description provided for @listingReset.
  ///
  /// In fr, this message translates to:
  /// **'Réinitialiser'**
  String get listingReset;

  /// No description provided for @listingResetFilters.
  ///
  /// In fr, this message translates to:
  /// **'Réinitialiser les filtres'**
  String get listingResetFilters;

  /// No description provided for @vehicleCurrencyUnit.
  ///
  /// In fr, this message translates to:
  /// **'MRU'**
  String get vehicleCurrencyUnit;

  /// No description provided for @heroTitle.
  ///
  /// In fr, this message translates to:
  /// **'Achetez & vendez\nvotre véhicule\nen Mauritanie'**
  String get heroTitle;

  /// No description provided for @heroSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Plus de 850 véhicules vérifiés par nos agences partenaires'**
  String get heroSubtitle;

  /// No description provided for @searchHint.
  ///
  /// In fr, this message translates to:
  /// **'Toyota Camry, moins de 1.5M MRU...'**
  String get searchHint;

  /// No description provided for @statVehicles.
  ///
  /// In fr, this message translates to:
  /// **'véhicules vérifiés'**
  String get statVehicles;

  /// No description provided for @statAgencies.
  ///
  /// In fr, this message translates to:
  /// **'agences partenaires'**
  String get statAgencies;

  /// No description provided for @statCities.
  ///
  /// In fr, this message translates to:
  /// **'villes couvertes'**
  String get statCities;

  /// No description provided for @seeAll.
  ///
  /// In fr, this message translates to:
  /// **'Voir tout →'**
  String get seeAll;

  /// No description provided for @sectionDealsTitle.
  ///
  /// In fr, this message translates to:
  /// **'Les meilleures affaires'**
  String get sectionDealsTitle;

  /// No description provided for @sectionDealsSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'{count} deals du moment'**
  String sectionDealsSubtitle(int count);

  /// No description provided for @sectionRecentTitle.
  ///
  /// In fr, this message translates to:
  /// **'Annonces récentes'**
  String get sectionRecentTitle;

  /// No description provided for @sectionRecentSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Ajoutées récemment'**
  String get sectionRecentSubtitle;

  /// No description provided for @sectionAgenciesTitle.
  ///
  /// In fr, this message translates to:
  /// **'Agences partenaires'**
  String get sectionAgenciesTitle;

  /// No description provided for @sectionAgenciesSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'{count} agences vérifiées'**
  String sectionAgenciesSubtitle(int count);

  /// No description provided for @navMessages.
  ///
  /// In fr, this message translates to:
  /// **'Messages'**
  String get navMessages;

  /// No description provided for @messagesSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Vos conversations'**
  String get messagesSubtitle;

  /// No description provided for @vehicleSellerPrivate.
  ///
  /// In fr, this message translates to:
  /// **'Vendeur particulier'**
  String get vehicleSellerPrivate;

  /// No description provided for @vehicleFuelLabel.
  ///
  /// In fr, this message translates to:
  /// **'Carburant'**
  String get vehicleFuelLabel;

  /// No description provided for @filterSortRecent.
  ///
  /// In fr, this message translates to:
  /// **'Plus récents'**
  String get filterSortRecent;

  /// No description provided for @filterSortPriceAsc.
  ///
  /// In fr, this message translates to:
  /// **'Prix croissant'**
  String get filterSortPriceAsc;

  /// No description provided for @filterSortPriceDesc.
  ///
  /// In fr, this message translates to:
  /// **'Prix décroissant'**
  String get filterSortPriceDesc;

  /// No description provided for @filterSortYearDesc.
  ///
  /// In fr, this message translates to:
  /// **'Année décroissante'**
  String get filterSortYearDesc;

  /// No description provided for @filterSortKmAsc.
  ///
  /// In fr, this message translates to:
  /// **'Km croissant'**
  String get filterSortKmAsc;

  /// No description provided for @filterShowVehicles.
  ///
  /// In fr, this message translates to:
  /// **'Voir les véhicules'**
  String get filterShowVehicles;

  /// No description provided for @filterApply.
  ///
  /// In fr, this message translates to:
  /// **'Appliquer ({count} filtre{plural})'**
  String filterApply(int count, String plural);

  /// No description provided for @filterBrand.
  ///
  /// In fr, this message translates to:
  /// **'Marque'**
  String get filterBrand;

  /// No description provided for @filterAllBrands.
  ///
  /// In fr, this message translates to:
  /// **'Toutes les marques'**
  String get filterAllBrands;

  /// No description provided for @filterModel.
  ///
  /// In fr, this message translates to:
  /// **'Modèle'**
  String get filterModel;

  /// No description provided for @filterAllModels.
  ///
  /// In fr, this message translates to:
  /// **'Tous les modèles'**
  String get filterAllModels;

  /// No description provided for @filterCity.
  ///
  /// In fr, this message translates to:
  /// **'Ville'**
  String get filterCity;

  /// No description provided for @filterAllCities.
  ///
  /// In fr, this message translates to:
  /// **'Toutes les villes'**
  String get filterAllCities;

  /// No description provided for @filterPriceMru.
  ///
  /// In fr, this message translates to:
  /// **'Prix (MRU)'**
  String get filterPriceMru;

  /// No description provided for @filterYearLabel.
  ///
  /// In fr, this message translates to:
  /// **'Année'**
  String get filterYearLabel;

  /// No description provided for @filterSortBy.
  ///
  /// In fr, this message translates to:
  /// **'Trier par'**
  String get filterSortBy;

  /// No description provided for @filterSortRecentHint.
  ///
  /// In fr, this message translates to:
  /// **'Plus récents'**
  String get filterSortRecentHint;

  /// No description provided for @agencyAnnouncements.
  ///
  /// In fr, this message translates to:
  /// **'Annonces'**
  String get agencyAnnouncements;

  /// No description provided for @navAgenciesTitle.
  ///
  /// In fr, this message translates to:
  /// **'Agences'**
  String get navAgenciesTitle;

  /// No description provided for @vehicleYearLabel.
  ///
  /// In fr, this message translates to:
  /// **'Année'**
  String get vehicleYearLabel;

  /// No description provided for @authSignIn.
  ///
  /// In fr, this message translates to:
  /// **'Se connecter'**
  String get authSignIn;

  /// No description provided for @authCreateAccount.
  ///
  /// In fr, this message translates to:
  /// **'Créer un compte'**
  String get authCreateAccount;

  /// No description provided for @authMyAccount.
  ///
  /// In fr, this message translates to:
  /// **'Mon compte'**
  String get authMyAccount;

  /// No description provided for @authConnectToAccess.
  ///
  /// In fr, this message translates to:
  /// **'Connectez-vous pour accéder'**
  String get authConnectToAccess;

  /// No description provided for @authConnectForMessages.
  ///
  /// In fr, this message translates to:
  /// **'Connectez-vous pour accéder\nà vos messages'**
  String get authConnectForMessages;

  /// No description provided for @authConnectForFavorites.
  ///
  /// In fr, this message translates to:
  /// **'Connectez-vous pour voir\nvos favoris'**
  String get authConnectForFavorites;

  /// No description provided for @authConnectForVehicle.
  ///
  /// In fr, this message translates to:
  /// **'Connectez-vous pour sauvegarder ce véhicule'**
  String get authConnectForVehicle;

  /// No description provided for @authPhoneTitle.
  ///
  /// In fr, this message translates to:
  /// **'Entrez votre numéro de téléphone'**
  String get authPhoneTitle;

  /// No description provided for @authPhoneLabel.
  ///
  /// In fr, this message translates to:
  /// **'Téléphone'**
  String get authPhoneLabel;

  /// No description provided for @authReceiveCode.
  ///
  /// In fr, this message translates to:
  /// **'Recevoir le code'**
  String get authReceiveCode;

  /// No description provided for @authContinueWithout.
  ///
  /// In fr, this message translates to:
  /// **'Continuer sans compte'**
  String get authContinueWithout;

  /// No description provided for @favoritesCount.
  ///
  /// In fr, this message translates to:
  /// **'{count} véhicule enregistré'**
  String favoritesCount(int count);

  /// No description provided for @priceRatingVeryGood.
  ///
  /// In fr, this message translates to:
  /// **'Très bon'**
  String get priceRatingVeryGood;

  /// No description provided for @priceRatingGood.
  ///
  /// In fr, this message translates to:
  /// **'Bon'**
  String get priceRatingGood;

  /// No description provided for @priceRatingFair.
  ///
  /// In fr, this message translates to:
  /// **'Juste'**
  String get priceRatingFair;

  /// No description provided for @priceRatingHigh.
  ///
  /// In fr, this message translates to:
  /// **'Élevé'**
  String get priceRatingHigh;

  /// No description provided for @priceRatingVeryHigh.
  ///
  /// In fr, this message translates to:
  /// **'Très élevé'**
  String get priceRatingVeryHigh;

  /// No description provided for @agencyVerified.
  ///
  /// In fr, this message translates to:
  /// **'Agence vérifiée'**
  String get agencyVerified;

  /// No description provided for @agenciesVerifiedCount.
  ///
  /// In fr, this message translates to:
  /// **'{count} agences vérifiées en Mauritanie'**
  String agenciesVerifiedCount(int count);

  /// No description provided for @agencyVehiclesLabel.
  ///
  /// In fr, this message translates to:
  /// **'véhicules'**
  String get agencyVehiclesLabel;

  /// No description provided for @favoritesEmpty.
  ///
  /// In fr, this message translates to:
  /// **'Enregistrez vos véhicules préférés en\ntouchant le cœur sur une annonce.'**
  String get favoritesEmpty;

  /// No description provided for @favoritesBrowse.
  ///
  /// In fr, this message translates to:
  /// **'Parcourir les véhicules'**
  String get favoritesBrowse;

  /// No description provided for @favoritesCountLabel.
  ///
  /// In fr, this message translates to:
  /// **'{count} véhicule enregistré'**
  String favoritesCountLabel(int count);

  /// No description provided for @loginTitle.
  ///
  /// In fr, this message translates to:
  /// **'Connexion'**
  String get loginTitle;

  /// No description provided for @loginSmsHint.
  ///
  /// In fr, this message translates to:
  /// **'Nous vous enverrons un code de vérification par SMS'**
  String get loginSmsHint;

  /// No description provided for @featuredLabel.
  ///
  /// In fr, this message translates to:
  /// **'Vedette'**
  String get featuredLabel;

  /// No description provided for @categoriesTitle.
  ///
  /// In fr, this message translates to:
  /// **'Parcourir par catégorie'**
  String get categoriesTitle;

  /// No description provided for @categoriesViewAll.
  ///
  /// In fr, this message translates to:
  /// **'Tout voir'**
  String get categoriesViewAll;

  /// No description provided for @catSedan.
  ///
  /// In fr, this message translates to:
  /// **'Berlines'**
  String get catSedan;

  /// No description provided for @catSuv.
  ///
  /// In fr, this message translates to:
  /// **'SUV'**
  String get catSuv;

  /// No description provided for @catPickup.
  ///
  /// In fr, this message translates to:
  /// **'Pickup'**
  String get catPickup;

  /// No description provided for @catVan.
  ///
  /// In fr, this message translates to:
  /// **'Utilitaires'**
  String get catVan;

  /// No description provided for @catHatchback.
  ///
  /// In fr, this message translates to:
  /// **'Compactes'**
  String get catHatchback;

  /// No description provided for @catElectric.
  ///
  /// In fr, this message translates to:
  /// **'Hybride / Élec.'**
  String get catElectric;

  /// No description provided for @brandsTitle.
  ///
  /// In fr, this message translates to:
  /// **'Marques populaires'**
  String get brandsTitle;

  /// No description provided for @brandsSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Trouvez votre voiture par marque'**
  String get brandsSubtitle;

  /// No description provided for @brandsViewAll.
  ///
  /// In fr, this message translates to:
  /// **'Voir les marques'**
  String get brandsViewAll;

  /// No description provided for @lifestyleTitle.
  ///
  /// In fr, this message translates to:
  /// **'Pour chaque style de vie'**
  String get lifestyleTitle;

  /// No description provided for @lifestyleSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Sélections curatées pour vous aider à choisir'**
  String get lifestyleSubtitle;

  /// No description provided for @lifestyleFrom.
  ///
  /// In fr, this message translates to:
  /// **'à partir de'**
  String get lifestyleFrom;

  /// No description provided for @lifestyleVehicles.
  ///
  /// In fr, this message translates to:
  /// **'véhicules'**
  String get lifestyleVehicles;

  /// No description provided for @lifeFamilyTitle.
  ///
  /// In fr, this message translates to:
  /// **'Pour la famille'**
  String get lifeFamilyTitle;

  /// No description provided for @lifeFamilyDesc.
  ///
  /// In fr, this message translates to:
  /// **'SUV spacieux, 5+ places, kilométrage modéré'**
  String get lifeFamilyDesc;

  /// No description provided for @lifeFamilyBadge.
  ///
  /// In fr, this message translates to:
  /// **'Famille'**
  String get lifeFamilyBadge;

  /// No description provided for @lifePremiumTitle.
  ///
  /// In fr, this message translates to:
  /// **'Le premium'**
  String get lifePremiumTitle;

  /// No description provided for @lifePremiumDesc.
  ///
  /// In fr, this message translates to:
  /// **'Land Cruiser, Mercedes, Range Rover sélectionnés'**
  String get lifePremiumDesc;

  /// No description provided for @lifePremiumBadge.
  ///
  /// In fr, this message translates to:
  /// **'Premium'**
  String get lifePremiumBadge;

  /// No description provided for @lifeFirstTitle.
  ///
  /// In fr, this message translates to:
  /// **'Premier véhicule'**
  String get lifeFirstTitle;

  /// No description provided for @lifeFirstDesc.
  ///
  /// In fr, this message translates to:
  /// **'Compacte économique pour démarrer en douceur'**
  String get lifeFirstDesc;

  /// No description provided for @lifeFirstBadge.
  ///
  /// In fr, this message translates to:
  /// **'Premier achat'**
  String get lifeFirstBadge;

  /// No description provided for @lifePickupTitle.
  ///
  /// In fr, this message translates to:
  /// **'Pickup pro'**
  String get lifePickupTitle;

  /// No description provided for @lifePickupDesc.
  ///
  /// In fr, this message translates to:
  /// **'4×4 diesel pour travail et désert mauritanien'**
  String get lifePickupDesc;

  /// No description provided for @lifePickupBadge.
  ///
  /// In fr, this message translates to:
  /// **'Tout terrain'**
  String get lifePickupBadge;

  /// No description provided for @agencyCtaTitle.
  ///
  /// In fr, this message translates to:
  /// **'Vous êtes une agence ?'**
  String get agencyCtaTitle;

  /// No description provided for @agencyCtaSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Diffusez votre stock auprès de 12 000+ acheteurs mensuels.'**
  String get agencyCtaSubtitle;

  /// No description provided for @agencyCtaButton.
  ///
  /// In fr, this message translates to:
  /// **'Devenir agence partenaire'**
  String get agencyCtaButton;

  /// No description provided for @agencyStatPartners.
  ///
  /// In fr, this message translates to:
  /// **'Agences partenaires'**
  String get agencyStatPartners;

  /// No description provided for @agencyStatListings.
  ///
  /// In fr, this message translates to:
  /// **'Annonces actives'**
  String get agencyStatListings;

  /// No description provided for @agencyStatVisitors.
  ///
  /// In fr, this message translates to:
  /// **'Visiteurs / mois'**
  String get agencyStatVisitors;

  /// No description provided for @trustVerifiedTitle.
  ///
  /// In fr, this message translates to:
  /// **'Agences vérifiées'**
  String get trustVerifiedTitle;

  /// No description provided for @trustVerifiedDesc.
  ///
  /// In fr, this message translates to:
  /// **'Tous nos partenaires sont validés manuellement'**
  String get trustVerifiedDesc;

  /// No description provided for @trustPricesTitle.
  ///
  /// In fr, this message translates to:
  /// **'Prix transparents'**
  String get trustPricesTitle;

  /// No description provided for @trustPricesDesc.
  ///
  /// In fr, this message translates to:
  /// **'Comparez instantanément au marché'**
  String get trustPricesDesc;

  /// No description provided for @trustContactTitle.
  ///
  /// In fr, this message translates to:
  /// **'Contact direct'**
  String get trustContactTitle;

  /// No description provided for @trustContactDesc.
  ///
  /// In fr, this message translates to:
  /// **'WhatsApp & téléphone, sans intermédiaire'**
  String get trustContactDesc;

  /// No description provided for @trustLocalTitle.
  ///
  /// In fr, this message translates to:
  /// **'100% Mauritanie'**
  String get trustLocalTitle;

  /// No description provided for @trustLocalDesc.
  ///
  /// In fr, this message translates to:
  /// **'De Nouakchott à Zouérat, partout dans le pays'**
  String get trustLocalDesc;

  /// No description provided for @priceNegotiable.
  ///
  /// In fr, this message translates to:
  /// **'Prix négociable'**
  String get priceNegotiable;

  /// No description provided for @vehicleSold.
  ///
  /// In fr, this message translates to:
  /// **'🚗 Ce véhicule a été vendu'**
  String get vehicleSold;

  /// No description provided for @vehicleTransmission.
  ///
  /// In fr, this message translates to:
  /// **'Transmission'**
  String get vehicleTransmission;

  /// No description provided for @vehicleBodyType.
  ///
  /// In fr, this message translates to:
  /// **'Carrosserie'**
  String get vehicleBodyType;

  /// No description provided for @vehicleCityLabel.
  ///
  /// In fr, this message translates to:
  /// **'Ville'**
  String get vehicleCityLabel;

  /// No description provided for @whatsappMessage.
  ///
  /// In fr, this message translates to:
  /// **'Bonjour, je suis intéressé par votre {brand} {model} {year}. Toujours disponible ?'**
  String whatsappMessage(String brand, String model, int year);

  /// No description provided for @announcedBy.
  ///
  /// In fr, this message translates to:
  /// **'Annonce de'**
  String get announcedBy;

  /// No description provided for @verifiedAgencyDot.
  ///
  /// In fr, this message translates to:
  /// **'Agence vérifiée'**
  String get verifiedAgencyDot;

  /// No description provided for @transmissionManualShort.
  ///
  /// In fr, this message translates to:
  /// **'Manuelle'**
  String get transmissionManualShort;

  /// No description provided for @transmissionAutoShort.
  ///
  /// In fr, this message translates to:
  /// **'Auto'**
  String get transmissionAutoShort;

  /// No description provided for @aboutAgency.
  ///
  /// In fr, this message translates to:
  /// **'À propos de l\'agence'**
  String get aboutAgency;

  /// No description provided for @agencyActiveListings.
  ///
  /// In fr, this message translates to:
  /// **'annonces actives'**
  String get agencyActiveListings;

  /// No description provided for @allPhotos.
  ///
  /// In fr, this message translates to:
  /// **'Toutes les photos'**
  String get allPhotos;

  /// No description provided for @similarVehicles.
  ///
  /// In fr, this message translates to:
  /// **'Véhicules similaires'**
  String get similarVehicles;

  /// No description provided for @otherAgencyVehicles.
  ///
  /// In fr, this message translates to:
  /// **'Autres véhicules de cette agence'**
  String get otherAgencyVehicles;

  /// No description provided for @viewAll.
  ///
  /// In fr, this message translates to:
  /// **'Voir tout'**
  String get viewAll;

  /// No description provided for @agencyAddress.
  ///
  /// In fr, this message translates to:
  /// **'Adresse'**
  String get agencyAddress;

  /// No description provided for @agencyEmail.
  ///
  /// In fr, this message translates to:
  /// **'Email'**
  String get agencyEmail;

  /// No description provided for @thumbnailsGallery.
  ///
  /// In fr, this message translates to:
  /// **'Photos'**
  String get thumbnailsGallery;

  /// No description provided for @agencyLocation.
  ///
  /// In fr, this message translates to:
  /// **'Localisation'**
  String get agencyLocation;

  /// No description provided for @otherVehicles.
  ///
  /// In fr, this message translates to:
  /// **'Autres véhicules de l\'agence'**
  String get otherVehicles;

  /// No description provided for @reviewsTitle.
  ///
  /// In fr, this message translates to:
  /// **'Avis sur ce vendeur'**
  String get reviewsTitle;

  /// No description provided for @reviewsNone.
  ///
  /// In fr, this message translates to:
  /// **'Aucun avis pour le moment'**
  String get reviewsNone;

  /// No description provided for @reviewsLeave.
  ///
  /// In fr, this message translates to:
  /// **'Laisser un avis'**
  String get reviewsLeave;

  /// No description provided for @reviewsEdit.
  ///
  /// In fr, this message translates to:
  /// **'Modifier mon avis'**
  String get reviewsEdit;

  /// No description provided for @reviewsRating.
  ///
  /// In fr, this message translates to:
  /// **'Note'**
  String get reviewsRating;

  /// No description provided for @reviewsComment.
  ///
  /// In fr, this message translates to:
  /// **'Commentaire (optionnel)'**
  String get reviewsComment;

  /// No description provided for @reviewsCommentHint.
  ///
  /// In fr, this message translates to:
  /// **'Partagez votre expérience...'**
  String get reviewsCommentHint;

  /// No description provided for @reviewsSubmit.
  ///
  /// In fr, this message translates to:
  /// **'Publier l\'avis'**
  String get reviewsSubmit;

  /// No description provided for @reviewsSubmitting.
  ///
  /// In fr, this message translates to:
  /// **'Publication...'**
  String get reviewsSubmitting;

  /// No description provided for @reviewsSuccess.
  ///
  /// In fr, this message translates to:
  /// **'Avis publié'**
  String get reviewsSuccess;

  /// No description provided for @reviewsError.
  ///
  /// In fr, this message translates to:
  /// **'Erreur lors de la publication'**
  String get reviewsError;

  /// No description provided for @reviewsNoLead.
  ///
  /// In fr, this message translates to:
  /// **'Vous devez contacter le vendeur avant de laisser un avis'**
  String get reviewsNoLead;

  /// No description provided for @reviewsOwnVehicle.
  ///
  /// In fr, this message translates to:
  /// **'Vous ne pouvez pas évaluer votre propre annonce'**
  String get reviewsOwnVehicle;

  /// No description provided for @reviewsLogin.
  ///
  /// In fr, this message translates to:
  /// **'Connectez-vous pour laisser un avis'**
  String get reviewsLogin;

  /// No description provided for @reviewsBasedOn.
  ///
  /// In fr, this message translates to:
  /// **'basée sur'**
  String get reviewsBasedOn;

  /// No description provided for @reviewsCancel.
  ///
  /// In fr, this message translates to:
  /// **'Annuler'**
  String get reviewsCancel;

  /// No description provided for @reviewsCount.
  ///
  /// In fr, this message translates to:
  /// **'{count} avis'**
  String reviewsCount(int count);
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
