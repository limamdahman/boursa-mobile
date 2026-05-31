class AgencyCity {
  final int id;
  final String nameFr;
  final String nameAr;
  const AgencyCity(
      {required this.id, required this.nameFr, required this.nameAr});
  factory AgencyCity.fromJson(Map<String, dynamic> j) => AgencyCity(
        id: j['id'] as int,
        nameFr: j['name_fr'] as String? ?? '',
        nameAr: j['name_ar'] as String? ?? '',
      );
  String get name => nameFr;
}

class Agency {
  final String id;
  final String name;
  final String slug;
  final String? logoUrl;
  final String? bannerUrl;
  final String? address;
  final String? description;
  final String? email;
  final String? website;
  final String? phoneWhatsapp;
  final String? phoneCall;
  final bool isVerified;
  final String subscriptionTier;
  final int vehiclesCount;
  final AgencyCity? city;
  final double? lat;
  final double? lng;

  const Agency({
    required this.id,
    required this.name,
    required this.slug,
    this.logoUrl,
    this.bannerUrl,
    this.address,
    this.description,
    this.email,
    this.website,
    this.phoneWhatsapp,
    this.phoneCall,
    required this.isVerified,
    required this.subscriptionTier,
    required this.vehiclesCount,
    this.city,
    this.lat,
    this.lng,
  });

  factory Agency.fromJson(Map<String, dynamic> j) => Agency(
        id: j['id'] as String,
        name: j['name'] as String,
        slug: j['slug'] as String,
        logoUrl: j['logo_url'] as String?,
        bannerUrl: j['banner_url'] as String?,
        address: j['address'] as String?,
        description: j['description'] as String?,
        email: j['email'] as String?,
        website: j['website'] as String?,
        phoneWhatsapp: j['phone_whatsapp'] as String?,
        phoneCall: j['phone_call'] as String?,
        isVerified: j['is_verified'] as bool? ?? false,
        subscriptionTier: j['subscription_tier'] as String? ?? 'free',
        vehiclesCount: j['vehicles_count'] as int? ?? 0,
        city: j['city'] != null
            ? AgencyCity.fromJson(j['city'] as Map<String, dynamic>)
            : null,
        lat: (j['lat'] as num?)?.toDouble(),
        lng: (j['lng'] as num?)?.toDouble(),
      );

  String get initials => name
      .split(' ')
      .where((s) => s.isNotEmpty)
      .take(2)
      .map((s) => s[0].toUpperCase())
      .join();

  bool get isBusiness => subscriptionTier == 'business';
  bool get isPro => subscriptionTier == 'pro' || isBusiness;
}
