import '../models/product_model.dart';
import '../models/category_model.dart';
import 'api_service.dart';
import '../constants/api_constants.dart';

class ProductService {
  static final ProductService _instance = ProductService._internal();
  factory ProductService() => _instance;
  ProductService._internal();

  final ApiService _api = ApiService();

  Future<List<CategoryModel>> getCategories() async {
    final result = await _api.get(ApiConstants.categories, auth: false);
    if (result['success'] == true) {
      final list = result['data']['categories'] as List;
      return list.map((c) => CategoryModel.fromJson(c)).toList();
    }
    return [];
  }

  Future<Map<String, dynamic>> getProducts({
    int    page     = 1,
    int    limit    = 20,
    String? category,
    String? search,
    double? minPrice,
    double? maxPrice,
    String  sortBy  = 'createdAt',
    String  sortOrder = 'DESC',
  }) async {
    final params = <String, String>{
      'page':  page.toString(),
      'limit': limit.toString(),
    };
    if (category  != null) params['category']  = category;
    if (search    != null) params['search']     = search;
    if (minPrice  != null) params['minPrice']   = minPrice.toString();
    if (maxPrice  != null) params['maxPrice']   = maxPrice.toString();
    params['sortBy']    = sortBy;
    params['sortOrder'] = sortOrder;

    final result = await _api.get(
      ApiConstants.products,
      queryParams: params,
      auth: false,
    );

    if (result['success'] == true) {
      final list = result['data'] as List;
      return {
        'products':   list.map((p) => ProductModel.fromJson(p)).toList(),
        'pagination': result['pagination'],
      };
    }
    return {'products': [], 'pagination': null};
  }

  Future<List<ProductModel>> getFeaturedProducts() async {
    final result = await _api.get(ApiConstants.featured, auth: false);
    if (result['success'] == true) {
      final list = result['data']['products'] as List;
      return list.map((p) => ProductModel.fromJson(p)).toList();
    }
    return [];
  }

  Future<Map<String, dynamic>> searchProducts(String query, {int page = 1}) async {
    final result = await _api.get(
      ApiConstants.search,
      queryParams: {'q': query, 'page': page.toString()},
      auth: false,
    );
    if (result['success'] == true) {
      final list = result['data'] as List;
      return {
        'products':   list.map((p) => ProductModel.fromJson(p)).toList(),
        'pagination': result['pagination'],
      };
    }
    return {'products': [], 'pagination': null};
  }

  Future<ProductModel?> getProductById(String id) async {
    final result = await _api.get('${ApiConstants.products}/$id', auth: false);
    if (result['success'] == true) {
      return ProductModel.fromJson(result['data']['product']);
    }
    return null;
  }

  Future<Map<String, dynamic>> addReview(
    String productId,
    int rating,
    String comment,
  ) async {
    return await _api.post(
      '${ApiConstants.products}/$productId/reviews',
      {'rating': rating, 'comment': comment},
    );
  }
}
