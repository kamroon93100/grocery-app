import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/product_provider.dart';
import '../../widgets/premium_category_section.dart';

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});
  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final product = context.read<ProductProvider>();
      if (product.categories.isEmpty) {
        product.loadCategories();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final product = context.watch<ProductProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // Header
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Categories',
                      style: TextStyle(
                        fontSize:   24,
                        fontWeight: FontWeight.w800,
                        color:      Color(0xFF101828),
                        letterSpacing: -0.3)),
                    IconButton(
                      icon: const Icon(Icons.search,
                        color: Color(0xFF101828), size: 26),
                      onPressed: () {},
                    ),
                  ],
                ),
              ),
            ),

            // Categories
            SliverToBoxAdapter(
              child: product.categories.isEmpty
                  ? const Center(
                      child: Padding(
                        padding: EdgeInsets.all(40),
                        child: CircularProgressIndicator(
                          color: Color(0xFF12B76A))))
                  : PremiumCategorySection(
                      categories: product.categories),
            ),

            // Bottom padding
            const SliverToBoxAdapter(
              child: SizedBox(height: 100)),
          ],
        ),
      ),
    );
  }
}
