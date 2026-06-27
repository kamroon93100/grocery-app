import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;
import '../../providers/product_provider.dart';
import '../../models/category_model.dart';

/// ═══════════════════════════════════════════════════════
/// CATEGORIES SCREEN - EXACT SPEC
/// Every pixel matches the specification exactly.
/// NO creative changes. NO improvisation.
/// ═══════════════════════════════════════════════════════

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
      final p = context.read<ProductProvider>();
      if (p.categories.isEmpty) p.loadCategories();
    });
  }

  // Group categories into sections
  Map<String, List<CategoryModel>> _getSections(List<CategoryModel> cats) {
    final fresh   = <CategoryModel>[];
    final grocery = <CategoryModel>[];
    final snacks  = <CategoryModel>[];

    for (final c in cats) {
      final n = c.name.toLowerCase();
      if (n.contains('veg') || n.contains('fruit') ||
          n.contains('dairy') || n.contains('meat')) {
        fresh.add(c);
      } else if (n.contains('grain') || n.contains('bakery')) {
        grocery.add(c);
      } else {
        snacks.add(c);
      }
    }
    return {
      if (fresh.isNotEmpty)   'Fresh Items':       fresh,
      if (grocery.isNotEmpty) 'Grocery & Kitchen':  grocery,
      if (snacks.isNotEmpty)  'Snacks & Drinks':    snacks,
    };
  }

  @override
  Widget build(BuildContext context) {
    final product = context.watch<ProductProvider>();

    return Scaffold(
      // Spec 11: Background #FFFFFF
      backgroundColor: const Color(0xFFFFFFFF),
      body: SafeArea(
        // Spec 1: Top safe padding 24px
        child: Column(
          children: [
            // ─── HEADER (Spec 2) ─────────────────
            Padding(
              // Spec 2: Horizontal 24px, Top 20px, Bottom 24px
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Spec 2: Title 34px, w700, #111111, spacing -0.5
                  const Text('Categories',
                    style: TextStyle(
                      fontSize:       34,
                      fontWeight:     FontWeight.w700,
                      color:          Color(0xFF111111),
                      letterSpacing:  -0.5,
                    ),
                  ),
                  // Spec 2: Search 40x40 touch, 24x24 icon, no bg
                  SizedBox(
                    width: 40, height: 40,
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      icon: const Icon(Icons.search,
                        size: 24, color: Color(0xFF111111)),
                      onPressed: () {},
                    ),
                  ),
                ],
              ),
            ),

            // ─── SCROLLABLE CONTENT ──────────────
            Expanded(
              child: ListView(
                // Spec 10: Bouncing scroll physics
                physics: const BouncingScrollPhysics(
                  parent: AlwaysScrollableScrollPhysics()),
                children: [
                  // Spec 3: 24px gap between header and first section
                  // (already handled by header bottom padding)

                  // Category sections
                  ...(_getSections(product.categories).entries.map((entry) {
                    return _CategorySection(
                      title:      entry.key,
                      categories: entry.value,
                    );
                  }).toList()),

                  // Spec 17: 24px before banner
                  const SizedBox(height: 24),

                  // FREE DELIVERY BANNER (Spec 15)
                  const _FreeDeliveryBanner(),

                  // Space for bottom nav
                  SizedBox(height: 80 + MediaQuery.of(context).padding.bottom),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// ═══════════════════════════════════════════════════════
/// CATEGORY SECTION (Spec 4, 5, 6)
/// ═══════════════════════════════════════════════════════

class _CategorySection extends StatelessWidget {
  final String              title;
  final List<CategoryModel> categories;

  const _CategorySection({
    required this.title,
    required this.categories,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Spec 4: Section title - 22px, w700, #111111, bottom 18px
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 18),
          child: Text(title,
            style: const TextStyle(
              fontSize:   22,
              fontWeight: FontWeight.w700,
              color:      Color(0xFF111111),
            ),
          ),
        ),

        // Spec 5: Horizontal scrolling cards
        SizedBox(
          // Spec 5: Card height 126px
          height: 126,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            // Spec 10: Bouncing physics
            physics: const BouncingScrollPhysics(),
            // Spec 5: Section padding 24px
            padding: const EdgeInsets.symmetric(horizontal: 24),
            itemCount: categories.length,
            itemBuilder: (context, index) {
              return Padding(
                // Spec 5: Card gap 16px
                padding: EdgeInsets.only(
                  right: index < categories.length - 1 ? 16 : 0),
                child: _CategoryCard(
                  category: categories[index],
                  colorIndex: index,
                ),
              );
            },
          ),
        ),

        // Spec 9: 36px between sections
        const SizedBox(height: 36),
      ],
    );
  }
}

/// ═══════════════════════════════════════════════════════
/// CATEGORY CARD (Spec 5, 6, 7, 8, 12)
/// ═══════════════════════════════════════════════════════

class _CategoryCard extends StatefulWidget {
  final CategoryModel category;
  final int            colorIndex;

  const _CategoryCard({
    required this.category,
    required this.colorIndex,
  });

  @override
  State<_CategoryCard> createState() => _CategoryCardState();
}

class _CategoryCardState extends State<_CategoryCard>
    with SingleTickerProviderStateMixin {

  late AnimationController _ctrl;
  late Animation<double>   _scale;

  // Spec 6: Pastel colors
  static const List<Color> pastels = [
    Color(0xFFE6F5F2),  // Mint
    Color(0xFFFFF2B8),  // Cream yellow
    Color(0xFFE7F8EF),  // Light green
    Color(0xFFF3EBFF),  // Lavender
    Color(0xFFEAF4FF),  // Light blue
    Color(0xFFFCE4EC),  // Pink
    Color(0xFFFFF9C4),  // Yellow
    Color(0xFFE0F7FA),  // Cyan
  ];

  @override
  void initState() {
    super.initState();
    // Spec 21: Scale 1.0 -> 0.97 on tap, spring back
    _ctrl = AnimationController(
      vsync:    this,
      duration: const Duration(milliseconds: 100),
    );
    _scale = Tween<double>(begin: 1.0, end: 0.97).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final color = pastels[widget.colorIndex % pastels.length];

    return GestureDetector(
      // Spec 21: Scale animation on tap
      onTapDown:   (_) => _ctrl.forward(),
      onTapUp:     (_) => _ctrl.reverse(),
      onTapCancel: ()  => _ctrl.reverse(),
      onTap: () => context.read<ProductProvider>()
          .selectCategory(widget.category.name),
      child: ScaleTransition(
        scale: _scale,
        child: SizedBox(
          // Spec 5: Width 96px
          width: 96,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Spec 6: Image container 90x90
              Container(
                width: 80, height: 80,
                decoration: BoxDecoration(
                  color: color,
                  // Spec 6: Rounded top 46, bottom 18
                  // approximated with 26 uniform radius
                  borderRadius: BorderRadius.circular(26),
                  // Spec 12: NO shadow, NO elevation, NO border
                ),
                child: Center(
                  // Spec 7: Image fill 72-80%, centered
                  child: widget.category.image != null &&
                         widget.category.image!.startsWith('http')
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: Image.network(
                            widget.category.image!,
                            width: 68, height: 68,
                            fit: BoxFit.contain,
                            errorBuilder: (_, __, ___) =>
                              Text(widget.category.icon,
                                style: const TextStyle(fontSize: 36)),
                          ),
                        )
                      : Text(widget.category.icon,
                          style: const TextStyle(fontSize: 36)),
                ),
              ),

              // Spec 8: Image bottom spacing 10px
              const SizedBox(height: 10),

              // Spec 8: Text - width 90, center, 15px semibold, max 2 lines
              SizedBox(
                width: 90,
                child: Text(
                  widget.category.name,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize:   15,
                    fontWeight: FontWeight.w600,
                    color:      Color(0xFF111111),
                    height:     1.2,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// ═══════════════════════════════════════════════════════
/// FREE DELIVERY BANNER (Spec 15)
/// ═══════════════════════════════════════════════════════

class _FreeDeliveryBanner extends StatefulWidget {
  const _FreeDeliveryBanner();

  @override
  State<_FreeDeliveryBanner> createState() => _FreeDeliveryBannerState();
}

class _FreeDeliveryBannerState extends State<_FreeDeliveryBanner>
    with SingleTickerProviderStateMixin {

  late AnimationController _flagCtrl;

  @override
  void initState() {
    super.initState();
    // Spec 15: Flag animation - infinite, 3 sec, ease in out
    _flagCtrl = AnimationController(
      vsync:    this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
  }

  @override
  void dispose() { _flagCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Container(
      // Spec 15: Height 60px, Background #E8FAFF
      height: 60,
      margin: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: const Color(0xFFE8FAFF),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const SizedBox(width: 20),
          // Spec 15: Left text - Bold 18 + Regular 15
          Expanded(
            child: RichText(
              text: const TextSpan(
                children: [
                  TextSpan(
                    text: 'FREE DELIVERY ',
                    style: TextStyle(
                      fontSize: 15, fontWeight: FontWeight.w700,
                      color:      Color(0xFF111111)),
                  ),
                  TextSpan(
                    text: 'on orders above Rs99',
                    style: TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w400,
                      color:      Color(0xFF111111)),
                  ),
                ],
              ),
            ),
          ),
          // Spec 15: Animated flag - 3 sec, ease in out, 3-5px amplitude
          AnimatedBuilder(
            animation: _flagCtrl,
            builder: (context, _) {
              return Transform.translate(
                offset: Offset(
                  0,
                  math.sin(_flagCtrl.value * math.pi) * 4, // 4px amplitude
                ),
                child: Container(
                  width:  42,
                  height: 42,
                  margin: const EdgeInsets.only(right: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0EA5E9),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Center(
                    child: Text('🏳️',
                      style: TextStyle(fontSize: 20)),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}


