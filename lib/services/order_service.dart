import '../models/order_model.dart';
import '../models/cart_model.dart';
import 'api_service.dart';
import '../constants/api_constants.dart';

class OrderService {
  static final OrderService _instance = OrderService._internal();
  factory OrderService() => _instance;
  OrderService._internal();

  final ApiService _api = ApiService();

  Future<Map<String, dynamic>> placeOrder({
    required List<CartItemModel> items,
    required Map<String, dynamic> deliveryAddress,
    required String paymentMethod,
    String? couponCode,
    String? notes,
  }) async {
    final orderItems = items.map((item) => {
      'productId': item.product.id,
      'quantity':  item.quantity,
    }).toList();

    final body = <String, dynamic>{
      'items':           orderItems,
      'deliveryAddress': deliveryAddress,
      'paymentMethod':   paymentMethod,
    };
    if (couponCode != null) body['couponCode'] = couponCode;
    if (notes      != null) body['notes']      = notes;

    return await _api.post(ApiConstants.orders, body);
  }

  Future<Map<String, dynamic>> getMyOrders({
    int     page   = 1,
    int     limit  = 10,
    String? status,
  }) async {
    final params = <String, String>{
      'page':  page.toString(),
      'limit': limit.toString(),
    };
    if (status != null) params['status'] = status;

    final result = await _api.get(
      ApiConstants.myOrders,
      queryParams: params,
    );
    if (result['success'] == true) {
      final list = result['data'] as List;
      return {
        'orders':     list.map((o) => OrderModel.fromJson(o)).toList(),
        'pagination': result['pagination'],
      };
    }
    return {'orders': [], 'pagination': null};
  }

  Future<OrderModel?> getOrderById(String id) async {
    final result = await _api.get('${ApiConstants.orders}/$id');
    if (result['success'] == true) {
      return OrderModel.fromJson(result['data']['order']);
    }
    return null;
  }

  Future<Map<String, dynamic>> cancelOrder(String id, String reason) async {
    return await _api.post(
      '${ApiConstants.orders}/$id/cancel',
      {'reason': reason},
    );
  }

  Future<Map<String, dynamic>> validateCoupon(
    String code, double orderAmount) async {
    return await _api.post(ApiConstants.validateCoupon, {
      'code':        code,
      'orderAmount': orderAmount,
    });
  }
}
