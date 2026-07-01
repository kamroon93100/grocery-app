class ProductModel {
  final String id;
  final String name;
  final String description;
  final double price;
  final double discount;
  final int stock;
  final String unit;
  final List<String> images;
  final String? thumbnail;
  final String categoryId;
  final String? categoryName;
  final String? categoryIcon;
  final bool isActive;
  final bool isFeatured;
  final double rating;
  final int reviewCount;
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

  static const String _imageBase = 'https://kohli-store-api-4zh4.onrender.com/uploads/products/';

  double get finalPrice => discount <= 0 ? price : price - (price * discount / 100);
  bool get hasDiscount => discount > 0;
  bool get inStock => stock > 0;
  bool get lowStock => stock > 0 && stock <= 10;

  String get displayImage {
    final n = name.toLowerCase();

    String? forced;
    if (n.contains('banana')) forced = 'fresh-banana-robusta-1-dozen.webp';
    if (n.contains('apple')) forced = 'apple-royal-gala-4-pcs.webp';
    if (n.contains('pomegranate')) forced = 'pomegranate-2-pcs.webp';
    if (n.contains('orange')) forced = 'orange-nagpur-1-kg.webp';
    if (n.contains('papaya')) forced = 'papaya-semi-ripe-1-pc.webp';
    if (n.contains('tomato')) forced = 'tomato-hybrid-1-kg.webp';
    if (n.contains('potato')) forced = 'potato-fresh-1-kg.webp';
    if (n.contains('onion')) forced = 'onion-red-1-kg.webp';
    if (n.contains('taaza')) forced = 'amul-taaza-toned-milk-500-ml.webp';
    if (n.contains('gold') && n.contains('milk')) forced = 'amul-gold-full-cream-milk-500-ml.webp';
    if (n.contains('paneer')) forced = 'amul-fresh-paneer-200-g.webp';
    if (n.contains('butter')) forced = 'amul-butter-100-g.webp';
    if (n.contains('bread')) forced = 'britannia-brown-bread-400-g.webp';
    if (n.contains('egg')) forced = 'farm-fresh-eggs-6-pcs.webp';

    if (forced != null) return '$_imageBase$forced?v=$forced';

    return thumbnail ?? (images.isNotEmpty ? images[0] : '🛒');
  }

  bool get isNetworkImage => displayImage.startsWith('http');
  bool get isEmojiImage => !isNetworkImage && displayImage.length <= 3;

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    final variants = (json['variants'] as List?) ?? [];
    final variant = variants.isNotEmpty && variants.first is Map
        ? Map<String, dynamic>.from(variants.first)
        : <String, dynamic>{};

    final imageList = (json['images'] as List?) ?? [];
    final imageUrls = imageList.map((img) {
      if (img is Map) {
        final raw = (img['imageUrl'] ?? img['url'] ?? img['image'] ?? img['thumbnail'] ?? '').toString();
        if (raw.isEmpty) return '';
        if (raw.startsWith('http')) return raw;
        return '$_imageBase$raw?v=$raw';
      }
      return img.toString();
    }).where((x) => x.isNotEmpty).toList();

    final sellingPrice = double.tryParse((variant['sellingPrice'] ?? json['sellingPrice'] ?? json['price'] ?? '0').toString()) ?? 0.0;
    final mrp = double.tryParse((variant['mrp'] ?? json['mrp'] ?? sellingPrice).toString()) ?? sellingPrice;

    return ProductModel(
      id: (json['id'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      description: (json['description'] ?? '').toString(),
      price: sellingPrice,
      discount: mrp > sellingPrice && mrp > 0 ? ((mrp - sellingPrice) / mrp) * 100 : 0.0,
      stock: int.tryParse((variant['stock'] ?? json['stock'] ?? 0).toString()) ?? 0,
      unit: (variant['variant'] ?? variant['weight'] ?? variant['unit'] ?? json['unit'] ?? 'piece').toString(),
      images: imageUrls,
      thumbnail: imageUrls.isNotEmpty ? imageUrls.first : null,
      categoryId: (json['categoryId'] ?? '').toString(),
      categoryName: json['category'] is Map ? json['category']['name']?.toString() : null,
      categoryIcon: json['category'] is Map ? json['category']['image']?.toString() : null,
      isActive: json['isActive'] ?? true,
      isFeatured: json['isFeatured'] ?? false,
      rating: double.tryParse((json['rating'] ?? 0).toString()) ?? 0.0,
      reviewCount: int.tryParse((json['ratingCount'] ?? json['reviewCount'] ?? 0).toString()) ?? 0,
      tags: const [],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'description': description,
    'price': price,
    'discount': discount,
    'stock': stock,
    'unit': unit,
    'images': images,
    'thumbnail': thumbnail,
    'categoryId': categoryId,
    'categoryName': categoryName,
    'categoryIcon': categoryIcon,
    'isActive': isActive,
    'isFeatured': isFeatured,
    'rating': rating,
    'reviewCount': reviewCount,
    'tags': tags,
  };
}




