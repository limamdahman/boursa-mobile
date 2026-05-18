class BrandRef {
  BrandRef({required this.id, required this.name, this.slug});

  factory BrandRef.fromJson(Map<String, dynamic> json) => BrandRef(
        id: (json['id'] as num).toInt(),
        name: json['name'] as String,
        slug: json['slug'] as String?,
      );

  final int id;
  final String name;
  final String? slug;
}

class VehicleModelRef {
  VehicleModelRef({required this.id, required this.name, required this.brandId});

  factory VehicleModelRef.fromJson(Map<String, dynamic> json) => VehicleModelRef(
        id: (json['id'] as num).toInt(),
        brandId: (json['brand_id'] as num).toInt(),
        name: json['name'] as String,
      );

  final int id;
  final int brandId;
  final String name;
}

class CityRef {
  CityRef({
    required this.id,
    required this.nameFr,
    required this.nameAr,
    this.region,
    this.parentId,
  });

  factory CityRef.fromJson(Map<String, dynamic> json) => CityRef(
        id: (json['id'] as num).toInt(),
        nameFr: json['name_fr'] as String? ?? json['name'] as String? ?? '',
        nameAr: json['name_ar'] as String? ?? '',
        region: json['region'] as String?,
        parentId: (json['parent_id'] as num?)?.toInt(),
      );

  final int id;
  final String nameFr;
  final String nameAr;
  final String? region;
  final int? parentId;

  String displayName(String locale) =>
      locale == 'ar' && nameAr.isNotEmpty ? nameAr : nameFr;
}
