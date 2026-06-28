import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/api_constants.dart';
import '../models/product_model.dart';
import '../models/cart_model.dart';
import '../services/api_service.dart';

class CartProvider extends ChangeNotifier {
  List<CartItemModel> _items = [];
  String? _couponCode;
  double  _couponDiscount = 0;
  DateTime? _deliveryDate;
  String?   _deliverySlot;

  static const String _storageKey = 'cart_items';

  List<CartItemModel> get items          => _items;
  int                 get itemCount      => _items.fold(0, (s, i) => s + i.quantity);
  double              get subtotal       => _items.fold(0.0, (s, i) => s + i.subtotal);
  double              get couponDiscount => _couponDiscount;
  String?             get couponCode     => _couponCode;
  double              get deliveryFee    => subtotal > 50 ? 0 : 5;
  double              get tax            => (subtotal - _couponDiscount) * 0.05;
  double              get totalAmount    => subtotal - _couponDiscount + deliveryFee + tax;
  DateTime?           get deliveryDate   => _deliveryDate;
  String?             get deliverySlot   => _deliverySlot;
  bool                get hasSchedule    => _deliverySlot != null;

  Future<void> loadCart() async {
    final prefs = await SharedPreferences.getInstance();
    final data  = prefs.getString(_storageKey);
    if (data == null) return;
    try {
      final list = jsonDecode(data) as List;
      _items = list.map((e) => CartItemModel.fromJson(e)).toList();
      notifyListeners();
    } catch (_) {
      _items = [];
    }
  }

  Future<void> _saveCart() async {
    final prefs = await SharedPreferences.getInstance();
    final data  = jsonEncode(_items.map((e) => e.toJson()).toList());
    await prefs.setString(_storageKey, data);
  }

  void addItem(ProductModel product) {
    final index = _items.indexWhere((i) => i.product.id == product.id);
    if (index >= 0) {
      if (_items[index].quantity >= product.stock) return;
      _items[index].quantity++;
    } else {
      if (!product.inStock) return;
      _items.add(CartItemModel(product: product));
    }
    notifyListeners();
    _saveCart();
  }

  void removeItem(String productId) {
    _items.removeWhere((i) => i.product.id == productId);
    notifyListeners();
    _saveCart();
  }

  void increaseQuantity(String productId) {
    final index = _items.indexWhere((i) => i.product.id == productId);
    if (index >= 0 && _items[index].quantity < _items[index].product.stock) {
      _items[index].quantity++;
      notifyListeners();
      _saveCart();
    }
  }

  void decreaseQuantity(String productId) {
    final index = _items.indexWhere((i) => i.product.id == productId);
    if (index >= 0) {
      if (_items[index].quantity > 1) {
        _items[index].quantity--;
      } else {
        _items.removeAt(index);
      }
      notifyListeners();
      _saveCart();
    }
  }

  void applyCoupon(String code, double discount) {
    _couponCode     = code;
    _couponDiscount = discount;
    notifyListeners();
  }

  void removeCoupon() {
    _couponCode     = null;
    _couponDiscount = 0;
    notifyListeners();
  }

  void setDeliverySlot(DateTime date, String slot) {
    _deliveryDate = date;
    _deliverySlot = slot;
    notifyListeners();
  }

  void clearDeliverySlot() {
    _deliveryDate = null;
    _deliverySlot = null;
    notifyListeners();
  }

  void clearCart() {
    _items.clear();
    _couponCode     = null;
    _couponDiscount = 0;
    _deliveryDate   = null;
    _deliverySlot   = null;
    notifyListeners();
    _saveCart();
  }

  /// Fetch latest prices from the server before checkout
  Future<void> refreshPrices() async {
    final api = ApiService();
    for (int i = 0; i < _items.length; i++) {
      try {
        final result = await api.get('${ApiConstants.products}/${_items[i].product.id}');
        if (result['success'] == true && result['data']?['product'] != null) {
          final updated = ProductModel.fromJson(result['data']['product']);
          _items[i] = CartItemModel(product: updated, quantity: _items[i].quantity);
        }
      } catch (_) {}
    }
    notifyListeners();
    _saveCart();
  }

  bool isInCart(String productId) =>
      _items.any((i) => i.product.id == productId);

  int getQuantity(String productId) {
    final index = _items.indexWhere((i) => i.product.id == productId);
    return index >= 0 ? _items[index].quantity : 0;
  }
}
