import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/ui/icons/boursa_icons.dart';
import '../../../../l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/chat_provider.dart';
import '../../data/models/chat_models.dart';

class ChatListScreen extends ConsumerWidget {
  const ChatListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isAuth = ref.watch(isAuthenticatedProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          _CompactHeader(title: AppLocalizations.of(context)!.navMessages, subtitle: AppLocalizations.of(context)!.messagesSubtitle),
          Expanded(
            child: !isAuth
                ? _NotLoggedIn()
                : ref.watch(conversationsProvider).when(
                    loading: () => const Center(
                        child: CircularProgressIndicator(
                            color: AppColors.primary)),
                    error: (e, _) => Center(child: Text('Erreur: $e')),
                    data: (convs) => convs.isEmpty
                        ? _EmptyState()
                        : ListView.builder(
                            itemCount: convs.length,
                            itemBuilder: (context, i) => _ChatRow(
                              conv: convs[i],
                              onTap: () =>
                                  context.push('/chat/${convs[i].id}',
                                      extra: convs[i].displayName),
                            ),
                          ),
                  ),
          ),
        ],
      ),
    );
  }
}

class _ChatRow extends StatelessWidget {
  const _ChatRow({required this.conv, required this.onTap});
  final Conversation conv;
  final VoidCallback onTap;

  static const _gradients = [
    [Color(0xFF16A34A), Color(0xFF0f766e)],
    [Color(0xFF0ea5e9), Color(0xFF1e40af)],
    [Color(0xFFf59e0b), Color(0xFFb45309)],
    [Color(0xFF8b5cf6), Color(0xFF6d28d9)],
    [Color(0xFFef4444), Color(0xFF991b1b)],
  ];

  List<Color> get _gradient {
    final name = conv.displayName;
    final idx = name.isNotEmpty ? name.codeUnitAt(0) % _gradients.length : 0;
    return _gradients[idx];
  }

  String get _initials {
    final parts = conv.displayName.split(' ').where((s) => s.isNotEmpty).take(2);
    return parts.map((s) => s[0].toUpperCase()).join();
  }

  String _formatTime(DateTime? dt) {
    if (dt == null) return '';
    final now = DateTime.now();
    if (now.difference(dt).inDays == 0) return DateFormat('HH:mm').format(dt);
    if (now.difference(dt).inDays == 1) return 'Hier';
    return DateFormat('EEE', 'fr').format(dt);
  }

  @override
  Widget build(BuildContext context) {
    final hasUnread = conv.unreadCount > 0;

    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: const BoxDecoration(
          color: AppColors.surface,
          border: Border(bottom: BorderSide(color: AppColors.border)),
        ),
        child: Row(
          children: [
            // Avatar : logo agence réel, sinon dégradé + initiales
            _Avatar(
              logoUrl: conv.agencyLogo,
              initials: _initials,
              gradient: _gradient,
            ),
            const SizedBox(width: 13),
            // Milieu
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          conv.displayName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.sourceSans3(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      if (conv.agencyVerified) ...[
                        const SizedBox(width: 5),
                        BoursaVerifiedIcon(
                          size: 15,
                          color: conv.agencyTier == 'business'
                              ? AppColors.priceColor
                              : AppColors.primary,
                        ),
                      ],
                      const SizedBox(width: 8),
                      Text(
                        _formatTime(conv.lastMessageAt),
                        style: GoogleFonts.sourceSans3(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    conv.lastMessageBody ?? 'Aucun message',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.sourceSans3(
                      fontSize: 13,
                      fontWeight:
                          hasUnread ? FontWeight.w600 : FontWeight.w400,
                      color: hasUnread
                          ? AppColors.textPrimary
                          : AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            // Badge non-lus
            if (hasUnread) ...[
              const SizedBox(width: 8),
              Container(
                width: 20,
                height: 20,
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    '${conv.unreadCount}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: const Color(0x1F16A34A),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(Icons.chat_bubble_outline,
                size: 36, color: AppColors.primary),
          ),
          const SizedBox(height: 16),
          Text(
            'Aucune conversation',
            style: GoogleFonts.sourceSans3(
              fontSize: 17,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Contactez une agence depuis une annonce',
            style: GoogleFonts.sourceSans3(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _NotLoggedIn extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: const Color(0x1F16A34A),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(Icons.lock_outline,
                  size: 36, color: AppColors.primary),
            ),
            const SizedBox(height: 16),
            Text(
              AppLocalizations.of(context)!.authConnectForMessages,
              textAlign: TextAlign.center,
              style: GoogleFonts.sourceSans3(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: FilledButton(
                onPressed: () => context.push('/login'),
                child: Text(AppLocalizations.of(context)!.authSignIn),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CompactHeader extends StatelessWidget {
  const _CompactHeader({required this.title, required this.subtitle});
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF064E3B), Color(0xFF052E22), Color(0xFF0A0A0A)],
          stops: [0.0, 0.55, 1.0],
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
              color: Color(0x2616A34A),
              blurRadius: 18,
              offset: Offset(0, 8)),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: GoogleFonts.sourceSans3(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.3,
                    color: Colors.white,
                  )),
              const SizedBox(height: 3),
              Text(subtitle,
                  style: GoogleFonts.sourceSans3(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.7),
                  )),
            ],
          ),
        ),
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.logoUrl, required this.initials, required this.gradient});
  final String? logoUrl;
  final String initials;
  final List<Color> gradient;

  Widget _fallback() => Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: gradient,
          ),
        ),
        child: Center(
          child: Text(
            initials,
            style: GoogleFonts.sourceSans3(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 17,
            ),
          ),
        ),
      );

  @override
  Widget build(BuildContext context) {
    if (logoUrl == null || logoUrl!.isEmpty) return _fallback();
    return ClipOval(
      child: CachedNetworkImage(
        imageUrl: logoUrl!,
        width: 50,
        height: 50,
        fit: BoxFit.cover,
        placeholder: (_, __) => _fallback(),
        errorWidget: (_, __, ___) => _fallback(),
      ),
    );
  }
}

