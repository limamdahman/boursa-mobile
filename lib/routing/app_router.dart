import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../features/auth/presentation/screens/otp_screen.dart';
import '../features/auth/presentation/screens/phone_login_screen.dart';
import '../features/auth/presentation/screens/profile_screen.dart';
import '../features/vehicles/presentation/screens/listing_screen.dart';
import '../features/vehicles/presentation/screens/vehicle_detail_screen.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const ListingScreen(),
    ),
    GoRoute(
      path: '/vehicle/:id',
      builder: (context, state) {
        final id = state.pathParameters['id']!;
        return VehicleDetailScreen(id: id);
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
    GoRoute(
      path: '/profile',
      builder: (context, state) => const ProfileScreen(),
    ),
  ],
  errorBuilder: (context, state) => Scaffold(
    body: Center(
      child: Text('Page introuvable: ${state.uri}'),
    ),
  ),
);
