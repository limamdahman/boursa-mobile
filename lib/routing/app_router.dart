import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/vehicles/presentation/screens/listing_screen.dart';
import '../features/vehicles/presentation/screens/vehicle_detail_screen.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const ListingScreen(),
      ),
      GoRoute(
        path: '/vehicle/:id',
        builder: (context, state) =>
            VehicleDetailScreen(id: state.pathParameters['id']!),
      ),
    ],
  );
});
