class UserModel {
  final String  id;
  final String  name;
  final String  email;
  final String  phone;
  final String  role;
  final String? avatar;
  final bool    isVerified;
  final bool    isActive;
  final double  walletBalance;
  final String? fcmToken;
  final String? lastLogin;
  final String  createdAt;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.role,
    this.avatar,
    required this.isVerified,
    required this.isActive,
    required this.walletBalance,
    this.fcmToken,
    this.lastLogin,
    required this.createdAt,
  });

  bool get isAdmin    => role == 'admin';
  bool get isDelivery => role == 'delivery';
  bool get isCustomer => role == 'customer';

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
    id:            json['id']            ?? '',
    name:          json['name']          ?? '',
    email:         json['email']         ?? '',
    phone:         json['phone']         ?? '',
    role:          json['role']          ?? 'customer',
    avatar:        json['avatar'],
    isVerified:    json['isVerified']    ?? false,
    isActive:      json['isActive']      ?? true,
    walletBalance: double.tryParse(json['walletBalance'].toString()) ?? 0.0,
    fcmToken:      json['fcmToken'],
    lastLogin:     json['lastLogin'],
    createdAt:     json['createdAt']     ?? '',
  );

  Map<String, dynamic> toJson() => {
    'id':           id,
    'name':         name,
    'email':        email,
    'phone':        phone,
    'role':         role,
    'avatar':       avatar,
    'isVerified':   isVerified,
    'isActive':     isActive,
    'walletBalance':walletBalance,
    'createdAt':    createdAt,
  };
}
