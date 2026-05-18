import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
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

  static const _fuelOptions = ['gasoline', 'diesel', 'hybrid', 'electric', 'gpl'];
  static const _transmissionOptions = ['manual', 'automatic'];
  static const _sortOptions = [
    ('recent', 'Plus récents'),
    ('price_asc', 'Prix croissant'),
    ('price_desc', 'Prix décroissant'),
    ('year_desc', 'Année décroissante'),
    ('mileage_asc', 'Kilométrage croissant'),
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
    final priceFmt = NumberFormat.decimalPattern('fr_FR');

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.85,
      maxChildSize: 0.95,
      minChildSize: 0.5,
      builder: (context, scrollController) => Container(
        decoration: const BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: Column(
          children: [
            // Handle
            Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 8, 12),
              child: Row(
                children: [
                  const Text(
                    'Filtres',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: _reset,
                    child: const Text('Réinitialiser'),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),

            const Divider(height: 1),

            // Scrollable content
            Expanded(
              child: ListView(
                controller: scrollController,
                padding: const EdgeInsets.all(16),
                children: [
                  _buildBrandSelector(),
                  if (_draft.brandId != null) ...[
                    const SizedBox(height: 16),
                    _buildModelSelector(),
                  ],
                  const SizedBox(height: 24),
                  _buildCitySelector(),
                  const SizedBox(height: 24),
                  _buildPriceRange(priceFmt),
                  const SizedBox(height: 24),
                  _buildYearRange(),
                  const SizedBox(height: 24),
                  _buildFuelChips(),
                  const SizedBox(height: 24),
                  _buildTransmissionChips(),
                  const SizedBox(height: 24),
                  _buildSortSelector(),
                  const SizedBox(height: 32),
                ],
              ),
            ),

            // Apply button
            Container(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              decoration: const BoxDecoration(
                color: AppColors.surface,
                border: Border(top: BorderSide(color: AppColors.border)),
              ),
              child: SafeArea(
                top: false,
                child: SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: _apply,
                    child: Text(
                      _draft.isEmpty
                          ? 'Voir les résultats'
                          : 'Appliquer (${_draft.activeCount} filtre(s))',
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Sections UI ──────────────────────────────────────────────────────────

  Widget _buildBrandSelector() {
    final brands = ref.watch(brandsListProvider);

    return _Section(
      label: 'Marque',
      child: brands.when(
        loading: () => const _LoadingChip(),
        error: (e, _) => Text('Erreur: $e', style: const TextStyle(color: AppColors.error)),
        data: (list) => DropdownButtonFormField<int?>(
          value: _draft.brandId,
          isExpanded: true,
          decoration: const InputDecoration(hintText: 'Toutes les marques'),
          items: [
            const DropdownMenuItem<int?>(value: null, child: Text('Toutes les marques')),
            ...list.map((b) => DropdownMenuItem<int?>(
                  value: b.id,
                  child: Text(b.name),
                )),
          ],
          onChanged: (v) {
            setState(() {
              if (v == null) {
                _draft = _draft.copyWith(clearBrand: true, clearModel: true);
              } else {
                _draft = _draft.copyWith(brandId: v, clearModel: true);
              }
            });
          },
        ),
      ),
    );
  }

  Widget _buildModelSelector() {
    if (_draft.brandId == null) return const SizedBox.shrink();
    final models = ref.watch(modelsForBrandProvider(_draft.brandId!));

    return _Section(
      label: 'Modèle',
      child: models.when(
        loading: () => const _LoadingChip(),
        error: (e, _) => Text('Erreur: $e', style: const TextStyle(color: AppColors.error)),
        data: (list) => DropdownButtonFormField<int?>(
          value: _draft.modelId,
          isExpanded: true,
          decoration: const InputDecoration(hintText: 'Tous les modèles'),
          items: [
            const DropdownMenuItem<int?>(value: null, child: Text('Tous les modèles')),
            ...list.map((m) => DropdownMenuItem<int?>(
                  value: m.id,
                  child: Text(m.name),
                )),
          ],
          onChanged: (v) => setState(() {
            _draft = v == null
                ? _draft.copyWith(clearModel: true)
                : _draft.copyWith(modelId: v);
          }),
        ),
      ),
    );
  }

  Widget _buildCitySelector() {
    final cities = ref.watch(citiesListProvider);

    return _Section(
      label: 'Ville',
      child: cities.when(
        loading: () => const _LoadingChip(),
        error: (e, _) => Text('Erreur: $e', style: const TextStyle(color: AppColors.error)),
        data: (list) => DropdownButtonFormField<int?>(
          value: _draft.cityId,
          isExpanded: true,
          decoration: const InputDecoration(hintText: 'Toutes les villes'),
          items: [
            const DropdownMenuItem<int?>(value: null, child: Text('Toutes les villes')),
            ...list.map((c) => DropdownMenuItem<int?>(
                  value: c.id,
                  child: Text(c.nameFr),
                )),
          ],
          onChanged: (v) => setState(() {
            _draft = v == null
                ? _draft.copyWith(clearCity: true)
                : _draft.copyWith(cityId: v);
          }),
        ),
      ),
    );
  }

  Widget _buildPriceRange(NumberFormat fmt) {
    return _Section(
      label: 'Prix (MRU)',
      subtitle:
          '${fmt.format(_priceRange.start.toInt())} – ${fmt.format(_priceRange.end.toInt())}',
      child: RangeSlider(
        values: _priceRange,
        min: 0,
        max: 10000000,
        divisions: 50,
        labels: RangeLabels(
          fmt.format(_priceRange.start.toInt()),
          fmt.format(_priceRange.end.toInt()),
        ),
        onChanged: (v) => setState(() {
          _priceRange = v;
          _draft = _draft.copyWith(
            priceMin: v.start > 0 ? v.start.toInt() : null,
            priceMax: v.end < 10000000 ? v.end.toInt() : null,
          );
        }),
      ),
    );
  }

  Widget _buildYearRange() {
    return _Section(
      label: 'Année',
      subtitle: '${_yearRange.start.toInt()} – ${_yearRange.end.toInt()}',
      child: RangeSlider(
        values: _yearRange,
        min: 1990,
        max: 2026,
        divisions: 36,
        labels: RangeLabels(
          '${_yearRange.start.toInt()}',
          '${_yearRange.end.toInt()}',
        ),
        onChanged: (v) => setState(() {
          _yearRange = v;
          _draft = _draft.copyWith(
            yearMin: v.start > 1990 ? v.start.toInt() : null,
            yearMax: v.end < 2026 ? v.end.toInt() : null,
          );
        }),
      ),
    );
  }

  Widget _buildFuelChips() {
    return _Section(
      label: 'Carburant',
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: _fuelOptions.map((fuel) {
          final selected = _draft.fuel == fuel;
          return FilterChip(
            label: Text(_fuelLabel(fuel)),
            selected: selected,
            onSelected: (s) => setState(() {
              _draft = s
                  ? _draft.copyWith(fuel: fuel)
                  : _draft.copyWith(clearFuel: true);
            }),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTransmissionChips() {
    return _Section(
      label: 'Transmission',
      child: Wrap(
        spacing: 8,
        children: _transmissionOptions.map((t) {
          final selected = _draft.transmission == t;
          return FilterChip(
            label: Text(t == 'manual' ? 'Manuelle' : 'Automatique'),
            selected: selected,
            onSelected: (s) => setState(() {
              _draft = s
                  ? _draft.copyWith(transmission: t)
                  : _draft.copyWith(clearTransmission: true);
            }),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSortSelector() {
    return _Section(
      label: 'Trier par',
      child: DropdownButtonFormField<String?>(
        value: _draft.sort ?? 'recent',
        isExpanded: true,
        items: _sortOptions
            .map((opt) => DropdownMenuItem<String?>(
                  value: opt.$1,
                  child: Text(opt.$2),
                ))
            .toList(),
        onChanged: (v) => setState(() {
          _draft = _draft.copyWith(sort: v);
        }),
      ),
    );
  }

  // ─── Actions ──────────────────────────────────────────────────────────────

  String _fuelLabel(String fuel) {
    switch (fuel) {
      case 'gasoline':
        return 'Essence';
      case 'diesel':
        return 'Diesel';
      case 'hybrid':
        return 'Hybride';
      case 'electric':
        return 'Électrique';
      case 'gpl':
        return 'GPL';
      default:
        return fuel;
    }
  }

  void _reset() {
    setState(() {
      _draft = const VehicleFilter();
      _priceRange = const RangeValues(0, 10000000);
      _yearRange = const RangeValues(2000, 2026);
    });
  }

  void _apply() {
    Navigator.pop(context, _draft);
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.label, this.subtitle, required this.child});

  final String label;
  final String? subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label,
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
            if (subtitle != null)
              Text(subtitle!,
                  style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
          ],
        ),
        const SizedBox(height: 8),
        child,
      ],
    );
  }
}

class _LoadingChip extends StatelessWidget {
  const _LoadingChip();

  @override
  Widget build(BuildContext context) => const SizedBox(
        height: 32,
        child: Center(
          child: SizedBox(
            width: 16, height: 16,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      );
}
