import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../providers/auth_provider.dart';

class PhoneLoginScreen extends ConsumerStatefulWidget {
  const PhoneLoginScreen({super.key});

  @override
  ConsumerState<PhoneLoginScreen> createState() => _PhoneLoginScreenState();
}

class _PhoneLoginScreenState extends ConsumerState<PhoneLoginScreen> {
  final _controller = TextEditingController();
  bool _submitting = false;
  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() {
      _error = null;
      _submitting = true;
    });
    final raw = _controller.text.trim();
    String phone = raw;
    // Auto-format : si commence par 8 chiffres et pas de +, ajoute +222 (MR)
    if (raw.length == 8 && !raw.startsWith('+') && RegExp(r'^\d+$').hasMatch(raw)) {
      phone = '+222$raw';
    }

    try {
      final normalized = await ref.read(authProvider.notifier).requestOtp(phone);
      if (!mounted) return;
      context.go('/otp', extra: normalized);
    } on Object catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Connexion'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 20),
            const Icon(Icons.phone_android, size: 64, color: AppColors.primary),
            const SizedBox(height: 24),
            Text(
              'Entrez votre numéro de téléphone',
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              'Nous vous enverrons un code de vérification par SMS',
              style: TextStyle(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            TextField(
              controller: _controller,
              keyboardType: TextInputType.phone,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[0-9+]')),
              ],
              decoration: const InputDecoration(
                labelText: 'Téléphone',
                hintText: '+222 33 44 55 66',
                prefixIcon: Icon(Icons.phone),
                border: OutlineInputBorder(),
              ),
              autofocus: true,
              onSubmitted: (_) => _submit(),
            ),
            if (_error != null) ...[
              const SizedBox(height: 12),
              Text(
                _error!,
                style: const TextStyle(color: AppColors.error),
              ),
            ],
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _submitting ? null : _submit,
              child: _submitting
                  ? const SizedBox(
                      height: 16, width: 16,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Text('Recevoir le code'),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => context.go('/'),
              child: const Text('Continuer sans compte'),
            ),
          ],
        ),
      ),
    );
  }
}
