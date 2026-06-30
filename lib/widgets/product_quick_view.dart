import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../models/product_model.dart';
import '../providers/cart_provider.dart';
import '../providers/wishlist_provider.dart';
import '../constants/app_constants.dart';
import '../app/theme/app_text_styles.dart';
import '../app/theme/app_radius.dart';
import '../app/theme/color_scheme_ext.dart';

class ProductQuickView {
  static void show(BuildContext context, ProductModel product,
      {List<ProductModel>? relatedProducts}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withOpacity(0.55),
      isDismissible: true,
      enableDrag: true,
      builder: (ctx) => _QuickViewSheet(
        product: product,
        relatedProducts: relatedProducts ?? [],
      ),
    );
  }
}

class _QuickViewSheet extends StatefulWidget {
  final ProductModel product;
  final List<ProductModel> relatedProducts;

  const _QuickViewSheet({
    required this.product,
    required this.relatedProducts,
  });

  @override
  State<_QuickViewSheet> createState() => _QuickViewSheetState();
}

class _QuickViewSheetState extends State<_QuickViewSheet>
    with SingleTickerProviderStateMixin {
  late ProductModel _current;
  int _currentImageIndex = 0;
  final CarouselSliderController _carouselCtrl = CarouselSliderController();

  late AnimationController _slideController;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _current = widget.product;

    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 280),
    );
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: const Cubic(0.22, 1, 0.36, 1),
    ));
    _slideController.forward();
  }

  @override
  void dispose() {
    _slideController.dispose();
    super.dispose();
  }



  List<String> get _images {
    if (_current.images.isNotEmpty) return _current.images;
    return [_current.displayImage];
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final cart = context.watch<CartProvider>();
    final wishlist = context.watch<WishlistProvider>();
    final inCart = cart.isInCart(_current.id);
    final qty = cart.getQuantity(_current.id);
    final isFav = wishlist.isInWishlist(_current.id);

    return SlideTransition(
      position: _slideAnim,
      child: DraggableScrollableSheet(
        initialChildSize: 0.85,
        maxChildSize: 0.95,
        minChildSize: 0.5,
        expand: false,
        builder: (context, scrollController) {
          return Container(
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.bottomSheet)),
            ),
            child: Column(
              children: [
                // Drag handle
                Container(
                  margin: const EdgeInsets.only(top: 12),
                  width: 48, height: 5,
                  decoration: BoxDecoration(
                    color: colorScheme.divider,
                    borderRadius: BorderRadius.circular(3)),
                ),
                // Top bar - close, bookmark, share
                Padding(
                  padding: const EdgeInsets.fromLTRB(8, 4, 8, 0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: colorScheme.softSurface,
                            shape: BoxShape.circle),
                          child: Icon(Icons.close_rounded,
                            color: colorScheme.textPrimary, size: 20),
                        ),
                        onPressed: () => Navigator.pop(context),
                      ),
                      Row(
                        children: [
                          IconButton(
                            icon: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: colorScheme.softSurface,
                                shape: BoxShape.circle),
                              child: AnimatedSwitcher(
                                duration: const Duration(milliseconds: 200),
                                transitionBuilder: (child, anim) =>
                                    ScaleTransition(scale: anim, child: child),
                                child: Icon(
                                  isFav ? Icons.bookmark : Icons.bookmark_outline,
                                  key: ValueKey(isFav),
                                  color: isFav ? colorScheme.primary : colorScheme.textMuted,
                                  size: 20),
                              ),
                            ),
                            onPressed: () {
                              context.read<WishlistProvider>().toggleWishlist(_current);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(isFav
                                      ? 'Removed from wishlist'
                                      : 'Saved to wishlist'),
                                  backgroundColor: isFav ? colorScheme.textMuted : colorScheme.primary,
                                  behavior: SnackBarBehavior.floating,
                                  duration: const Duration(seconds: 1),
                                ),
                              );
                            },
                          ),
                          const SizedBox(width: 4),
                          IconButton(
                            icon: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: colorScheme.softSurface,
                                shape: BoxShape.circle),
                              child: Icon(Icons.share_outlined,
                                color: colorScheme.textPrimary, size: 20),
                            ),
                            onPressed: () {},
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Scrollable content
                Expanded(
                  child: SingleChildScrollView(
                    controller: scrollController,
                    child: Column(
                      children: [
                        // IMAGE CAROUSEL
                        Container(
                          height: 260,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: CarouselSlider.builder(
                            carouselController: _carouselCtrl,
                            itemCount: _images.length,
                            options: CarouselOptions(
                              height: 260,
                              viewportFraction: 1.0,
                              enableInfiniteScroll: _images.length > 1,
                              autoPlay: false,
                              enlargeCenterPage: false,
                              onPageChanged: (i, _) =>
                                  setState(() => _currentImageIndex = i),
                            ),
                            itemBuilder: (context, index, _) {
                              final img = _images[index];
                              return Container(
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: colorScheme.softSurface,
                                  borderRadius: BorderRadius.circular(AppRadius.productCardImage),
                                ),
                                child: img.startsWith('http')
                                    ? ClipRRect(
                                        borderRadius: BorderRadius.circular(AppRadius.productCardImage),
                                        child: Image.network(img,
                                          fit: BoxFit.contain,
                                          loadingBuilder: (_, child, progress) =>
                                              progress == null ? child :
                                              const Center(
                                                child: CircularProgressIndicator(strokeWidth: 2)),
                                          errorBuilder: (_, __, ___) =>
                                              Center(
                                                child: Text(img,
                                                  style: const TextStyle(fontSize: 80))),
                                        ),
                                      )
                                    : Center(
                                        child: Text(img,
                                          style: const TextStyle(fontSize: 100))),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 12),
                        // Page indicator + rating
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              if (_images.length > 1)
                                AnimatedSmoothIndicator(
                                  activeIndex: _currentImageIndex,
                                  count: _images.length,
                                  effect: ExpandingDotsEffect(
                                    activeDotColor: colorScheme.primary,
                                    dotColor: colorScheme.divider,
                                    dotHeight: 8,
                                    dotWidth: 8,
                                    expansionFactor: 2.5,
                                    spacing: 4,
                                  ),
                                )
                              else
                                const SizedBox(),
                              Row(
                                children: [
                                  Icon(Icons.access_time_rounded, size: 14,
                                    color: colorScheme.textMuted),
                                  const SizedBox(width: 4),
                                  Text('30 MINS',
                                    style: TextStyle(
                                      color: colorScheme.textMuted,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12)),
                                  const SizedBox(width: 12),
                                  Icon(Icons.star_rounded, size: 16,
                                    color: colorScheme.warning),
                                  const SizedBox(width: 2),
                                  Text(
                                    '${_current.rating.toStringAsFixed(1)} (${_current.reviewCount})',
                                    style: TextStyle(
                                      color: colorScheme.warning,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13)),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Product info card
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 12),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: colorScheme.card,
                            borderRadius: BorderRadius.circular(AppRadius.productCardImage),
                            border: Border.all(color: colorScheme.border),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (_current.categoryName != null)
                                GestureDetector(
                                  onTap: () {},
                                  child: Text('Explore all ${_current.categoryName} items >',
                                    style: TextStyle(
                                      color: colorScheme.primary, fontSize: 13,
                                      fontWeight: FontWeight.w500)),
                                ),
                              const SizedBox(height: 8),
                              Text(_current.name,
                                style: AppTextStyles.h2(color: colorScheme.textPrimary)),
                              const SizedBox(height: 6),
                              Text(_current.description.isNotEmpty
                                  ? _current.description
                                  : 'Fresh ${_current.name} - Premium quality from trusted sources',
                                style: AppTextStyles.caption(color: colorScheme.textMuted)),
                              const SizedBox(height: 12),
                              Text('Quantity: ${_current.unit}',
                                style: AppTextStyles.body(color: colorScheme.textPrimary)),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Quantity variant selector
                        if (widget.relatedProducts.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: colorScheme.softSurface,
                                      borderRadius: BorderRadius.circular(AppRadius.primaryButton),
                                      border: Border.all(color: colorScheme.border),
                                    ),
                                    child: Column(
                                      children: [
                                        Text('2 x ${_current.unit}',
                                          style: TextStyle(fontWeight: FontWeight.bold,
                                            color: colorScheme.textPrimary)),
                                        Text('${AppConstants.currency}${(_current.finalPrice * 2).toStringAsFixed(0)}',
                                          style: TextStyle(
                                            color: colorScheme.primary,
                                            fontWeight: FontWeight.bold)),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: colorScheme.primary.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(AppRadius.primaryButton),
                                      border: Border.all(color: colorScheme.primary, width: 2),
                                    ),
                                    child: Column(
                                      children: [
                                        Text(_current.unit,
                                          style: TextStyle(fontWeight: FontWeight.bold,
                                            color: colorScheme.primary)),
                                        Text('${AppConstants.currency}${_current.finalPrice.toStringAsFixed(0)}',
                                          style: TextStyle(
                                            color: colorScheme.primary,
                                            fontWeight: FontWeight.bold)),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        const SizedBox(height: 100),
                      ],
                    ),
                  ),
                ),
                // BOTTOM STICKY CTA
                Container(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                  decoration: BoxDecoration(
                    color: colorScheme.surface,
                    border: Border(
                      top: BorderSide(color: colorScheme.divider, width: 1)),
                  ),
                  child: SafeArea(
                    top: false,
                    child: Row(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
                              children: [
                                Text(_current.unit,
                                  style: AppTextStyles.small(color: colorScheme.textMuted)),
                                if (_current.hasDiscount) ...[
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: colorScheme.successSoft,
                                      borderRadius: BorderRadius.circular(4)),
                                    child: Text('${_current.discount.toInt()}% OFF',
                                      style: TextStyle(
                                        color: colorScheme.success,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 10)),
                                  ),
                                ],
                              ],
                            ),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.baseline,
                              textBaseline: TextBaseline.alphabetic,
                              children: [
                                Text('${AppConstants.currency}${_current.finalPrice.toStringAsFixed(0)}',
                                  style: AppTextStyles.price(color: colorScheme.textPrimary)),
                                if (_current.hasDiscount) ...[
                                  const SizedBox(width: 6),
                                  Text('${AppConstants.currency}${_current.price.toStringAsFixed(0)}',
                                    style: TextStyle(
                                      color: colorScheme.textMuted,
                                      fontSize: 13,
                                      decoration: TextDecoration.lineThrough)),
                                ],
                              ],
                            ),
                          ],
                        ),
                        const Spacer(),
                        // ADD or quantity controls
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 250),
                          transitionBuilder: (child, anim) =>
                              ScaleTransition(scale: anim, child: child),
                          child: inCart
                              ? Container(
                                  key: const ValueKey('controls'),
                                  decoration: BoxDecoration(
                                    color: colorScheme.primary,
                                    borderRadius: BorderRadius.circular(AppRadius.primaryButton)),
                                  child: Row(
                                    children: [
                                      InkWell(
                                        onTap: () => context.read<CartProvider>()
                                            .decreaseQuantity(_current.id),
                                        child: const Padding(
                                          padding: EdgeInsets.all(12),
                                          child: Icon(Icons.remove,
                                            color: Colors.white, size: 18)),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 16),
                                        child: Text('$qty',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16)),
                                      ),
                                      InkWell(
                                        onTap: () => context.read<CartProvider>()
                                            .increaseQuantity(_current.id),
                                        child: const Padding(
                                          padding: EdgeInsets.all(12),
                                          child: Icon(Icons.add,
                                            color: Colors.white, size: 18)),
                                      ),
                                    ],
                                  ),
                                )
                              : SizedBox(
                                  key: const ValueKey('add'),
                                  width: 130, height: 48,
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: colorScheme.primary,
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(AppRadius.primaryButton)),
                                      padding: EdgeInsets.zero),
                                    onPressed: () =>
                                        context.read<CartProvider>().addItem(_current),
                                    child: Text('ADD',
                                      style: AppTextStyles.bodyStrong(color: Colors.white)),
                                  ),
                                ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

