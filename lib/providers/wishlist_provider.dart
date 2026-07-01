import 'package:flutter/material.dart';
import '../models/product_model.dart';

class WishlistProvider extends ChangeNotifier {
  final List<ProductModel> _items = [];

  List<ProductModel> get items => List.unmodifiable(_items);
  int get count => _items.length;

  Future<void> loadWishlist() async {
    notifyListeners();
  }

  bool contains(String productId) => _items.any((p) => p.id == productId);

  void toggle(ProductModel product) {
    if (contains(product.id)) {
      _items.removeWhere((p) => p.id == product.id);
    } else {
      _items.insert(0, product);
    }
    notifyListeners();
  }

  Future<void> removeFromWishlist(String productId) async {
    _items.removeWhere((p) => p.id == productId);
    notifyListeners();
  }

  Future<void> clearWishlist() async {
    _items.clear();
    notifyListeners();
  }

  void remove(String productId) {
    _items.removeWhere((p) => p.id == productId);
    notifyListeners();
  }

  void clear() {
    _items.clear();
    notifyListeners();
  }
}
