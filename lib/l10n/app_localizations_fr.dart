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
  String get contactCall => 'Appel';

  @override
  String get contactMessage => 'Message';

  @override
  String get fuelGasoline => 'Essence';

  @override
  String get fuelDiesel => 'Diesel';

  @override
  String get fuelHybrid => 'Hybride';

  @override
  String get fuelElectric => 'Élec.';

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

  @override
  String get navVehicles => 'Véhicules';

  @override
  String get navAgencies => 'Agences';

  @override
  String get navChat => 'Chat';

  @override
  String get filterFuel => 'Carburant';

  @override
  String get filterTransmission => 'Transmission';

  @override
  String get listingReset => 'Réinitialiser';

  @override
  String get listingResetFilters => 'Réinitialiser les filtres';

  @override
  String get vehicleCurrencyUnit => 'MRU';

  @override
  String get heroTitle => 'Achetez & vendez\nvotre véhicule\nen Mauritanie';

  @override
  String get heroSubtitle => 'Plus de 850 véhicules vérifiés par nos agences partenaires';

  @override
  String get searchHint => 'Toyota Camry, moins de 1.5M MRU...';

  @override
  String get statVehicles => 'véhicules vérifiés';

  @override
  String get statAgencies => 'agences partenaires';

  @override
  String get statCities => 'villes couvertes';

  @override
  String get seeAll => 'Voir tout →';

  @override
  String get sectionDealsTitle => 'Les meilleures affaires';

  @override
  String sectionDealsSubtitle(int count) {
    return '$count deals du moment';
  }

  @override
  String get sectionRecentTitle => 'Annonces récentes';

  @override
  String get sectionRecentSubtitle => 'Ajoutées récemment';

  @override
  String get sectionAgenciesTitle => 'Agences partenaires';

  @override
  String sectionAgenciesSubtitle(int count) {
    return '$count agences vérifiées';
  }

  @override
  String get navMessages => 'Messages';

  @override
  String get messagesSubtitle => 'Vos conversations';

  @override
  String get vehicleSellerPrivate => 'Vendeur particulier';

  @override
  String get vehicleFuelLabel => 'Carburant';

  @override
  String get filterSortRecent => 'Plus récents';

  @override
  String get filterSortPriceAsc => 'Prix croissant';

  @override
  String get filterSortPriceDesc => 'Prix décroissant';

  @override
  String get filterSortYearDesc => 'Année décroissante';

  @override
  String get filterSortKmAsc => 'Km croissant';

  @override
  String get filterShowVehicles => 'Voir les véhicules';

  @override
  String filterApply(int count, String plural) {
    return 'Appliquer ($count filtre$plural)';
  }

  @override
  String get filterBrand => 'Marque';

  @override
  String get filterAllBrands => 'Toutes les marques';

  @override
  String get filterModel => 'Modèle';

  @override
  String get filterAllModels => 'Tous les modèles';

  @override
  String get filterCity => 'Ville';

  @override
  String get filterAllCities => 'Toutes les villes';

  @override
  String get filterPriceMru => 'Prix (MRU)';

  @override
  String get filterYearLabel => 'Année';

  @override
  String get filterSortBy => 'Trier par';

  @override
  String get filterSortRecentHint => 'Plus récents';

  @override
  String get agencyAnnouncements => 'Annonces';

  @override
  String get navAgenciesTitle => 'Agences';

  @override
  String get vehicleYearLabel => 'Année';

  @override
  String get authSignIn => 'Se connecter';

  @override
  String get authCreateAccount => 'Créer un compte';

  @override
  String get authMyAccount => 'Mon compte';

  @override
  String get authConnectToAccess => 'Connectez-vous pour accéder';

  @override
  String get authConnectForMessages => 'Connectez-vous pour accéder\nà vos messages';

  @override
  String get authConnectForFavorites => 'Connectez-vous pour voir\nvos favoris';

  @override
  String get authConnectForVehicle => 'Connectez-vous pour sauvegarder ce véhicule';

  @override
  String get authPhoneTitle => 'Entrez votre numéro de téléphone';

  @override
  String get authPhoneLabel => 'Téléphone';

  @override
  String get authReceiveCode => 'Recevoir le code';

  @override
  String get authContinueWithout => 'Continuer sans compte';

  @override
  String favoritesCount(int count) {
    return '$count véhicule enregistré';
  }

  @override
  String get priceRatingVeryGood => 'Très bon';

  @override
  String get priceRatingGood => 'Bon';

  @override
  String get priceRatingFair => 'Juste';

  @override
  String get priceRatingHigh => 'Élevé';

  @override
  String get priceRatingVeryHigh => 'Très élevé';

  @override
  String get agencyVerified => 'Agence vérifiée';

  @override
  String agenciesVerifiedCount(int count) {
    return '$count agences vérifiées en Mauritanie';
  }

  @override
  String get agencyVehiclesLabel => 'véhicules';

  @override
  String get favoritesEmpty => 'Enregistrez vos véhicules préférés en\ntouchant le cœur sur une annonce.';

  @override
  String get favoritesBrowse => 'Parcourir les véhicules';

  @override
  String favoritesCountLabel(int count) {
    return '$count véhicule enregistré';
  }

  @override
  String get loginTitle => 'Connexion';

  @override
  String get loginSmsHint => 'Nous vous enverrons un code de vérification par SMS';

  @override
  String get featuredLabel => 'Vedette';

  @override
  String get categoriesTitle => 'Parcourir par catégorie';

  @override
  String get categoriesViewAll => 'Tout voir';

  @override
  String get catSedan => 'Berlines';

  @override
  String get catSuv => 'SUV';

  @override
  String get catPickup => 'Pickup';

  @override
  String get catVan => 'Utilitaires';

  @override
  String get catHatchback => 'Compactes';

  @override
  String get catElectric => 'Hybride / Élec.';

  @override
  String get brandsTitle => 'Marques populaires';

  @override
  String get brandsSubtitle => 'Trouvez votre voiture par marque';

  @override
  String get brandsViewAll => 'Voir les marques';

  @override
  String get lifestyleTitle => 'Pour chaque style de vie';

  @override
  String get lifestyleSubtitle => 'Sélections curatées pour vous aider à choisir';

  @override
  String get lifestyleFrom => 'à partir de';

  @override
  String get lifestyleVehicles => 'véhicules';

  @override
  String get lifeFamilyTitle => 'Pour la famille';

  @override
  String get lifeFamilyDesc => 'SUV spacieux, 5+ places, kilométrage modéré';

  @override
  String get lifeFamilyBadge => 'Famille';

  @override
  String get lifePremiumTitle => 'Le premium';

  @override
  String get lifePremiumDesc => 'Land Cruiser, Mercedes, Range Rover sélectionnés';

  @override
  String get lifePremiumBadge => 'Premium';

  @override
  String get lifeFirstTitle => 'Premier véhicule';

  @override
  String get lifeFirstDesc => 'Compacte économique pour démarrer en douceur';

  @override
  String get lifeFirstBadge => 'Premier achat';

  @override
  String get lifePickupTitle => 'Pickup pro';

  @override
  String get lifePickupDesc => '4×4 diesel pour travail et désert mauritanien';

  @override
  String get lifePickupBadge => 'Tout terrain';

  @override
  String get agencyCtaTitle => 'Vous êtes une agence ?';

  @override
  String get agencyCtaSubtitle => 'Diffusez votre stock auprès de 12 000+ acheteurs mensuels.';

  @override
  String get agencyCtaButton => 'Devenir agence partenaire';

  @override
  String get agencyStatPartners => 'Agences partenaires';

  @override
  String get agencyStatListings => 'Annonces actives';

  @override
  String get agencyStatVisitors => 'Visiteurs / mois';

  @override
  String get trustVerifiedTitle => 'Agences vérifiées';

  @override
  String get trustVerifiedDesc => 'Tous nos partenaires sont validés manuellement';

  @override
  String get trustPricesTitle => 'Prix transparents';

  @override
  String get trustPricesDesc => 'Comparez instantanément au marché';

  @override
  String get trustContactTitle => 'Contact direct';

  @override
  String get trustContactDesc => 'WhatsApp & téléphone, sans intermédiaire';

  @override
  String get trustLocalTitle => '100% Mauritanie';

  @override
  String get trustLocalDesc => 'De Nouakchott à Zouérat, partout dans le pays';

  @override
  String get priceNegotiable => 'Prix négociable';

  @override
  String get vehicleSold => '🚗 Ce véhicule a été vendu';

  @override
  String get vehicleTransmission => 'Transmission';

  @override
  String get vehicleBodyType => 'Carrosserie';

  @override
  String get vehicleCityLabel => 'Ville';

  @override
  String whatsappMessage(String brand, String model, int year) {
    return 'Bonjour, je suis intéressé par votre $brand $model $year. Toujours disponible ?';
  }

  @override
  String get announcedBy => 'Annonce de';

  @override
  String get verifiedAgencyDot => 'Agence vérifiée';

  @override
  String get transmissionManualShort => 'Manuelle';

  @override
  String get transmissionAutoShort => 'Auto';

  @override
  String get aboutAgency => 'À propos de l\'agence';

  @override
  String get agencyActiveListings => 'annonces actives';

  @override
  String get allPhotos => 'Toutes les photos';

  @override
  String get similarVehicles => 'Véhicules similaires';

  @override
  String get otherAgencyVehicles => 'Autres véhicules de cette agence';

  @override
  String get viewAll => 'Voir tout';

  @override
  String get agencyAddress => 'Adresse';

  @override
  String get agencyEmail => 'Email';

  @override
  String get thumbnailsGallery => 'Photos';

  @override
  String get agencyLocation => 'Localisation';

  @override
  String get otherVehicles => 'Autres véhicules de l\'agence';

  @override
  String get reviewsTitle => 'Avis sur ce vendeur';

  @override
  String get reviewsNone => 'Aucun avis pour le moment';

  @override
  String get reviewsLeave => 'Laisser un avis';

  @override
  String get reviewsEdit => 'Modifier mon avis';

  @override
  String get reviewsRating => 'Note';

  @override
  String get reviewsComment => 'Commentaire (optionnel)';

  @override
  String get reviewsCommentHint => 'Partagez votre expérience...';

  @override
  String get reviewsSubmit => 'Publier l\'avis';

  @override
  String get reviewsSubmitting => 'Publication...';

  @override
  String get reviewsSuccess => 'Avis publié';

  @override
  String get reviewsError => 'Erreur lors de la publication';

  @override
  String get reviewsNoLead => 'Vous devez contacter le vendeur avant de laisser un avis';

  @override
  String get reviewsOwnVehicle => 'Vous ne pouvez pas évaluer votre propre annonce';

  @override
  String get reviewsLogin => 'Connectez-vous pour laisser un avis';

  @override
  String get reviewsBasedOn => 'basée sur';

  @override
  String get reviewsCancel => 'Annuler';

  @override
  String reviewsCount(int count) {
    return '$count avis';
  }

  @override
  String get registerTitle => 'Inscription';

  @override
  String get registerHeading => 'Créer un compte';

  @override
  String get registerSubtitle => 'Entrez vos informations pour recevoir un code de vérification';

  @override
  String get registerNameLabel => 'Nom complet';

  @override
  String get registerNameRequired => 'Veuillez entrer votre nom';

  @override
  String get registerHaveAccount => 'J\'ai déjà un compte';
}
