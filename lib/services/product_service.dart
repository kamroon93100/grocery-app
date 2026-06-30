import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/product_model.dart';
import '../models/category_model.dart';
import '../constants/api_constants.dart';

class ProductService {
  static final ProductService _instance = ProductService._internal();
  factory ProductService() => _instance;
  ProductService._internal();

  List _items(dynamic body) {
    if (body is List) return body;
    if (body is Map && body['items'] is List) return body['items'];
    if (body is Map && body['products'] is List) return body['products'];
    if (body is Map && body['data'] is List) return body['data'];
    if (body is Map && body['data'] is Map && body['data']['items'] is List) return body['data']['items'];
    return [];
  }

  Future<List<CategoryModel>> getCategories() async {
    final res = await http.get(Uri.parse('${ApiConstants.baseUrl}${ApiConstants.categories}'));
    final body = jsonDecode(res.body);
    final list = _items(body);
    return list.map((c) => CategoryModel.fromJson(Map<String, dynamic>.from(c))).toList();
  }

  Future<Map<String, dynamic>> getProducts({
    int page = 1,
    int limit = 20,
    String? category,
    String? search,
    double? minPrice,
    double? maxPrice,
    String sortBy = 'createdAt',
    String sortOrder = 'DESC',
  }) async {
    final uri = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.products}').replace(
      queryParameters: {
        'page': page.toString(),
        'limit': '100',
      },
    );

    final res = await http.get(uri);
    final body = jsonDecode(res.body);
    final list = _items(body);

    final products = list
        .whereType<Map>()
        .map((p) => ProductModel.fromJson(Map<String, dynamic>.from(p)))
        .toList();

    return {
      'products': products,
      'pagination': body is Map ? body : null,
    };
  }

  Future<List<ProductModel>> getFeaturedProducts() async {
    final result = await getProducts(limit: 20);
    return List<ProductModel>.from(result['products'] ?? []);
  }

  Future<Map<String, dynamic>> searchProducts(String query, {int page = 1}) async {
    final result = await getProducts(page: page, limit: 100);
    final products = List<ProductModel>.from(result['products'] ?? [])
        .where((p) => p.name.toLowerCase().contains(query.toLowerCase()))
        .toList();
    return {'products': products, 'pagination': null};
  }

  Future<ProductModel?> getProductById(String id) async {
    final result = await getProducts(limit: 100);
    final products = List<ProductModel>.from(result['products'] ?? []);
    try {
      return products.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<Map<String, dynamic>> addReview(String productId, int rating, String comment) async {
    return {'success': false, 'message': 'Reviews not connected yet'};
  }
}


