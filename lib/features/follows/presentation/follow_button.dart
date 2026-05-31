import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/storage/locale_storage.dart';
import '../../auth/presentation/providers/auth_provider.dart';
import 'follow_providers.dart';
import '../../../core/theme/app_font.dart';

class FollowButton extends ConsumerWidget {
  const FollowButton(
      {super.key, required this.sellerType, required this.sellerId});
  final String sellerType; // 'user' | 'agency'
  final String sellerId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isAr = ref.watch(localeProvider).languageCode == 'ar';
    final isAuth = ref.watch(isAuthenticatedProvider);
    final key = (type: sellerType, id: sellerId);
    final following = ref.watch(isFollowingProvider(key)).valueOrNull ?? false;
    final count = ref.watch(followersCountProvider(key)).valueOrNull ?? 0;

    return OutlinedButton.icon(
      onPressed: () async {
        if (!isAuth) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(
                isAr ? 'سجل دخولك للمتابعة' : 'Connectez-vous pour suivre'),
          ));
          return;
        }
        try {
          await ref.read(followRepositoryProvider).toggle(sellerType, sellerId);
          ref.invalidate(isFollowingProvider(key));
          ref.invalidate(followersCountProvider(key));
        } catch (_) {}
      },
      style: OutlinedButton.styleFrom(
        backgroundColor: following ? AppColors.primary : Colors.transparent,
        foregroundColor: following ? Colors.white : AppColors.primary,
        side: const BorderSide(color: AppColors.primary),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      ),
      icon: Icon(following ? Icons.check : Icons.add, size: 16),
      label: Text(
        following
            ? '${isAr ? 'متابَع' : 'Suivi'}${count > 0 ? ' · $count' : ''}'
            : '${isAr ? 'متابعة' : 'Suivre'}${count > 0 ? ' · $count' : ''}',
        style: appFont(context, fontSize: 13, fontWeight: FontWeight.w700),
      ),
    );
  }
}
