class OrderItemModel {
  final String id;
  final String productId;
  final String productName;
  final String productImage;
  final double price;
  final int    quantity;
  final double subtotal;

  OrderItemModel({
    required this.id,
    required this.productId,
    required this.productName,
    required this.productImage,
    required this.price,
    required this.quantity,
    required this.subtotal,
  });

  factory OrderItemModel.fromJson(Map<String, dynamic> json) => OrderItemModel(
    id:           json['id']           ?? '',
    productId:    json['productId']    ?? '',
    productName:  json['productName']  ?? '',
    productImage: json['productImage'] ?? '🛒',
    price:        double.tryParse(json['price'].toString())    ?? 0.0,
    quantity:     json['quantity']     ?? 1,
    subtotal:     double.tryParse(json['subtotal'].toString()) ?? 0.0,
  );
}

class OrderModel {
  final String           id;
  final String           orderNumber;
  final String           userId;
  final String           status;
  final String           paymentStatus;
  final String           paymentMethod;
  final double           subtotal;
  final double           discount;
  final double           deliveryFee;
  final double           tax;
  final double           totalAmount;
  final double           couponDiscount;
  final String?          couponCode;
  final Map<String, dynamic> deliveryAddress;
  final List<OrderItemModel> items;
  final String           createdAt;
  final String notes;
  final String?          cancelReason;
  final int              estimatedTime;
  final double?          deliveryLat;
  final double?          deliveryLng;

  OrderModel({
    required this.id,
    required this.orderNumber,
    required this.userId,
    required this.status,
    required this.paymentStatus,
    required this.paymentMethod,
    required this.subtotal,
    required this.discount,
    required this.deliveryFee,
    required this.tax,
    required this.totalAmount,
    required this.couponDiscount,
    this.couponCode,
    required this.deliveryAddress,
    required this.items,
    required this.createdAt,
    this.notes = '',
    this.cancelReason,
    required this.estimatedTime,
    this.deliveryLat,
    this.deliveryLng,
  });

  bool get isPending    => status == 'pending';
  bool get isConfirmed  => status == 'confirmed';
  bool get isDelivered  => status == 'delivered';
  bool get isCancelled  => status == 'cancelled';
  bool get canCancel    => ['pending','confirmed'].contains(status);

  factory OrderModel.fromJson(Map<String, dynamic> json) => OrderModel(
    id:             json['id']            ?? '',
    orderNumber:    json['orderNumber']   ?? '',
    userId:         json['userId']        ?? '',
    status:         json['status']        ?? 'pending',
    paymentStatus:  json['paymentStatus'] ?? 'pending',
    paymentMethod:  json['paymentMethod'] ?? 'cod',
    subtotal:       double.tryParse(json['subtotal'].toString())       ?? 0.0,
    discount:       double.tryParse(json['discount'].toString())       ?? 0.0,
    deliveryFee:    double.tryParse(json['deliveryFee'].toString())    ?? 0.0,
    tax:            double.tryParse(json['tax'].toString())            ?? 0.0,
    totalAmount:    double.tryParse(json['totalAmount'].toString())    ?? 0.0,
    couponDiscount: double.tryParse(json['couponDiscount'].toString()) ?? 0.0,
    couponCode:     json['couponCode'],
    deliveryAddress:Map<String,dynamic>.from(json['deliveryAddress'] ?? {}),
    items: (json['items'] as List<dynamic>? ?? [])
        .map((i) => OrderItemModel.fromJson(i))
        .toList(),
    createdAt:     json['createdAt']    ?? '',
    notes: json['notes'] ?? '',
    cancelReason:  json['cancelReason'],
    estimatedTime: json['estimatedTime'] ?? 30,
    deliveryLat: double.tryParse(json['deliveryLat']?.toString() ?? ''),
    deliveryLng: double.tryParse(json['deliveryLng']?.toString() ?? ''),
  );
}



