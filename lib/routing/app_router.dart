import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../features/auth/presentation/screens/otp_screen.dart';
import '../features/auth/presentation/screens/phone_login_screen.dart';
import '../features/auth/presentation/screens/profile_screen.dart';
import '../features/favorites/presentation/screens/favorites_screen.dart';
import '../features/vehicles/presentation/screens/listing_screen.dart';
import '../features/home/presentation/screens/home_screen.dart';
import '../features/vehicles/presentation/screens/vehicle_detail_screen.dart';
import '../features/agencies/presentation/screens/agencies_screen.dart';
import '../features/agencies/presentation/screens/agency_detail_screen.dart';
import '../features/chat/presentation/screens/chat_list_screen.dart';
import '../features/chat/presentation/screens/chat_screen.dart';
import '../shell/main_shell.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    ShellRoute(
      builder: (context, state, child) => MainShell(child: child),
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const HomeScreen(),
        ),
        GoRoute(
          path: '/vehicules',
          builder: (context, state) => const ListingScreen(),
        ),
        GoRoute(
          path: '/agences',
          builder: (context, state) => const AgenciesScreen(),
        ),
        GoRoute(
          path: '/chat',
          builder: (context, state) => const ChatListScreen(),
        ),
        GoRoute(
          path: '/favorites',
          builder: (context, state) => const FavoritesScreen(),
        ),
        GoRoute(
          path: '/profile',
          builder: (context, state) => const ProfileScreen(),
        ),
      ],
    ),
    GoRoute(
      path: '/vehicle/:id',
      builder: (context, state) {
        final id = state.pathParameters['id']!;
        return VehicleDetailScreen(id: id);
      },
    ),
    GoRoute(
      path: '/agences/:slug',
      builder: (context, state) {
        final slug = state.pathParameters['slug']!;
        return AgencyDetailScreen(slug: slug);
      },
    ),
    GoRoute(
      path: '/chat/:id',
      builder: (context, state) {
        final id = state.pathParameters['id']!;
        final title = state.extra as String?;
        return ChatScreen(conversationId: id, title: title);
      },
    ),
    GoRoute(
      path: '/login',
      builder: (context, state) => const PhoneLoginScreen(),
    ),
    GoRoute(
      path: '/otp',
      builder: (context, state) {
        final phone = state.extra as String? ?? '';
        return OtpScreen(phone: phone);
      },
    ),
  ],
  errorBuilder: (context, state) => Scaffold(
    body: Center(child: Text('Page introuvable: ${state.uri}')),
  ),
);
