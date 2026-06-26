import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/cart_provider.dart';
import '../../providers/product_provider.dart';
import '../../models/product_model.dart';
import '../../widgets/home_banners.dart';
import '../../widgets/search_filter_sheet.dart';
import '../cart/cart_screen.dart';
import '../orders/orders_screen.dart';
import '../profile/profile_screen.dart';
import '../admin/admin_screen.dart';
import '../product/product_detail_screen.dart';
import '../../constants/app_constants.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int    _currentIndex  = 0;
  final  _searchCtrl    = TextEditingController();

  @override
  void dispose() { _searchCtrl.dispose(); super.dispose(); }

  void _showFilters() {
    final p = context.read<ProductProvider>();
    showModalBottomSheet(
      context:            context,
      isScrollControlled: true,
      backgroundColor:    Colors.transparent,
      builder: (_) => SearchFilterBottomSheet(
        minPrice: p.minPrice,
        maxPrice: p.maxPrice,
        sortBy:   p.sortBy,
        onApply: (min, max, sort) =>
            context.read<ProductProvider>().applyFilters(min, max, sort),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth    = context.watch<AuthProvider>();
    final cart    = context.watch<CartProvider>();
    final product = context.watch<ProductProvider>();

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text(AppConstants.storeName,
          style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          if (auth.isAdmin)
            IconButton(
              icon:    const Icon(Icons.admin_panel_settings),
              tooltip: 'Admin Panel',
              onPressed: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const AdminScreen())),
            ),
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.shopping_cart_outlined, size: 28),
                onPressed: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const CartScreen())),
              ),
              if (cart.itemCount > 0)
                Positioned(
                  right: 4, top: 4,
                  child: CircleAvatar(
                    radius:          9,
                    backgroundColor: Colors.red,
                    child: Text('${cart.itemCount}',
                      style: const TextStyle(
                        fontSize: 10, color: Colors.white,
                        fontWeight: FontWeight.bold)),
                  ),
                ),
            ],
          ),
        ],
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: [
          _buildShopPage(product, cart),
          const OrdersScreen(),
          const ProfileScreen(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex:        _currentIndex,
        selectedItemColor:   Colors.green,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        onTap: (i) => setState(() => _currentIndex = i),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.store_outlined),
            activeIcon: Icon(Icons.store), label: 'Shop'),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long_outlined),
            activeIcon: Icon(Icons.receipt_long), label: 'Orders'),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }

  Widget _buildShopPage(ProductProvider product, CartProvider cart) {
    return CustomScrollView(
      slivers: [
        // Search Bar
        SliverToBoxAdapter(
          child: Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchCtrl,
                    onChanged:  (val) =>
                        context.read<ProductProvider>().searchProducts(val),
                    decoration: InputDecoration(
                      hintText:  'Search groceries...',
                      prefixIcon: const Icon(Icons.search, color: Colors.green),
                      suffixIcon: _searchCtrl.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                _searchCtrl.clear();
                                context.read<ProductProvider>().clearSearch();
                              })
                          : null,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide:   BorderSide.none),
                      filled:    true,
                      fillColor: Colors.grey.shade100,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  decoration: BoxDecoration(
                    color: product.hasActiveFilters
                        ? Colors.green : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12)),
                  child: IconButton(
                    icon: Icon(Icons.tune,
                      color: product.hasActiveFilters
                          ? Colors.white : Colors.green),
                    onPressed: _showFilters,
                  ),
                ),
              ],
            ),
          ),
        ),

        // Banners (only show when not searching)
        if (_searchCtrl.text.isEmpty)
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: HomeBanners(),
            ),
          ),

        // Categories
        if (product.categories.isNotEmpty && _searchCtrl.text.isEmpty)
          SliverToBoxAdapter(
            child: Container(
              color:  Colors.white,
              height: 50,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                itemCount: product.categories.length + 1,
                itemBuilder: (context, index) {
                  final isAll      = index == 0;
                  final cat        = isAll ? null : product.categories[index - 1];
                  final catName    = isAll ? 'All' : cat!.name;
                  final isSelected = product.selectedCategory == catName;
                  return GestureDetector(
                    onTap: () =>
                        context.read<ProductProvider>().selectCategory(catName),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin:   const EdgeInsets.only(right: 8),
                      padding:  const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                      decoration: BoxDecoration(
                        color:        isSelected ? Colors.green : Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected ? Colors.green : Colors.grey.shade300),
                      ),
                      child: Text(
                        isAll ? '🛒 All' : '${cat!.icon} ${cat.name}',
                        style: TextStyle(
                          color:      isSelected ? Colors.white : Colors.grey.shade700,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          fontSize:   13,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

        // Active filters badge
        if (product.hasActiveFilters && _searchCtrl.text.isEmpty)
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.all(8),
              color: Colors.green.shade50,
              child: Row(
                children: [
                  const Icon(Icons.filter_list, color: Colors.green, size: 16),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Filters active: \$${product.minPrice.toInt()}-\$${product.maxPrice.toInt()} | ${product.sortBy.replaceAll('_', ' ')}',
                      style: const TextStyle(color: Colors.green, fontSize: 12)),
                  ),
                  TextButton(
                    onPressed: () => context.read<ProductProvider>().resetFilters(),
                    child: const Text('Clear',
                      style: TextStyle(color: Colors.red, fontSize: 12)),
                  ),
                ],
              ),
            ),
          ),

        // Title
        if (_searchCtrl.text.isEmpty)
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(12),
              child: Text('All Products',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
          ),

        // Products grid
        _searchCtrl.text.isNotEmpty
            ? _buildSearchResults(product, cart)
            : _buildProductGrid(product, cart),
      ],
    );
  }

  Widget _buildSearchResults(ProductProvider product, CartProvider cart) {
    if (product.isSearching) {
      return const SliverFillRemaining(
        child: Center(child: CircularProgressIndicator(color: Colors.green)));
    }
    if (product.searchResults.isEmpty) {
      return SliverFillRemaining(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.search_off, size: 60, color: Colors.grey.shade400),
              const SizedBox(height: 12),
              Text('No results found',
                style: TextStyle(color: Colors.grey.shade500, fontSize: 16)),
            ],
          ),
        ),
      );
    }
    return SliverPadding(
      padding: const EdgeInsets.all(12),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2, childAspectRatio: 0.75,
          crossAxisSpacing: 12, mainAxisSpacing: 12,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) => _productCard(product.searchResults[index], cart),
          childCount: product.searchResults.length,
        ),
      ),
    );
  }

  Widget _buildProductGrid(ProductProvider product, CartProvider cart) {
    if (product.products.isEmpty && !product.isLoading) {
      return SliverFillRemaining(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.store_outlined, size: 60, color: Colors.grey.shade400),
              const SizedBox(height: 12),
              Text('No products found',
                style: TextStyle(color: Colors.grey.shade500, fontSize: 16)),
              TextButton(
                onPressed: () =>
                    context.read<ProductProvider>().loadProducts(refresh: true),
                child: const Text('Refresh')),
            ],
          ),
        ),
      );
    }
    return SliverPadding(
      padding: const EdgeInsets.all(12),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2, childAspectRatio: 0.75,
          crossAxisSpacing: 12, mainAxisSpacing: 12,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            if (index == product.products.length) {
              context.read<ProductProvider>().loadProducts();
              return const Center(child: CircularProgressIndicator(color: Colors.green));
            }
            return _productCard(product.products[index], cart);
          },
          childCount: product.products.length + (product.hasMore ? 1 : 0),
        ),
      ),
    );
  }

  Widget _productCard(ProductModel p, CartProvider cart) {
    return GestureDetector(
      onTap: () => Navigator.push(context,
        MaterialPageRoute(builder: (_) => ProductDetailScreen(product: p))),
      child: _buildProductCard(p, cart),
    );
  }

  Widget _buildProductCard(ProductModel p, CartProvider cart) {
    final inCart = cart.isInCart(p.id);
    final qty    = cart.getQuantity(p.id);
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Stack(
              children: [
                Center(child: Text(p.displayImage,
                  style: const TextStyle(fontSize: 52))),
                if (p.hasDiscount)
                  Positioned(
                    top: 0, right: 0,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(8)),
                      child: Text('${p.discount.toInt()}%',
                        style: const TextStyle(
                          color: Colors.white, fontSize: 10,
                          fontWeight: FontWeight.bold)),
                    ),
                  ),
              ],
            ),
            Column(
              children: [
                Text(p.name,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  textAlign: TextAlign.center, maxLines: 1,
                  overflow: TextOverflow.ellipsis),
                Text(p.categoryName ?? '',
                  style: TextStyle(color: Colors.grey.shade500, fontSize: 11)),
                const SizedBox(height: 4),
                if (p.hasDiscount)
                  Text('\$${p.price.toStringAsFixed(2)}',
                    style: const TextStyle(color: Colors.grey, fontSize: 11,
                      decoration: TextDecoration.lineThrough)),
                Text('\$${p.finalPrice.toStringAsFixed(2)}',
                  style: const TextStyle(color: Colors.green, fontSize: 16,
                    fontWeight: FontWeight.bold)),
              ],
            ),
            inCart
                ? Container(
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.green),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.remove, color: Colors.green, size: 18),
                          onPressed: () => context.read<CartProvider>().decreaseQuantity(p.id),
                          constraints: const BoxConstraints(minWidth: 30, minHeight: 30),
                          padding: EdgeInsets.zero,
                        ),
                        Text('$qty',
                          style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
                        IconButton(
                          icon: const Icon(Icons.add, color: Colors.green, size: 18),
                          onPressed: () => context.read<CartProvider>().increaseQuantity(p.id),
                          constraints: const BoxConstraints(minWidth: 30, minHeight: 30),
                          padding: EdgeInsets.zero,
                        ),
                      ],
                    ),
                  )
                : SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => context.read<CartProvider>().addItem(p),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 8)),
                      child: const Text('Add',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}


