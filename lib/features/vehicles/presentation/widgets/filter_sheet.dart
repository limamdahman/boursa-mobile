import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../l10n/app_localizations.dart';
import '../../data/repositories/reference_repository.dart';
import '../providers/vehicle_filter.dart';

class FilterSheet extends ConsumerStatefulWidget {
  const FilterSheet({super.key, required this.initial});

  final VehicleFilter initial;

  @override
  ConsumerState<FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends ConsumerState<FilterSheet> {
  late VehicleFilter _draft;
  RangeValues _priceRange = const RangeValues(0, 10000000);
  RangeValues _yearRange = const RangeValues(2000, 2026);

  List<(String, String)> _fuelOptions(AppLocalizations l) => [
        ('gasoline', l.fuelGasoline),
        ('diesel', l.fuelDiesel),
        ('hybrid', l.fuelHybrid),
        ('electric', l.fuelElectric),
        ('gpl', l.fuelGpl),
      ];
  List<(String, String)> _transOptions(AppLocalizations l) => [
        ('manual', l.transmissionManual),
        ('automatic', l.transmissionAutomatic),
      ];
  List<(String, String)> _sortOptions(AppLocalizations l) => [
        ('recent', l.filterSortRecent),
        ('price_asc', l.filterSortPriceAsc),
        ('price_desc', l.filterSortPriceDesc),
        ('year_desc', l.filterSortYearDesc),
        ('mileage_asc', l.filterSortKmAsc),
      ];

  @override
  void initState() {
    super.initState();
    _draft = widget.initial;
    if (_draft.priceMin != null || _draft.priceMax != null) {
      _priceRange = RangeValues(
        (_draft.priceMin ?? 0).toDouble(),
        (_draft.priceMax ?? 10000000).toDouble(),
      );
    }
    if (_draft.yearMin != null || _draft.yearMax != null) {
      _yearRange = RangeValues(
        (_draft.yearMin ?? 2000).toDouble(),
        (_draft.yearMax ?? 2026).toDouble(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.85,
      minChildSize: 0.6,
      maxChildSize: 0.95,
      builder: (context, scrollController) => Container(
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: Column(
          children: [
            // Drag handle
            Container(
              margin: const EdgeInsets.only(top: 8, bottom: 4),
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.borderStrong,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 8, 12),
              child: Row(
                children: [
                  Text(
                    AppLocalizations.of(context)!.listingFilters,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: _reset,
                    child: Text(AppLocalizations.of(context)!.listingReset),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 22),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            // Content
            Expanded(
              child: ListView(
                controller: scrollController,
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                children: [
                  _buildBrand(),
                  if (_draft.brandId != null) ...[
                    const SizedBox(height: 18),
                    _buildModel(),
                  ],
                  const SizedBox(height: 18),
                  _buildCity(),
                  const SizedBox(height: 18),
                  _buildPriceRange(),
                  const SizedBox(height: 18),
                  _buildYearRange(),
                  const SizedBox(height: 18),
                  _buildFuelChips(),
                  const SizedBox(height: 18),
                  _buildTransmissionChips(),
                  const SizedBox(height: 18),
                  _buildSort(),
                  const SizedBox(height: 28),
                ],
              ),
            ),
            // Sticky CTA
            Container(
              padding: EdgeInsets.fromLTRB(
                16,
                10,
                16,
                14 + MediaQuery.of(context).padding.bottom,
              ),
              decoration: const BoxDecoration(
                color: AppColors.surface,
                border: Border(top: BorderSide(color: AppColors.border)),
              ),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _apply,
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(46),
                  ),
                  child: Text(
                    _draft.activeCount == 0
                        ? 'Voir les véhicules'
                        : 'Appliquer (${_draft.activeCount} filtre${_draft.activeCount > 1 ? "s" : ""})',
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _label(String s) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(
          s.toUpperCase(),
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.5,
            color: AppColors.textPrimary,
          ),
        ),
      );

  Widget _buildBrand() {
    final brands = ref.watch(brandsListProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label(AppLocalizations.of(context)!.filterBrand),
        brands.when(
          loading: () => const SizedBox(
            height: 40,
            child: Center(
                child: SizedBox(
              width: 14,
              height: 14,
              child: CircularProgressIndicator(strokeWidth: 2),
            )),
          ),
          error: (e, _) => Text('Erreur: $e',
              style: const TextStyle(color: AppColors.error)),
          data: (list) => _Select<int?>(
            value: _draft.brandId,
            hint: AppLocalizations.of(context)!.filterAllBrands,
            items: [
              _Opt<int?>(null, AppLocalizations.of(context)!.filterAllBrands),
              ...list.map((b) => _Opt<int?>(b.id, b.name)),
            ],
            onChanged: (v) => setState(() {
              _draft = v == null
                  ? _draft.copyWith(clearBrand: true, clearModel: true)
                  : _draft.copyWith(brandId: v, clearModel: true);
            }),
          ),
        ),
      ],
    );
  }

  Widget _buildModel() {
    if (_draft.brandId == null) return const SizedBox.shrink();
    final models = ref.watch(modelsForBrandProvider(_draft.brandId!));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label(AppLocalizations.of(context)!.filterModel),
        models.when(
          loading: () => const SizedBox(height: 40),
          error: (e, _) => Text('Erreur: $e',
              style: const TextStyle(color: AppColors.error)),
          data: (list) => _Select<int?>(
            value: _draft.modelId,
            hint: AppLocalizations.of(context)!.filterAllModels,
            items: [
              _Opt<int?>(null, AppLocalizations.of(context)!.filterAllModels),
              ...list.map((m) => _Opt<int?>(m.id, m.name)),
            ],
            onChanged: (v) => setState(() {
              _draft = v == null
                  ? _draft.copyWith(clearModel: true)
                  : _draft.copyWith(modelId: v);
            }),
          ),
        ),
      ],
    );
  }

  Widget _buildCity() {
    final cities = ref.watch(citiesListProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label(AppLocalizations.of(context)!.filterCity),
        cities.when(
          loading: () => const SizedBox(height: 40),
          error: (e, _) => Text('Erreur: $e',
              style: const TextStyle(color: AppColors.error)),
          data: (list) => _Select<int?>(
            value: _draft.cityId,
            hint: AppLocalizations.of(context)!.filterAllCities,
            items: [
              _Opt<int?>(null, AppLocalizations.of(context)!.filterAllCities),
              ...list.map((c) => _Opt<int?>(c.id, c.nameFr)),
            ],
            onChanged: (v) => setState(() {
              _draft = v == null
                  ? _draft.copyWith(clearCity: true)
                  : _draft.copyWith(cityId: v);
            }),
          ),
        ),
      ],
    );
  }

  Widget _buildPriceRange() {
    final fmt = NumberFormat.decimalPattern('fr_FR');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _label(AppLocalizations.of(context)!.filterPriceMru),
            const Spacer(),
            Text(
              '${fmt.format(_priceRange.start.toInt())} – ${fmt.format(_priceRange.end.toInt())}',
              style: const TextStyle(
                fontSize: 11,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        RangeSlider(
          values: _priceRange,
          min: 0,
          max: 10000000,
          divisions: 100,
          onChanged: (v) => setState(() {
            _priceRange = v;
            _draft = _draft.copyWith(
              priceMin: v.start > 0 ? v.start.toInt() : null,
              priceMax: v.end < 10000000 ? v.end.toInt() : null,
            );
          }),
        ),
      ],
    );
  }

  Widget _buildYearRange() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _label(AppLocalizations.of(context)!.filterYearLabel),
            const Spacer(),
            Text(
              '${_yearRange.start.toInt()} – ${_yearRange.end.toInt()}',
              style: const TextStyle(
                fontSize: 11,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        RangeSlider(
          values: _yearRange,
          min: 1990,
          max: 2026,
          divisions: 36,
          onChanged: (v) => setState(() {
            _yearRange = v;
            _draft = _draft.copyWith(
              yearMin: v.start > 1990 ? v.start.toInt() : null,
              yearMax: v.end < 2026 ? v.end.toInt() : null,
            );
          }),
        ),
      ],
    );
  }

  Widget _buildFuelChips() {
    final l = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label(l.filterFuel),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: _fuelOptions(l).map((opt) {
            final (key, label) = opt;
            final selected = _draft.fuel == key;
            return _Chip(
              label: label,
              selected: selected,
              onTap: () => setState(() {
                _draft = selected
                    ? _draft.copyWith(clearFuel: true)
                    : _draft.copyWith(fuel: key);
              }),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildTransmissionChips() {
    final l = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label(l.filterTransmission),
        Wrap(
          spacing: 6,
          children: _transOptions(l).map((opt) {
            final (key, label) = opt;
            final selected = _draft.transmission == key;
            return _Chip(
              label: label,
              selected: selected,
              onTap: () => setState(() {
                _draft = selected
                    ? _draft.copyWith(clearTransmission: true)
                    : _draft.copyWith(transmission: key);
              }),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildSort() {
    final l = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label(AppLocalizations.of(context)!.filterSortBy),
        _Select<String?>(
          value: _draft.sort ?? 'recent',
          hint: l.filterSortRecentHint,
          items: _sortOptions(l).map((o) => _Opt<String?>(o.$1, o.$2)).toList(),
          onChanged: (v) => setState(() => _draft = _draft.copyWith(sort: v)),
        ),
      ],
    );
  }

  void _reset() {
    setState(() {
      _draft = const VehicleFilter();
      _priceRange = const RangeValues(0, 10000000);
      _yearRange = const RangeValues(2000, 2026);
    });
  }

  void _apply() => Navigator.pop(context, _draft);
}

class _Opt<T> {
  const _Opt(this.value, this.label);
  final T value;
  final String label;
}

class _Select<T> extends StatelessWidget {
  const _Select({
    required this.value,
    required this.items,
    required this.onChanged,
    required this.hint,
  });

  final T value;
  final List<_Opt<T>> items;
  final ValueChanged<T?> onChanged;
  final String hint;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.borderStrong),
        borderRadius: BorderRadius.circular(6),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,
          hint: Text(hint),
          isExpanded: true,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          icon: const Padding(
            padding: EdgeInsets.only(right: 4),
            child: Icon(Icons.keyboard_arrow_down,
                size: 18, color: AppColors.textMuted),
          ),
          style: const TextStyle(
            fontSize: 13,
            color: AppColors.textPrimary,
          ),
          dropdownColor: AppColors.surface,
          items: items
              .map((o) => DropdownMenuItem<T>(
                    value: o.value,
                    child: Text(o.label),
                  ))
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? AppColors.brand100 : AppColors.surface,
      borderRadius: BorderRadius.circular(6),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(6),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: selected ? AppColors.primary : AppColors.borderStrong,
              width: selected ? 1.5 : 1,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: selected ? AppColors.brand700 : AppColors.textPrimary,
            ),
          ),
        ),
      ),
    );
  }
}
