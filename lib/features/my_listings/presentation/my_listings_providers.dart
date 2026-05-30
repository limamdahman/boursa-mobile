import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_client.dart';
import '../data/my_vehicle.dart';
import '../data/user_vehicle_repository.dart';

final userVehicleRepositoryProvider = Provider<UserVehicleRepository>((ref) {
  return UserVehicleRepository(ref.read(apiClientProvider));
});

final myVehiclesProvider = FutureProvider<List<MyVehicle>>((ref) async {
  return ref.read(userVehicleRepositoryProvider).myVehicles();
});
