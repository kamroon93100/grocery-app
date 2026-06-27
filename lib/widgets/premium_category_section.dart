import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/category_model.dart';
import '../providers/product_provider.dart';
import '../main.dart';

/// ═══════════════════════════════════════════════════════
/// PREMIUM CATEGORY SECTION
/// Pixel-perfect Instamart-style grouped categories
/// ═══════════════════════════════════════════════════════

class PremiumCategorySection extends StatelessWidget {
  final List<CategoryModel> categories;

  const PremiumCategorySection({super.key, required this.categories});

  // Group categories into 3 sections like Instamart
  Map<String, List<CategoryModel>> get _sections {
    final fresh    = <CategoryModel>[];
    final grocery  = <CategoryModel>[];
    final snacks   = <CategoryModel>[];

    for (final cat in categories) {
      final name = cat.name.toLowerCase();
      if (name.contains('veg') || name.contains('fruit') ||
          name.contains('dairy') || name.contains('meat') ||
          name.contains('fresh')) {
        fresh.add(cat);
      } else if (name.contains('grain') || name.contains('rice') ||
                 name.contains('bakery') || name.contains('bread') ||
                 name.contains('cereal')) {
        grocery.add(cat);
      } else {
        snacks.add(cat);
      }
    }

    return {
      if (fresh.isNotEmpty)    'Fresh Items':       fresh,
      if (grocery.isNotEmpty)  'Grocery & Kitchen': grocery,
      if (snacks.isNotEmpty)   'Snacks & Drinks':   snacks,
    };
  }

  // Premium pastel palette (each tile gets unique color)
  static const List<List<Color>> tilePalettes = [
    [Color(0xFFE7F8EF), Color(0xFFC8E6D0)],  // Mint
    [Color(0xFFFFF4E6), Color(0xFFFFE0B2)],  // Peach
    [Color(0xFFE3F2FD), Color(0xFFBBDEFB)],  // Sky
    [Color(0xFFFCE4EC), Color(0xFFF8BBD0)],  // Pink
    [Color(0xFFF3E5F5), Color(0xFFE1BEE7)],  // Purple
    [Color(0xFFFFF9C4), Color(0xFFFFF59D)],  // Yellow
    [Color(0xFFE0F7FA), Color(0xFFB2EBF2)],  // Cyan
    [Color(0xFFFFE0E0), Color(0xFFFFCDD2)],  // Coral
  ];

  @override
  Widget build(BuildContext context) {
    final sections = _sections;
    int colorIndex = 0;

    return Column(
      children: sections.entries.map((entry) {
        final widget = _CategorySection(
          title:      entry.key,
          categories: entry.value,
          startColorIndex: colorIndex,
        );
        colorIndex += entry.value.length;
        return widget;
      }).toList(),
    );
  }
}

class _CategorySection extends StatelessWidget {
  final String              title;
  final List<CategoryModel> categories;
  final int                 startColorIndex;

  const _CategorySection({
    required this.title,
    required this.categories,
    required this.startColorIndex,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.only(top: 24, bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section title
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Text(
              title,
              style: const TextStyle(
                fontSize:   20,
                fontWeight: FontWeight.w800,
                color:      Color(0xFF101828),
                letterSpacing: -0.3,
              ),
            ),
          ),

          // Grid of categories (4 per row)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                childAspectRatio: 0.78,
                crossAxisSpacing: 4,
                mainAxisSpacing: 12,
              ),
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final cat = categories[index];
                final palette = PremiumCategorySection.tilePalettes[
                  (startColorIndex + index) %
                    PremiumCategorySection.tilePalettes.length];

                return _CategoryTile(
                  category: cat,
                  bgColor:  palette[0],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryTile extends StatefulWidget {
  final CategoryModel category;
  final Color         bgColor;

  const _CategoryTile({
    required this.category,
    required this.bgColor,
  });

  @override
  State<_CategoryTile> createState() => _CategoryTileState();
}

class _CategoryTileState extends State<_CategoryTile>
    with SingleTickerProviderStateMixin {

  late AnimationController _ctrl;
  late Animation<double>   _scale;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scale = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  bool get _hasNetworkImage =>
      widget.category.image != null &&
      widget.category.image!.startsWith('http');

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown:   (_) { _ctrl.forward();  setState(() => _isPressed = true); },
      onTapUp:     (_) { _ctrl.reverse();  setState(() => _isPressed = false); },
      onTapCancel: ()  { _ctrl.reverse();  setState(() => _isPressed = false); },
      onTap: () => context.read<ProductProvider>().selectCategory(widget.category.name),
      child: ScaleTransition(
        scale: _scale,
        child: Column(
          children: [
            // Image tile - exact 80x80 with bg color
            AspectRatio(
              aspectRatio: 1,
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  color: widget.bgColor,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: _hasNetworkImage
                      ? CachedNetworkImage(
                          imageUrl: widget.category.image!,
                          fit: BoxFit.contain,
                          placeholder: (_, __) =>
                            Center(child: Text(widget.category.icon,
                              style: const TextStyle(fontSize: 28))),
                          errorWidget: (_, __, ___) =>
                            Center(child: Text(widget.category.icon,
                              style: const TextStyle(fontSize: 28))),
                        )
                      : Center(
                          child: Text(
                            widget.category.icon,
                            style: const TextStyle(fontSize: 32),
                          ),
                        ),
                ),
              ),
            ),

            // Label
            Padding(
              padding: const EdgeInsets.only(top: 8, left: 2, right: 2),
              child: Text(
                widget.category.name,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF101828),
                  height: 1.25,
                  letterSpacing: -0.1,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
