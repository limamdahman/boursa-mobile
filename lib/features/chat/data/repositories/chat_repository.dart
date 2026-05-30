import 'package:dio/dio.dart';
import '../models/chat_models.dart';

class ChatRepository {
  final Dio _dio;
  ChatRepository(this._dio);

  Future<List<Conversation>> getConversations() async {
    final res = await _dio.get('/chat/conversations');
    final raw = res.data;
    final data = raw is List
        ? raw
        : (raw is Map && raw['data'] is List ? raw['data'] as List : <dynamic>[]);
    return data.map((e) => Conversation.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<Conversation> getOrCreateConversation(String agencyId) async {
    final res = await _dio.post('/chat/conversations/$agencyId');
    return Conversation.fromJson(res.data as Map<String, dynamic>);
  }

  Future<Conversation> getOrCreateSupport() async {
    final res = await _dio.post('/chat/support');
    return Conversation.fromJson(res.data as Map<String, dynamic>);
  }

  Future<List<ChatMessage>> getMessages(String conversationId, {String? since}) async {
    final params = since != null ? {'since': since} : null;
    final res = await _dio.get(
      '/chat/conversations/$conversationId/messages',
      queryParameters: params,
    );
    final data = res.data as List? ?? [];
    return data.map((e) => ChatMessage.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<ChatMessage> sendMessage(String conversationId, String body) async {
    final res = await _dio.post(
      '/chat/conversations/$conversationId/messages',
      data: {'body': body},
    );
    return ChatMessage.fromJson(res.data as Map<String, dynamic>);
  }
}
