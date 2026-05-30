class VehicleFilter {
  const VehicleFilter({
    this.brandId,
    this.modelId,
    this.cityId,
    this.priceMin,
    this.priceMax,
    this.yearMin,
    this.yearMax,
    this.fuel,
    this.transmission,
    this.sort,
    this.bodyType,
    this.isDeal,
  });

  final int? brandId;
  final int? modelId;
  final int? cityId;
  final int? priceMin;
  final int? priceMax;
  final int? yearMin;
  final int? yearMax;
  final String? fuel;
  final String? transmission;
  final String? sort;
  final String? bodyType;
  final bool? isDeal;

  VehicleFilter copyWith({
    int? brandId,
    int? modelId,
    int? cityId,
    int? priceMin,
    int? priceMax,
    int? yearMin,
    int? yearMax,
    String? fuel,
    String? transmission,
    String? sort,
    String? bodyType,
    bool? isDeal,
    bool clearBrand = false,
    bool clearModel = false,
    bool clearCity = false,
    bool clearFuel = false,
    bool clearTransmission = false,
    bool clearIsDeal = false,
  }) =>
      VehicleFilter(
        brandId: clearBrand ? null : (brandId ?? this.brandId),
        modelId: clearModel ? null : (modelId ?? this.modelId),
        cityId: clearCity ? null : (cityId ?? this.cityId),
        priceMin: priceMin ?? this.priceMin,
        priceMax: priceMax ?? this.priceMax,
        yearMin: yearMin ?? this.yearMin,
        yearMax: yearMax ?? this.yearMax,
        fuel: clearFuel ? null : (fuel ?? this.fuel),
        transmission:
            clearTransmission ? null : (transmission ?? this.transmission),
        sort: sort ?? this.sort,
        bodyType: bodyType ?? this.bodyType,
        isDeal: clearIsDeal ? null : (isDeal ?? this.isDeal),
      );

  bool get isEmpty =>
      brandId == null &&
      modelId == null &&
      cityId == null &&
      priceMin == null &&
      priceMax == null &&
      yearMin == null &&
      yearMax == null &&
      fuel == null &&
      transmission == null &&
      (sort == null || sort == 'recent') &&
      bodyType == null &&
      isDeal == null;

  int get activeCount {
    int n = 0;
    if (brandId != null) n++;
    if (modelId != null) n++;
    if (cityId != null) n++;
    if (priceMin != null || priceMax != null) n++;
    if (yearMin != null || yearMax != null) n++;
    if (fuel != null) n++;
    if (transmission != null) n++;
    if (bodyType != null) n++;
    return n;
  }
}
