import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_client.dart';
import '../data/publish_repository.dart';

final publishRepositoryProvider = Provider<PublishRepository>((ref) {
  return PublishRepository(ref.read(apiClientProvider));
});
