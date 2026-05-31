import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_client.dart';
import '../data/follow_repository.dart';

final followRepositoryProvider = Provider<FollowRepository>((ref) {
  return FollowRepository(ref.read(apiClientProvider));
});

typedef SellerKey = ({String type, String id});

final isFollowingProvider =
    FutureProvider.family<bool, SellerKey>((ref, key) async {
  try {
    return await ref.read(followRepositoryProvider).isFollowing(key.type, key.id);
  } catch (_) {
    return false;
  }
});

final followersCountProvider =
    FutureProvider.family<int, SellerKey>((ref, key) async {
  try {
    return await ref.read(followRepositoryProvider).followersCount(key.type, key.id);
  } catch (_) {
    return 0;
  }
});
