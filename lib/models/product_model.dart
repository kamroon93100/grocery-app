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

  double get finalPrice => discount <= 0 ? price : price - (price * discount / 100);
  bool get hasDiscount => discount > 0;
  bool get inStock => stock > 0;
  bool get lowStock => stock > 0 && stock <= 10;
  String get displayImage => thumbnail ?? (images.isNotEmpty ? images[0] : '🛒');
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
        return 'http://127.0.0.1:3001/uploads/products/' + raw;

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


