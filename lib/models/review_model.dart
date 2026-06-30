class ReviewModel {
  final String  id;
  final String  userId;
  final String  userName;
  final String? userAvatar;
  final int     rating;
  final String  comment;
  final List<String> images;
  final bool    isVerified;
  final String  createdAt;

  ReviewModel({
    required this.id,
    required this.userId,
    required this.userName,
    this.userAvatar,
    required this.rating,
    required this.comment,
    this.images   = const [],
    this.isVerified = false,
    required this.createdAt,
  });

  factory ReviewModel.fromJson(Map<String, dynamic> json) => ReviewModel(
    id:         json['id']         ?? '',
    userId:     json['userId']     ?? '',
    userName:   json['user']?['name'] ?? 'Anonymous',
    userAvatar: json['user']?['avatar'],
    rating:     json['rating']     ?? 0,
    comment:    json['comment']    ?? '',
    images:     List<String>.from(json['images'] ?? []),
    isVerified: json['isVerified'] ?? false,
    createdAt:  json['createdAt']  ?? '',
  );
}

