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
        limit: 100,
        category: null,
        minPrice: null,
        maxPrice: null,
        sortBy: 'createdAt',
        sortOrder: 'DESC',
      );

      final newProducts = List<ProductModel>.from(result['products'] ?? []);

      if (newProducts.isNotEmpty) {
        _products = refresh ? newProducts : [..._products, ...newProducts];
        _currentPage++;
      }
    } catch (e) {
      debugPrint('PRODUCT LOAD ERROR: ');
    }

    if (_products.isEmpty) {
      _products = _demoProducts();
    }

    _isLoading = false;
    notifyListeners();
  }

  List<ProductModel> _demoProducts() {
    const base = 'https://kohli-store-api-4zh4.onrender.com/uploads/products/';
    return [
      ProductModel(id:'demo1', name:'Cerelac Wheat Cereal', description:'300 g', price:269, discount:6, stock:25, unit:'300 g', images:['cerelac-wheat-cereal-300-g.webp'], thumbnail:'cerelac-wheat-cereal-300-g.webp', categoryId:'17', categoryName:'Baby Care', isActive:true, isFeatured:true, rating:4.7, reviewCount:323, tags:const []),
      ProductModel(id:'demo2', name:'Pampers Active Baby Diapers', description:'Medium 20 pcs', price:365, discount:9, stock:25, unit:'Medium 20 pcs', images:['pampers-active-baby-diapers-medium-20-pcs.webp'], thumbnail:'pampers-active-baby-diapers-medium-20-pcs.webp', categoryId:'17', categoryName:'Baby Care', isActive:true, isFeatured:true, rating:4.8, reviewCount:182, tags:const []),
      ProductModel(id:'demo3', name:'Dabur Red Toothpaste', description:'200 g', price:110, discount:8, stock:50, unit:'200 g', images:['dabur-red-toothpaste-200-g.webp'], thumbnail:'dabur-red-toothpaste-200-g.webp', categoryId:'16', categoryName:'Personal Care', isActive:true, isFeatured:true, rating:4.2, reviewCount:224, tags:const []),
      ProductModel(id:'demo4', name:'Nivea Soft Light Moisturiser', description:'200 ml', price:365, discount:9, stock:30, unit:'200 ml', images:['nivea-soft-light-moisturiser-200-ml.webp'], thumbnail:'nivea-soft-light-moisturiser-200-ml.webp', categoryId:'16', categoryName:'Personal Care', isActive:true, isFeatured:true, rating:4.7, reviewCount:92, tags:const []),
      ProductModel(id:'demo5', name:'Head & Shoulders Anti Dandruff Shampoo', description:'340 ml', price:315, discount:6, stock:30, unit:'340 ml', images:['head-shoulders-anti-dandruff-shampoo-340-ml.webp'], thumbnail:'head-shoulders-anti-dandruff-shampoo-340-ml.webp', categoryId:'16', categoryName:'Personal Care', isActive:true, isFeatured:true, rating:4.8, reviewCount:211, tags:const []),
      ProductModel(id:'demo6', name:'Clinic Plus Strong & Long Shampoo', description:'340 ml', price:195, discount:7, stock:30, unit:'340 ml', images:['clinic-plus-strong-long-shampoo-340-ml.webp'], thumbnail:'clinic-plus-strong-long-shampoo-340-ml.webp', categoryId:'16', categoryName:'Personal Care', isActive:true, isFeatured:true, rating:4.2, reviewCount:180, tags:const []),
    ];
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



