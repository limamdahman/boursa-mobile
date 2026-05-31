import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/storage/locale_storage.dart';
import '../../vehicles/data/models/reference.dart';
import '../../vehicles/data/repositories/reference_repository.dart';
import '../../my_listings/presentation/my_listings_providers.dart';
import 'publish_providers.dart';
import '../../../core/theme/app_font.dart';

class _Photo {
  _Photo(this.bytes, this.name);
  final Uint8List bytes;
  final String name;
}

class PublishScreen extends ConsumerStatefulWidget {
  const PublishScreen({super.key});
  @override
  ConsumerState<PublishScreen> createState() => _PublishScreenState();
}

class _PublishScreenState extends ConsumerState<PublishScreen> {
  int _step = 0;
  bool _submitting = false;
  String? _error;

  // Étape 1
  int? _brandId;
  int? _modelId;
  int _year = DateTime.now().year;
  // Étape 2
  final _mileage = TextEditingController();
  final _price = TextEditingController();
  bool _negotiable = false;
  String? _fuel;
  String? _transmission;
  String? _bodyType;
  int? _cityId;
  // Étape 3
  final List<_Photo> _photos = [];
  // Étape 4
  final _descFr = TextEditingController();
  final _descAr = TextEditingController();

  @override
  void dispose() {
    _mileage.dispose();
    _price.dispose();
    _descFr.dispose();
    _descAr.dispose();
    super.dispose();
  }

  bool get _canNext {
    switch (_step) {
      case 0:
        return _brandId != null && _modelId != null;
      case 1:
        return _price.text.trim().isNotEmpty &&
            (int.tryParse(_price.text.trim()) ?? 0) >= 50000;
      default:
        return true;
    }
  }

  Future<void> _pickPhotos() async {
    final picker = ImagePicker();
    final files = await picker.pickMultiImage();
    for (final f in files) {
      if (_photos.length >= 10) break;
      final bytes = await f.readAsBytes();
      _photos.add(_Photo(bytes, f.name));
    }
    setState(() {});
  }

