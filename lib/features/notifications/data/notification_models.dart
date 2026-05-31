class AppNotification {
  AppNotification({
    required this.id,
    required this.data,
    this.readAt,
    this.createdAt,
  });

  final String id;
  final Map<String, dynamic> data;
  final DateTime? readAt;
  final DateTime? createdAt;

  bool get isRead => readAt != null;
  String get type => (data['type'] ?? '') as String;
  String? get vehicleId => data['vehicle_id'] as String?;
  String? get brand => data['brand'] as String?;
  String? get model => data['model'] as String?;
  int? get year => (data['year'] as num?)?.toInt();
  String? get leadName =>
      data['lead_name'] as String? ?? data['leadName'] as String?;

  factory AppNotification.fromJson(Map<String, dynamic> j) => AppNotification(
        id: j['id'].toString(),
        data:
            (j['data'] as Map?)?.cast<String, dynamic>() ?? <String, dynamic>{},
        readAt: j['read_at'] != null
            ? DateTime.tryParse(j['read_at'] as String)
            : null,
        createdAt: j['created_at'] != null
            ? DateTime.tryParse(j['created_at'] as String)
            : null,
      );
}
