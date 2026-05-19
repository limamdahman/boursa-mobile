import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../providers/auth_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(authProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mon compte'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/'),
        ),
      ),
      body: switch (state) {
        AuthInitial() || AuthLoading() =>
          const Center(child: CircularProgressIndicator()),
        AuthAnonymous() => _AnonymousView(),
        AuthAuthenticated(user: final user) => _AuthenticatedView(user: user),
        AuthError(message: final m) => Center(
            child: Text(m, style: const TextStyle(color: AppColors.error)),
          ),
      },
    );
  }
}

class _AnonymousView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.account_circle_outlined,
                size: 96, color: AppColors.textMuted),
            const SizedBox(height: 16),
            Text(
              'Vous n\'êtes pas connecté',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            const Text(
              'Connectez-vous pour sauvegarder vos favoris et contacter les vendeurs',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 32),
            FilledButton.icon(
              onPressed: () => context.go('/login'),
              icon: const Icon(Icons.login),
              label: const Text('Se connecter'),
            ),
          ],
        ),
      ),
    );
  }
}

class _AuthenticatedView extends ConsumerWidget {
  const _AuthenticatedView({required this.user});

  final dynamic user; // User type, mais évite import circulaire avec dynamic

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const SizedBox(height: 20),
        const Center(
          child: CircleAvatar(
            radius: 48,
            backgroundColor: AppColors.primary,
            child: Icon(Icons.person, size: 48, color: Colors.white),
          ),
        ),
        const SizedBox(height: 16),
        Center(
          child: Text(
            user.name ?? user.phone,
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ),
        if (user.name != null && user.phone.isNotEmpty)
          Center(
            child: Text(
              user.phone,
              style: const TextStyle(color: AppColors.textSecondary),
            ),
          ),
        const SizedBox(height: 32),
        const Divider(),
        ListTile(
          leading: const Icon(Icons.favorite_outline),
          title: const Text('Mes favoris'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Bientôt disponible')),
            );
          },
        ),
        if (user.isAgencyOwner)
          ListTile(
            leading: const Icon(Icons.business),
            title: const Text('Mon agence'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Bientôt disponible')),
              );
            },
          ),
        const Divider(),
        ListTile(
          leading: const Icon(Icons.logout, color: AppColors.error),
          title: const Text('Se déconnecter',
              style: TextStyle(color: AppColors.error)),
          onTap: () async {
            final confirm = await showDialog<bool>(
              context: context,
              builder: (_) => AlertDialog(
                title: const Text('Déconnexion'),
                content: const Text('Voulez-vous vraiment vous déconnecter ?'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: const Text('Annuler'),
                  ),
                  FilledButton(
                    onPressed: () => Navigator.pop(context, true),
                    child: const Text('Déconnecter'),
                  ),
                ],
              ),
            );
            if (confirm == true) {
              await ref.read(authProvider.notifier).logout();
              if (context.mounted) context.go('/');
            }
          },
        ),
      ],
    );
  }
}
