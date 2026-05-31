import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_client.dart';
import '../../data/models/chat_models.dart';
import '../../data/repositories/chat_repository.dart';

final chatRepositoryProvider = Provider<ChatRepository>((ref) {
  return ChatRepository(ref.read(apiClientProvider));
});

final conversationsProvider = FutureProvider<List<Conversation>>((ref) {
  return ref.read(chatRepositoryProvider).getConversations();
});

class MessagesNotifier extends StateNotifier<List<ChatMessage>> {
  final ChatRepository _repo;
  final String conversationId;

  MessagesNotifier(this._repo, this.conversationId) : super([]);

  Future<void> load() async {
    try {
      final msgs = await _repo.getMessages(conversationId);
      state = msgs;
    } catch (_) {}
  }

  Future<void> poll() async {
    if (state.isEmpty) {
      await load();
      return;
    }
    try {
      final since = state.last.createdAt.toIso8601String();
      final news = await _repo.getMessages(conversationId, since: since);
      if (news.isNotEmpty) {
        final ids = state.map((m) => m.id).toSet();
        state = [...state, ...news.where((m) => !ids.contains(m.id))];
      }
    } catch (_) {}
  }

  Future<void> send(String body) async {
    try {
      final msg = await _repo.sendMessage(conversationId, body);
      state = [...state, msg];
    } catch (_) {}
  }
}

final messagesProvider =
    StateNotifierProvider.family<MessagesNotifier, List<ChatMessage>, String>(
  (ref, convId) => MessagesNotifier(ref.read(chatRepositoryProvider), convId),
);
