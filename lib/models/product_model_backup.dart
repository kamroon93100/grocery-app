class ProductModel {
  final String       id;
  final String       name;
  final String       description;
  final double       price;
  final double       discount;
  final int          stock;
  final String       unit;
  final List<String> images;
  final String?      thumbnail;
  final String       categoryId;
  final String?      categoryName;
  final String?      categoryIcon;
  final bool         isActive;
  final bool         isFeatured;
  final double       rating;
  final int          reviewCount;
  final List<String> tags;

  ProductModel({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.discount,
    required this.stock,
    required this.unit,
    required this.images,
    this.thumbnail,
    required this.categoryId,
    this.categoryName,
    this.categoryIcon,
    required this.isActive,
    required this.isFeatured,
    required this.rating,
    required this.reviewCount,
    required this.tags,
  });

  double get finalPrice {
    if (discount <= 0) return price;
    return price - (price * discount / 100);
  }

  bool get hasDiscount => discount > 0;
  bool get inStock     => stock > 0;
  bool get lowStock    => stock > 0 && stock <= 10;

  String get displayImage => thumbnail ?? (images.isNotEmpty ? images[0] : '🛒');
  bool   get isNetworkImage => displayImage.startsWith('http');
  bool   get isEmojiImage   => !isNetworkImage && displayImage.length <= 3;

  factory ProductModel.fromJson(Map<String, dynamic> json) => ProductModel(
    id:           json['id']          ?? '',
    name:         json['name']        ?? '',
    description:  json['description'] ?? '',
    price:        double.tryParse(json['price'].toString())    ?? 0.0,
    discount:     double.tryParse(json['discount'].toString()) ?? 0.0,
    stock:        json['stock']       ?? 0,
    unit:         json['unit']        ?? 'piece',
    images:       List<String>.from(json['images'] ?? []),
    thumbnail:    json['thumbnail'],
    categoryId:   json['categoryId']  ?? '',
    categoryName: json['category']?['name'] ?? json['categoryName'],
    categoryIcon: json['category']?['icon'] ?? json['categoryIcon'],
    isActive:     json['isActive']    ?? true,
    isFeatured:   json['isFeatured']  ?? false,
    rating:       double.tryParse(json['rating'].toString())      ?? 0.0,
    reviewCount:  json['reviewCount'] ?? 0,
    tags:         List<String>.from(json['tags'] ?? []),
  );

  Map<String, dynamic> toJson() => {
    'id':           id,
    'name':         name,
    'description':  description,
    'price':        price,
    'discount':     discount,
    'stock':        stock,
    'unit':         unit,
    'images':       images,
    'thumbnail':    thumbnail,
    'categoryId':   categoryId,
    'categoryName': categoryName,
    'categoryIcon': categoryIcon,
    'isActive':     isActive,
    'isFeatured':   isFeatured,
    'rating':       rating,
    'reviewCount':  reviewCount,
    'tags':         tags,
  };
}

