import 'package:flutter/material.dart';
import '../models/product_model.dart';
import '../models/category_model.dart';
import '../services/product_service.dart';

class ProductProvider extends ChangeNotifier {
  final ProductService _service = ProductService();

  List<ProductModel> _products = [];
  List<ProductModel> _featuredProducts = [];
  List<CategoryModel> _categories = [];
  List<ProductModel> _searchResults = [];

  bool _isLoading = false;
  bool _isSearching = false;
  String? _error;
  String _selectedCategory = 'All';
  int _currentPage = 1;
  bool _hasMore = true;

  double _minPrice = 0;
  double _maxPrice = 100000;
  String _sortBy = 'createdAt_DESC';

  List<ProductModel> get products => _products;
  List<ProductModel> get featuredProducts => _featuredProducts;
  List<CategoryModel> get categories => _categories;
  List<ProductModel> get searchResults => _searchResults;
  bool get isLoading => _isLoading;
  bool get isSearching => _isSearching;
  String? get error => _error;
  String get selectedCategory => _selectedCategory;
  bool get hasMore => _hasMore;
  double get minPrice => _minPrice;
  double get maxPrice => _maxPrice;
  String get sortBy => _sortBy;
  bool get hasActiveFilters => _minPrice > 0 || _sortBy != 'createdAt_DESC';

  Future<void> loadCategories() async {
    try {
      _categories = await _service.getCategories();
    } catch (e) {
      debugPrint('CATEGORY LOAD ERROR: $e');
    }
    notifyListeners();
  }

  Future<void> loadProducts({bool refresh = false}) async {
    if (refresh) {
      _currentPage = 1;
      _hasMore = true;
      _products = [];
    }

    if (_isLoading) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await _service.getProducts(
        page: _currentPage,
        limit: 20,
        category: null,
        minPrice: null,
        maxPrice: null,
        sortBy: 'createdAt',
        sortOrder: 'DESC',
      );

      final newProducts = List<ProductModel>.from(result['products'] ?? []);
      final pagination = result['pagination'];

      debugPrint('PRODUCT LOAD COUNT: ${newProducts.length}');
      debugPrint('PRODUCT PAGINATION: $pagination');

      _products = refresh ? newProducts : [..._products, ...newProducts];
      _currentPage++;
      _hasMore = pagination is Map
          ? (pagination['hasNext'] == true || pagination['hasNextPage'] == true)
          : false;
    } catch (e) {
      _error = 'Failed to load products: $e';
      debugPrint(_error);
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> loadFeaturedProducts() async {
    try {
      _featuredProducts = await _service.getFeaturedProducts();
    } catch (e) {
      debugPrint('FEATURED LOAD ERROR: $e');
    }
    notifyListeners();
  }

  Future<void> searchProducts(String query) async {
    if (query.isEmpty) {
      _searchResults = [];
      notifyListeners();
      return;
    }

    _isSearching = true;
    notifyListeners();

    try {
      final result = await _service.searchProducts(query);
      _searchResults = List<ProductModel>.from(result['products'] ?? []);
    } catch (e) {
      debugPrint('SEARCH ERROR: $e');
      _searchResults = [];
    }

    _isSearching = false;
    notifyListeners();
  }

  void selectCategory(String category) {
    _selectedCategory = category;
    loadProducts(refresh: true);
  }

  void applyFilters(double minPrice, double maxPrice, String sortBy) {
    _minPrice = minPrice;
    _maxPrice = maxPrice;
    _sortBy = sortBy;
    loadProducts(refresh: true);
  }

  void resetFilters() {
    _minPrice = 0;
    _maxPrice = 100000;
    _sortBy = 'createdAt_DESC';
    loadProducts(refresh: true);
  }

  void clearSearch() {
    _searchResults = [];
    notifyListeners();
  }
}


