import 'package:flutter/material.dart';
import '../models/product_model.dart';
import '../models/category_model.dart';
import '../services/product_service.dart';

class ProductProvider extends ChangeNotifier {
  final ProductService _service = ProductService();

  List<ProductModel>   _products          = [];
  List<ProductModel>   _featuredProducts  = [];
  List<CategoryModel>  _categories        = [];
  List<ProductModel>   _searchResults     = [];
  bool                 _isLoading         = false;
  bool                 _isSearching       = false;
  String?              _error;
  String               _selectedCategory  = 'All';
  int                  _currentPage       = 1;
  bool                 _hasMore           = true;

  // Filter options
  double  _minPrice   = 0;
  double  _maxPrice   = 50;
  String  _sortBy     = 'createdAt_DESC';

  List<ProductModel>  get products         => _products;
  List<ProductModel>  get featuredProducts => _featuredProducts;
  List<CategoryModel> get categories       => _categories;
  List<ProductModel>  get searchResults    => _searchResults;
  bool                get isLoading        => _isLoading;
  bool                get isSearching      => _isSearching;
  String?             get error            => _error;
  String              get selectedCategory => _selectedCategory;
  bool                get hasMore          => _hasMore;
  double              get minPrice         => _minPrice;
  double              get maxPrice         => _maxPrice;
  String              get sortBy           => _sortBy;
  bool get hasActiveFilters =>
      _minPrice > 0 || _maxPrice < 50 || _sortBy != 'createdAt_DESC';

  Future<void> loadCategories() async {
    _categories = await _service.getCategories();
    notifyListeners();
  }

  Future<void> loadProducts({bool refresh = false}) async {
    if (refresh) {
      _currentPage = 1;
      _hasMore     = true;
      _products    = [];
    }
    if (!_hasMore || _isLoading) return;

    _isLoading = true;
    _error     = null;
    notifyListeners();

    String? categoryId;
    if (_selectedCategory != 'All') {
      final cat = _categories.firstWhere(
        (c) => c.name == _selectedCategory,
        orElse: () => CategoryModel(
          id: '', name: '', description: '',
          icon: '', isActive: true, sortOrder: 0,
        ),
      );
      categoryId = cat.id.isNotEmpty ? cat.id : null;
    }

    final sortParts  = _sortBy.split('_');
    final sortField  = sortParts[0];
    final sortOrder  = sortParts.length > 1 ? sortParts[1] : 'DESC';

    final result = await _service.getProducts(
      page:      _currentPage,
      category:  categoryId,
      minPrice:  _minPrice > 0 ? _minPrice : null,
      maxPrice:  _maxPrice < 50 ? _maxPrice : null,
      sortBy:    sortField,
      sortOrder: sortOrder,
    );

    final newProducts = result['products'] as List<ProductModel>;
    final pagination  = result['pagination'];

    _products.addAll(newProducts);
    _currentPage++;
    _hasMore   = pagination != null && pagination['hasNext'] == true;
    _isLoading = false;
    notifyListeners();
  }

  Future<void> loadFeaturedProducts() async {
    _featuredProducts = await _service.getFeaturedProducts();
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
    final result   = await _service.searchProducts(query);
    _searchResults = result['products'] as List<ProductModel>;
    _isSearching   = false;
    notifyListeners();
  }

  void selectCategory(String category) {
    if (_selectedCategory == category) return;
    _selectedCategory = category;
    _currentPage      = 1;
    _hasMore          = true;
    _products         = [];
    notifyListeners();
    loadProducts(refresh: true);
  }

  void applyFilters(double minPrice, double maxPrice, String sortBy) {
    _minPrice = minPrice;
    _maxPrice = maxPrice;
    _sortBy   = sortBy;
    loadProducts(refresh: true);
  }

  void resetFilters() {
    _minPrice = 0;
    _maxPrice = 50;
    _sortBy   = 'createdAt_DESC';
    loadProducts(refresh: true);
  }

  void clearSearch() {
    _searchResults = [];
    notifyListeners();
  }
}
