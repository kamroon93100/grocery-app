class NotificationModel {
  final String            id;
  final String            title;
  final String            body;
  final String            type;
  final Map<String,dynamic> data;
  final bool              isRead;
  final String            createdAt;

  NotificationModel({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    required this.data,
    required this.isRead,
    required this.createdAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) =>
      NotificationModel(
        id:        json['id']        ?? '',
        title:     json['title']     ?? '',
        body:      json['body']      ?? '',
        type:      json['type']      ?? 'general',
        data:      Map<String,dynamic>.from(json['data'] ?? {}),
        isRead:    json['isRead']    ?? false,
        createdAt: json['createdAt'] ?? '',
      );
}