  Future<void> _submit(bool isAr) async {
    setState(() {
      _submitting = true;
      _error = null;
    });
    try {
      final repo = ref.read(publishRepositoryProvider);
      final payload = <String, dynamic>{
        'brand_id': _brandId,
        'vehicle_model_id': _modelId,
        'year': _year,
        'price_mru': int.parse(_price.text.trim()),
        'price_negotiable': _negotiable,
        if (_mileage.text.trim().isNotEmpty)
          'mileage_km': int.tryParse(_mileage.text.trim()),
        if (_fuel != null) 'fuel': _fuel,
        if (_transmission != null) 'transmission': _transmission,
        if (_bodyType != null) 'body_type': _bodyType,
        if (_cityId != null) 'city_id': _cityId,
        if (_descFr.text.trim().isNotEmpty)
          'description_fr': _descFr.text.trim(),
        if (_descAr.text.trim().isNotEmpty)
          'description_ar': _descAr.text.trim(),
      };
      final id = await repo.create(payload);
      for (var i = 0; i < _photos.length; i++) {
        await repo.uploadPhoto(id, _photos[i].bytes, _photos[i].name,
            isCover: i == 0);
      }
      ref.invalidate(myVehiclesProvider);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(isAr
              ? 'تم إنشاء الإعلان، في انتظار المراجعة'
              : 'Annonce créée, en attente de modération'),
        ));
        context.go('/mes-annonces');
      }
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isAr = ref.watch(localeProvider).languageCode == 'ar';
    final steps = isAr
        ? ['السيارة', 'المواصفات', 'الصور', 'الوصف']
        : ['Véhicule', 'Caractéristiques', 'Photos', 'Description'];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
          title: Text('${isAr ? "نشر إعلان" : "Publier"} · ${steps[_step]}')),
      body: Column(
        children: [
          LinearProgressIndicator(
            value: (_step + 1) / steps.length,
            backgroundColor: AppColors.border,
            color: AppColors.primary,
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: _buildStep(isAr),
            ),
          ),
          if (_error != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child:
                  Text(_error!, style: const TextStyle(color: AppColors.error)),
            ),
          Padding(
            padding: EdgeInsets.fromLTRB(
                16, 8, 16, 12 + MediaQuery.of(context).padding.bottom),
            child: Row(
              children: [
                if (_step > 0)
                  Expanded(
                    child: OutlinedButton(
                      onPressed:
                          _submitting ? null : () => setState(() => _step--),
                      child: Text(isAr ? 'السابق' : 'Précédent'),
                    ),
                  ),
                if (_step > 0) const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    onPressed: (_canNext && !_submitting)
                        ? () {
                            if (_step < steps.length - 1) {
                              setState(() => _step++);
                            } else {
                              _submit(isAr);
                            }
                          }
                        : null,
                    child: _submitting
                        ? const SizedBox(
                            height: 16,
                            width: 16,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white))
                        : Text(_step < steps.length - 1
                            ? (isAr ? 'التالي' : 'Suivant')
                            : (isAr ? 'نشر' : 'Publier')),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStep(bool isAr) {
    switch (_step) {
      case 0:
        return _stepVehicle(isAr);
      case 1:
        return _stepSpecs(isAr);
      case 2:
        return _stepPhotos(isAr);
      default:
        return _stepDescription(isAr);
    }
  }

  Widget _stepVehicle(bool isAr) {
    final brands = ref.watch(brandsListProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        brands.when(
          loading: () => const LinearProgressIndicator(),
          error: (e, _) => Text('Erreur: $e'),
          data: (list) => DropdownButtonFormField<int>(
            value: _brandId,
            decoration: InputDecoration(
                labelText: isAr ? 'الماركة' : 'Marque',
                border: const OutlineInputBorder()),
            items: list
                .map((b) => DropdownMenuItem(value: b.id, child: Text(b.name)))
                .toList(),
            onChanged: (v) => setState(() {
              _brandId = v;
              _modelId = null;
            }),
          ),
        ),
        const SizedBox(height: 16),
        if (_brandId != null)
          ref.watch(modelsForBrandProvider(_brandId!)).when(
                loading: () => const LinearProgressIndicator(),
                error: (e, _) => Text('Erreur: $e'),
                data: (models) => DropdownButtonFormField<int>(
                  value: _modelId,
                  decoration: InputDecoration(
                      labelText: isAr ? 'الموديل' : 'Modèle',
                      border: const OutlineInputBorder()),
                  items: models
                      .map((m) =>
                          DropdownMenuItem(value: m.id, child: Text(m.name)))
                      .toList(),
                  onChanged: (v) => setState(() => _modelId = v),
                ),
              ),
        const SizedBox(height: 16),
        DropdownButtonFormField<int>(
          value: _year,
          decoration: InputDecoration(
              labelText: isAr ? 'السنة' : 'Année',
              border: const OutlineInputBorder()),
          items: [
            for (var y = DateTime.now().year; y >= 1980; y--)
              DropdownMenuItem(value: y, child: Text('$y'))
          ],
          onChanged: (v) => setState(() => _year = v ?? _year),
        ),
      ],
    );
  }

  Widget _stepSpecs(bool isAr) {
    final cities = ref.watch(citiesListProvider);
    return Column(
      children: [
        TextField(
          controller: _price,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
              labelText: isAr ? 'السعر (أوقية)' : 'Prix (MRU)',
              border: const OutlineInputBorder()),
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 14),
        TextField(
          controller: _mileage,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
              labelText: isAr ? 'الكيلومترات' : 'Kilométrage',
              border: const OutlineInputBorder()),
        ),
        const SizedBox(height: 14),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(isAr ? 'السعر قابل للتفاوض' : 'Prix négociable'),
          value: _negotiable,
          activeColor: AppColors.primary,
          onChanged: (v) => setState(() => _negotiable = v),
        ),
        _dropdown(
            isAr ? 'الوقود' : 'Carburant',
            _fuel,
            {
              'gasoline': isAr ? 'بنزين' : 'Essence',
              'diesel': isAr ? 'ديزل' : 'Diesel',
              'hybrid': isAr ? 'هايبرد' : 'Hybride',
              'electric': isAr ? 'كهربائي' : 'Électrique',
              'lpg': isAr ? 'غاز' : 'GPL',
            },
            (v) => setState(() => _fuel = v)),
        _dropdown(
            isAr ? 'ناقل الحركة' : 'Transmission',
            _transmission,
            {
              'manual': isAr ? 'يدوي' : 'Manuelle',
              'automatic': isAr ? 'أوتوماتيك' : 'Automatique',
            },
            (v) => setState(() => _transmission = v)),
        _dropdown(
            isAr ? 'الهيكل' : 'Carrosserie',
            _bodyType,
            {
              'sedan': isAr ? 'سيدان' : 'Berline',
              'suv': 'SUV',
              'pickup': 'Pickup',
              'hatchback': isAr ? 'هاتشباك' : 'Compacte',
              'van': isAr ? 'فان' : 'Van',
              'coupe': isAr ? 'كوبيه' : 'Coupé',
            },
            (v) => setState(() => _bodyType = v)),
        cities.when(
          loading: () => const SizedBox.shrink(),
          error: (_, __) => const SizedBox.shrink(),
          data: (list) => Padding(
            padding: const EdgeInsets.only(top: 14),
            child: DropdownButtonFormField<int>(
              value: _cityId,
              decoration: InputDecoration(
                  labelText: isAr ? 'المدينة' : 'Ville',
                  border: const OutlineInputBorder()),
              items: list
                  .map((c) => DropdownMenuItem(
                      value: c.id,
                      child: Text(c.displayName(isAr ? 'ar' : 'fr'))))
                  .toList(),
              onChanged: (v) => setState(() => _cityId = v),
            ),
          ),
        ),
      ],
    );
  }

  Widget _dropdown(String label, String? value, Map<String, String> options,
      ValueChanged<String?> onChanged) {
    return Padding(
      padding: const EdgeInsets.only(top: 14),
      child: DropdownButtonFormField<String>(
        value: value,
        decoration: InputDecoration(
            labelText: label, border: const OutlineInputBorder()),
        items: options.entries
            .map((e) => DropdownMenuItem(value: e.key, child: Text(e.value)))
            .toList(),
        onChanged: onChanged,
      ),
    );
  }

  Widget _stepPhotos(bool isAr) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        OutlinedButton.icon(
          onPressed: _photos.length >= 10 ? null : _pickPhotos,
          icon: const Icon(Icons.add_photo_alternate_outlined),
          label: Text(isAr
              ? 'إضافة صور (${_photos.length}/10)'
              : 'Ajouter des photos (${_photos.length}/10)'),
        ),
        const SizedBox(height: 6),
        Text(
          isAr
              ? 'الصورة الأولى هي الغلاف. حد أقصى 10 صور.'
              : 'La 1ʳᵉ photo est la couverture. Max 10 photos.',
          style: appFont(context, fontSize: 12, color: AppColors.textSecondary),
        ),
        const SizedBox(height: 14),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (var i = 0; i < _photos.length; i++)
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.memory(_photos[i].bytes,
                        width: 90, height: 90, fit: BoxFit.cover),
                  ),
                  if (i == 0)
                    Positioned(
                      left: 4,
                      bottom: 4,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 5, vertical: 1),
                        color: AppColors.primary,
                        child: const Text('Cover',
                            style: TextStyle(color: Colors.white, fontSize: 9)),
                      ),
                    ),
                  Positioned(
                    right: 0,
                    top: 0,
                    child: GestureDetector(
                      onTap: () => setState(() => _photos.removeAt(i)),
                      child: Container(
                        color: Colors.black54,
                        child: const Icon(Icons.close,
                            color: Colors.white, size: 18),
                      ),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ],
    );
  }

  Widget _stepDescription(bool isAr) {
    return Column(
      children: [
        TextField(
          controller: _descFr,
          maxLines: 4,
          decoration: const InputDecoration(
              labelText: 'Description (FR)', border: OutlineInputBorder()),
        ),
        const SizedBox(height: 14),
        TextField(
          controller: _descAr,
          maxLines: 4,
          textDirection: TextDirection.rtl,
          decoration: const InputDecoration(
              labelText: 'الوصف (AR)', border: OutlineInputBorder()),
        ),
      ],
    );
  }
}
