import '../models/review_model.dart';
import '../constants/api_constants.dart';
import 'api_service.dart';

class ReviewService {
  static final ReviewService _instance = ReviewService._internal();
  factory ReviewService() => _instance;
  ReviewService._internal();

  final ApiService _api = ApiService();

  Future<List<ReviewModel>> getProductReviews(String productId,
    {int page = 1}) async {
    final result = await _api.get(
      '${ApiConstants.products}/$productId/reviews',
      queryParams: {'page': page.toString(), 'limit': '20'},
      auth:        false,
    );
    if (result['success'] == true) {
      final list = result['data'] as List;
      return list.map((r) => ReviewModel.fromJson(r)).toList();
    }
    return [];
  }

  Future<Map<String, dynamic>> addReview(
    String productId, int rating, String comment) async {
    return await _api.post(
      '${ApiConstants.products}/$productId/reviews',
      {'rating': rating, 'comment': comment},
    );
  }
}

