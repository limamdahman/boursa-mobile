class Brand {
  Brand({required this.id, required this.name, this.slug});

  factory Brand.fromJson(Map<String, dynamic> json) => Brand(
        id: (json['id'] as num).toInt(),
        name: (json["name"] ?? json["name_fr"] ?? json["name_ar"] ?? "") as String,
        slug: json['slug'] as String?,
      );

  final int id;
  final String name;
  final String? slug;
}

class VehicleModel {
  VehicleModel({required this.id, required this.name});

  factory VehicleModel.fromJson(Map<String, dynamic> json) => VehicleModel(
        id: (json['id'] as num).toInt(),
        name: (json["name"] ?? json["name_fr"] ?? json["name_ar"] ?? "") as String,
      );

  final int id;
  final String name;
}

class City {
  City({required this.id, required this.name});

  factory City.fromJson(Map<String, dynamic> json) => City(
        id: (json['id'] as num).toInt(),
        name: (json["name"] ?? json["name_fr"] ?? json["name_ar"] ?? "") as String,
      );

  final int id;
  final String name;
}

class VehicleMedia {
  VehicleMedia({
    required this.id,
    required this.urlOriginal,
    this.urlMd,
    this.urlThumb,
    this.isCover = false,
    this.sortOrder = 0,
  });

  factory VehicleMedia.fromJson(Map<String, dynamic> json) => VehicleMedia(
        id: json['id'] as String,
        urlOriginal: json['url_original'] as String? ?? '',
        urlMd: (json["url_md"] ?? json["url_webp_md"]) as String?,
        urlThumb: json['url_thumb'] as String?,
        isCover: json['is_cover'] as bool? ?? false,
        sortOrder: (json['sort_order'] as num?)?.toInt() ?? 0,
      );

  final String id;
  final String urlOriginal;
  final String? urlMd;
  final String? urlThumb;
  final bool isCover;
  final int sortOrder;

  String get bestUrl => urlMd ?? urlOriginal;
  String get bestThumb => urlThumb ?? urlMd ?? urlOriginal;
}

class AgencyLite {
  AgencyLite({required this.id, required this.name, this.phone});

  factory AgencyLite.fromJson(Map<String, dynamic> json) => AgencyLite(
        id: json['id'] as String,
        name: (json["name"] ?? json["name_fr"] ?? json["name_ar"] ?? "") as String,
        phone: json['phone'] as String?,
      );

  final String id;
  final String name;
  final String? phone;
}

class Vehicle {
  Vehicle({
    required this.id,
    required this.brand,
    required this.model,
    required this.year,
    required this.priceMru,
    required this.mileageKm,
    required this.fuel,
    required this.transmission,
    required this.bodyType,
    required this.condition,
    required this.media,
    this.description,
    this.city,
    this.agency,
    this.specs,
    this.coverImage,
    this.viewsCount = 0,
    this.contactsCount = 0,
    this.priceRating,
    this.priceRatingColor,
    this.priceRatingLabel,
    this.status,
    this.isDeal = false,
    this.originalPrice,
  });

  factory Vehicle.fromJson(Map<String, dynamic> json) => Vehicle(
        id: json['id'] as String,
        brand: Brand.fromJson(json['brand'] as Map<String, dynamic>),
        model: VehicleModel.fromJson(json['model'] as Map<String, dynamic>),
        year: (json['year'] as num).toInt(),
        priceMru: (json['price_mru'] as num).toInt(),
        mileageKm: (json['mileage_km'] as num?)?.toInt() ?? 0,
        fuel: json['fuel'] as String? ?? '',
        transmission: json['transmission'] as String? ?? '',
        bodyType: json['body_type'] as String? ?? '',
        condition: json['condition'] as String? ?? '',
        description: json['description'] as String?,
        city: json['city'] is Map<String, dynamic>
            ? City.fromJson(json['city'] as Map<String, dynamic>)
            : null,
        agency: json['agency'] is Map<String, dynamic>
            ? AgencyLite.fromJson(json['agency'] as Map<String, dynamic>)
            : null,
        coverImage: json['cover_image'] as String?,
        media: (json['media'] as List<dynamic>? ?? [])
            .map((m) => VehicleMedia.fromJson(m as Map<String, dynamic>))
            .toList(),
        specs: json['specs'] is Map<String, dynamic>
            ? Map<String, dynamic>.from(json['specs'] as Map)
            : null,
        viewsCount: (json['views_count'] as num?)?.toInt() ?? 0,
        contactsCount: (json['contacts_count'] as num?)?.toInt() ?? 0,
        priceRating: json['price_rating'] as String?,
        priceRatingColor: json['price_rating_color'] as String?,
        priceRatingLabel: json['price_rating_label'] as String?,
        status: json['status'] as String?,
        isDeal: json['is_deal'] as bool? ?? false,
        originalPrice: (json['original_price'] as num?)?.toInt(),
      );

  final String id;
  final Brand brand;
  final VehicleModel model;
  final int year;
  final int priceMru;
  final int mileageKm;
  final String fuel;
  final String transmission;
  final String bodyType;
  final String condition;
  final String? description;
  final City? city;
  final AgencyLite? agency;
  final List<VehicleMedia> media;
  final Map<String, dynamic>? specs;
  final String? coverImage;
  final int viewsCount;
  final int contactsCount;
  final String? priceRating;
  final String? priceRatingColor;
  final String? priceRatingLabel;
  final String? status;
  final bool isDeal;
  final int? originalPrice;

  String get title => '${brand.name} ${model.name}';
  String? get coverUrl => coverImage ?? (media.isNotEmpty ? media.first.bestUrl : null);
  bool get isSold => status == 'sold';
}

class VehiclePage {
  VehiclePage({
    required this.items,
    required this.currentPage,
    required this.lastPage,
    required this.total,
  });

  factory VehiclePage.fromJson(Map<String, dynamic> json) {
    final data = (json['data'] as List<dynamic>? ?? [])
        .map((e) => Vehicle.fromJson(e as Map<String, dynamic>))
        .toList();

    final meta = json['meta'] is Map<String, dynamic>
        ? json['meta'] as Map<String, dynamic>
        : json;

    return VehiclePage(
      items: data,
      currentPage: (meta['current_page'] as num?)?.toInt() ?? 1,
      lastPage: (meta['last_page'] as num?)?.toInt() ?? 1,
      total: (meta['total'] as num?)?.toInt() ?? data.length,
    );
  }

  final List<Vehicle> items;
  final int currentPage;
  final int lastPage;
  final int total;

  bool get hasMore => currentPage < lastPage;
}
