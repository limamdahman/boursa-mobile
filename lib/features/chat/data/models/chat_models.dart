class ChatMessage {
  final String id;
  final String? conversationId;
  final String senderType; // 'user' | 'agency'
  final String body;
  final DateTime createdAt;
  final DateTime? readAt;

  const ChatMessage({
    required this.id,
    this.conversationId,
    required this.senderType,
    required this.body,
    required this.createdAt,
    this.readAt,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> j) => ChatMessage(
    id: j['id'].toString(),
    conversationId: j['conversation_id'] as String?,
    senderType: (j['sender_type'] ?? 'agency') as String,
    body: (j['body'] ?? '') as String,
    createdAt: DateTime.parse(j['created_at'] as String),
    readAt: j['read_at'] != null ? DateTime.parse(j['read_at'] as String) : null,
  );

  bool get isFromUser => senderType == 'user';
}

class Conversation {
  final String id;
  final String? agencyId;
  final String? agencyName;
  final String? agencyLogo;
  final String? agencyTier;
  final String? lastMessageBody;
  final DateTime? lastMessageAt;
  final int unreadCount;

  const Conversation({
    required this.id,
    this.agencyId,
    this.agencyName,
    this.agencyLogo,
    this.agencyTier,
    this.lastMessageBody,
    this.lastMessageAt,
    this.unreadCount = 0,
  });

  factory Conversation.fromJson(Map<String, dynamic> j) => Conversation(
    id: j['id'] as String,
    agencyId: j['agency_id'] as String?,
    agencyName: j['agency']?['name'] as String?,
    agencyLogo: j['agency']?['logo_url'] as String?,
    agencyTier: j['agency']?['tier'] as String?,
    lastMessageBody: j['last_message']?['body'] as String?,
    lastMessageAt: j['last_message_at'] != null
        ? DateTime.parse(j['last_message_at'] as String)
        : null,
    unreadCount: j['unread_count'] as int? ?? 0,
  );

  bool get isSupport => agencyId == null;
  String get displayName => agencyName ?? 'Support Boursa';
}
