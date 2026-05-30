import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/theme/app_colors.dart';
import '../core/ui/icons/boursa_icons.dart';
import '../l10n/app_localizations.dart';

class MainShell extends ConsumerWidget {
  const MainShell({super.key, required this.child});
  final Widget child;

  static List<_Tab> _buildTabs(BuildContext context) => <_Tab>[
    _Tab(
      path: '/',
      label: AppLocalizations.of(context)!.navHome,
      builder: (selected, color) => Icon(
        selected ? Icons.home : Icons.home_outlined,
        size: 22, color: color),
    ),
    _Tab(
      path: '/vehicules',
      label: AppLocalizations.of(context)!.navVehicles,
      builder: (selected, color) =>
          BoursaCarIcon(size: 22, color: color, strokeWidth: 1.6),
    ),
    _Tab(
      path: '/agences',
      label: AppLocalizations.of(context)!.navAgencies,
      builder: (selected, color) => Icon(
        selected ? Icons.storefront : Icons.storefront_outlined,
        size: 22,
        color: color,
      ),
    ),
    _Tab(
      path: '/chat',
      label: AppLocalizations.of(context)!.navChat,
      builder: (selected, color) => BoursaChatIcon(
        size: 22,
        color: color,
        filled: selected,
        strokeWidth: 1.8,
      ),
    ),
    _Tab(
      path: '/favorites',
      label: AppLocalizations.of(context)!.navFavorites,
      builder: (selected, color) => BoursaHeartIcon(
        size: 22,
        filled: selected,
        activeColor: color,
        inactiveColor: color,
      ),
    ),
    _Tab(
      path: '/profile',
      label: AppLocalizations.of(context)!.navProfile,
      builder: (selected, color) => Icon(
        selected ? Icons.person : Icons.person_outline,
        size: 22,
        color: color,
      ),
    ),
  ];

  /// Détermine quel onglet est actif depuis l'URL courante.
  static int _resolveIndex(String location, List<_Tab> tabs) {
    if (location == '/') return 0;
    if (location.startsWith('/vehicules') || location.startsWith('/vehicle')) return 1;
    for (int i = 1; i < tabs.length; i++) {
      if (location.startsWith(tabs[i].path)) return i;
    }
    return 0;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final location = GoRouterState.of(context).uri.toString();
    final tabs = _buildTabs(context);
    final idx = _resolveIndex(location, tabs);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: child,
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: AppColors.surface,
          boxShadow: [
            BoxShadow(
              color: Color(0x140F172A),
              blurRadius: 16,
              spreadRadius: 0,
              offset: Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Row(
              children: [
                for (var i = 0; i < tabs.length; i++)
                  Expanded(
                    child: _NavButton(
                      item: tabs[i],
                      selected: i == idx,
                      onTap: () => context.go(tabs[i].path),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Tab {
  const _Tab({
    required this.path,
    required this.label,
    required this.builder,
  });
  final String path;
  final String label;

  /// Builder de l'icône. Reçoit `selected` + `color` à appliquer.
  final Widget Function(bool selected, Color color) builder;
}

class _NavButton extends StatelessWidget {
  const _NavButton({
    required this.item,
    required this.selected,
    required this.onTap,
  });

  final _Tab item;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected ? AppColors.primary : AppColors.textSecondary;

    return InkResponse(
      onTap: onTap,
      radius: 36,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOut,
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 5,
              ),
              decoration: BoxDecoration(
                color: selected ? const Color(0x1F16A34A) : Colors.transparent,
                borderRadius: BorderRadius.circular(20),
              ),
              child: item.builder(selected, color),
            ),
            const SizedBox(height: 4),
            Text(
              item.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 11,
                height: 1.0,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
