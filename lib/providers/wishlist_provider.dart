import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/api_constants.dart';
import '../models/product_model.dart';
import '../services/api_service.dart';

class WishlistProvider extends ChangeNotifier {
  static const String _key = 'wishlist_items';
  List<ProductModel> _items = [];
  final ApiService _api = ApiService();

  List<ProductModel> get items => _items;
  int get count => _items.length;

  Future<void> loadWishlist() async {
    // Try server first
    try {
      final result = await _api.get(ApiConstants.wishlist);
      if (result['success'] == true) {
        final list = result['data']['items'] as List;
        _items = list.map((json) => ProductModel.fromJson(json)).toList();
        notifyListeners();
        return;
      }
    } catch (_) {}

    // Fallback to local
    try {
      final prefs = await SharedPreferences.getInstance();
      final saved = prefs.getString(_key);
      if (saved != null) {
        final list = jsonDecode(saved) as List;
        _items = list.map((item) {
          try {
            return ProductModel(
              id:           item['id']           ?? '',
              name:         item['name']         ?? '',
              description:  item['description']  ?? '',
              price:        (item['price']    as num?)?.toDouble() ?? 0.0,
              discount:     (item['discount'] as num?)?.toDouble() ?? 0.0,
              stock:        item['stock']        ?? 100,
              unit:         item['unit']         ?? 'piece',
              images:       List<String>.from(item['images'] ?? []),
              thumbnail:    item['thumbnail'],
              categoryId:   item['categoryId']   ?? '',
              categoryName: item['categoryName'],
              categoryIcon: item['categoryIcon'],
              isActive:     true,
              isFeatured:   item['isFeatured']   ?? false,
              rating:       (item['rating']      as num?)?.toDouble() ?? 0.0,
              reviewCount:  item['reviewCount']  ?? 0,
              tags:         List<String>.from(item['tags'] ?? []),
            );
          } catch (e) {
            return null;
          }
        }).whereType<ProductModel>().toList();
        notifyListeners();
      }
    } catch (e) {
      _items = [];
    }
  }

  Future<void> _saveLocal() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final list  = _items.map((p) => {
        'id':           p.id,
        'name':         p.name,
        'description':  p.description,
        'price':        p.price,
        'discount':     p.discount,
        'stock':        p.stock,
        'unit':         p.unit,
        'images':       p.images,
        'thumbnail':    p.thumbnail,
        'categoryId':   p.categoryId,
        'categoryName': p.categoryName,
        'categoryIcon': p.categoryIcon,
        'isFeatured':   p.isFeatured,
        'rating':       p.rating,
        'reviewCount':  p.reviewCount,
        'tags':         p.tags,
      }).toList();
      await prefs.setString(_key, jsonEncode(list));
    } catch (_) {}
  }

  bool isInWishlist(String productId) =>
      _items.any((p) => p.id == productId);

  Future<void> toggleWishlist(ProductModel product) async {
    if (isInWishlist(product.id)) {
      _items.removeWhere((p) => p.id == product.id);
      try { await _api.delete('${ApiConstants.wishlist}/${product.id}'); } catch (_) {}
    } else {
      _items.add(product);
      try { await _api.post('${ApiConstants.wishlist}/${product.id}', {}); } catch (_) {}
    }
    await _saveLocal();
    notifyListeners();
  }

  Future<void> removeFromWishlist(String productId) async {
    _items.removeWhere((p) => p.id == productId);
    try { await _api.delete('${ApiConstants.wishlist}/$productId'); } catch (_) {}
    await _saveLocal();
    notifyListeners();
  }

  Future<void> clearWishlist() async {
    _items.clear();
    for (final item in _items) {
      try { await _api.delete('${ApiConstants.wishlist}/${item.id}'); } catch (_) {}
    }
    await _saveLocal();
    notifyListeners();
  }
}

