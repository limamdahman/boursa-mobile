import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/storage/locale_storage.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});
  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  final _name = TextEditingController();
  final _email = TextEditingController();
  bool _saving = false;
  bool _avatarUploading = false;
  bool _init = false;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    super.dispose();
  }

  Future<void> _pickAvatar(bool isAr) async {
    final picker = ImagePicker();
    final file = await picker.pickImage(source: ImageSource.gallery);
    if (file == null) return;
    setState(() => _avatarUploading = true);
    try {
      final bytes = await file.readAsBytes();
      final url = await ref
          .read(authProvider.notifier)
          .repo
          .uploadAvatar(bytes, file.name);
      final current = ref.read(currentUserProvider);
      if (url != null && current != null) {
        ref.read(authProvider.notifier).applyUpdatedUser(
              current.copyWith(avatarUrl: url),
            );
      }
    } catch (_) {
    } finally {
      if (mounted) setState(() => _avatarUploading = false);
    }
  }

  Future<void> _save(bool isAr) async {
    setState(() => _saving = true);
    try {
      await ref.read(authProvider.notifier).updateProfile(
            name: _name.text.trim(),
            email: _email.text.trim().isEmpty ? null : _email.text.trim(),
          );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(isAr ? 'تم حفظ الملف الشخصي' : 'Profil enregistré'),
        ));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content:
              Text(isAr ? 'خطأ في الحفظ' : 'Erreur lors de l’enregistrement'),
        ));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isAr = ref.watch(localeProvider).languageCode == 'ar';
    final user = ref.watch(currentUserProvider);

    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: Text(isAr ? 'الإعدادات' : 'Paramètres')),
        body: Center(
          child: Text(isAr ? 'يرجى تسجيل الدخول' : 'Veuillez vous connecter'),
        ),
      );
    }

    if (!_init) {
      _name.text = user.name ?? '';
      _email.text = user.email ?? '';
      _init = true;
    }

    final initials = (user.name ?? '?')
        .trim()
        .split(RegExp(r'\s+'))
        .take(2)
        .map((w) => w.isEmpty ? '' : w[0].toUpperCase())
        .join();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: Text(isAr ? 'الإعدادات' : 'Paramètres')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Avatar
          Center(
            child: Stack(
              children: [
                ClipOval(
                  child: SizedBox(
                    width: 96,
                    height: 96,
                    child: user.avatarUrl != null
                        ? CachedNetworkImage(
                            imageUrl: user.avatarUrl!, fit: BoxFit.cover)
                        : Container(
                            color: const Color(0xFF0F172A),
                            alignment: Alignment.center,
                            child: Text(initials,
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 30,
                                    fontWeight: FontWeight.w800))),
                  ),
                ),
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: GestureDetector(
                    onTap: _avatarUploading ? null : () => _pickAvatar(isAr),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                      child: _avatarUploading
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: Colors.white))
                          : const Icon(Icons.camera_alt,
                              color: Colors.white, size: 16),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          // Nom
          Text(isAr ? 'الاسم الكامل' : 'Nom complet',
              style: GoogleFonts.sourceSans3(
                  fontSize: 13, fontWeight: FontWeight.w700)),
          const SizedBox(height: 6),
          TextField(
            controller: _name,
            decoration: const InputDecoration(border: OutlineInputBorder()),
          ),
          const SizedBox(height: 16),
          // Email
          Text(isAr ? 'البريد الإلكتروني' : 'Email',
              style: GoogleFonts.sourceSans3(
                  fontSize: 13, fontWeight: FontWeight.w700)),
          const SizedBox(height: 6),
          TextField(
            controller: _email,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(border: OutlineInputBorder()),
          ),
          const SizedBox(height: 16),
          // Téléphone (lecture seule)
          Text(isAr ? 'الهاتف' : 'Téléphone',
              style: GoogleFonts.sourceSans3(
                  fontSize: 13, fontWeight: FontWeight.w700)),
          const SizedBox(height: 6),
          TextField(
            enabled: false,
            controller: TextEditingController(text: user.phone),
            decoration: InputDecoration(
              border: const OutlineInputBorder(),
              fillColor: AppColors.background,
              filled: true,
            ),
          ),
          const SizedBox(height: 24),
          // Langue
          Text(isAr ? 'اللغة' : 'Langue',
              style: GoogleFonts.sourceSans3(
                  fontSize: 13, fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          Row(
            children: [
              _langChip('Français', !isAr, () async {
                await ref
                    .read(localeProvider.notifier)
                    .setLocale(const Locale('fr'));
                ref.read(authProvider.notifier).updateProfile(language: 'fr');
              }),
              const SizedBox(width: 10),
              _langChip('العربية', isAr, () async {
                await ref
                    .read(localeProvider.notifier)
                    .setLocale(const Locale('ar'));
                ref.read(authProvider.notifier).updateProfile(language: 'ar');
              }),
            ],
          ),
          const SizedBox(height: 28),
          FilledButton(
            onPressed: _saving ? null : () => _save(isAr),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primary,
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            child: _saving
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.white))
                : Text(isAr ? 'حفظ' : 'Enregistrer',
                    style: const TextStyle(fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  Widget _langChip(String label, bool active, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: active ? AppColors.primary : AppColors.surface,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
                color: active ? AppColors.primary : AppColors.border),
          ),
          child: Text(label,
              style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: active ? Colors.white : AppColors.textSecondary)),
        ),
      ),
    );
  }
}
