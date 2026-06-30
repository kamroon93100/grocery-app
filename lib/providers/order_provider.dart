import 'package:flutter/material.dart';
import '../models/order_model.dart';
import '../models/cart_model.dart';
import '../services/order_service.dart';

class OrderProvider extends ChangeNotifier {
  final OrderService _service = OrderService();

  List<OrderModel> _orders    = [];
  bool             _isLoading = false;
  String?          _error;

  List<OrderModel> get orders    => _orders;
  bool             get isLoading => _isLoading;
  String?          get error     => _error;

  Future<void> loadMyOrders({String? status}) async {
    _isLoading = true;
    _error     = null;
    notifyListeners();

    try {
      final result = await _service.getMyOrders(status: status);
      _orders = result['orders'] as List<OrderModel>;
    } catch (e) {
      _error = e.toString();
      _orders = [];
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<Map<String, dynamic>> placeOrder({
    required List<CartItemModel>  items,
    required Map<String, dynamic> deliveryAddress,
    required String               paymentMethod,
    String?                       couponCode,
    String?                       notes,
  }) async {
    _isLoading = true;
    notifyListeners();

    final result = await _service.placeOrder(
      items:           items,
      deliveryAddress: deliveryAddress,
      paymentMethod:   paymentMethod,
      couponCode:      couponCode,
      notes:           notes,
    );

    _isLoading = false;
    if (result['success'] == true) {
      await loadMyOrders();
    }
    notifyListeners();
    return result;
  }

  Future<Map<String, dynamic>> cancelOrder(String id, String reason) async {
    final result = await _service.cancelOrder(id, reason);
    if (result['success'] == true) {
      await loadMyOrders();
    }
    return result;
  }
}



