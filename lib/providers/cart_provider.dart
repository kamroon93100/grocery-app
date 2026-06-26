import 'package:flutter/material.dart';
import '../models/product_model.dart';
import '../models/cart_model.dart';

class CartProvider extends ChangeNotifier {
  final List<CartItemModel> _items = [];
  String? _couponCode;
  double  _couponDiscount = 0;

  List<CartItemModel> get items          => _items;
  int                 get itemCount      => _items.fold(0, (s, i) => s + i.quantity);
  double              get subtotal       => _items.fold(0.0, (s, i) => s + i.subtotal);
  double              get couponDiscount => _couponDiscount;
  String?             get couponCode     => _couponCode;
  double              get deliveryFee    => subtotal > 50 ? 0 : 5;
  double              get tax            => (subtotal - _couponDiscount) * 0.05;
  double              get totalAmount    => subtotal - _couponDiscount + deliveryFee + tax;

  void addItem(ProductModel product) {
    final index = _items.indexWhere((i) => i.product.id == product.id);
    if (index >= 0) {
      _items[index].quantity++;
    } else {
      _items.add(CartItemModel(product: product));
    }
    notifyListeners();
  }

  void removeItem(String productId) {
    _items.removeWhere((i) => i.product.id == productId);
    notifyListeners();
  }

  void increaseQuantity(String productId) {
    final index = _items.indexWhere((i) => i.product.id == productId);
    if (index >= 0) { _items[index].quantity++; notifyListeners(); }
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

  void clearCart() {
    _items.clear();
    _couponCode     = null;
    _couponDiscount = 0;
    notifyListeners();
  }

  bool isInCart(String productId) =>
      _items.any((i) => i.product.id == productId);

  int getQuantity(String productId) {
    final index = _items.indexWhere((i) => i.product.id == productId);
    return index >= 0 ? _items[index].quantity : 0;
  }
}
