import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../models/product_model.dart';
import '../providers/cart_provider.dart';
import '../providers/wishlist_provider.dart';
import '../constants/app_constants.dart';

class ProductQuickView {
  static void show(BuildContext context, ProductModel product,
    {List<ProductModel>? relatedProducts}) {
    showModalBottomSheet(
      context:            context,
      isScrollControlled: true,
      backgroundColor:    Colors.transparent,
      barrierColor:       Colors.black.withOpacity(0.5),
      isDismissible:      true,
      enableDrag:         true,
      builder: (ctx) => _QuickViewSheet(
        product:         product,
        relatedProducts: relatedProducts ?? [],
      ),
    );
  }
}

class _QuickViewSheet extends StatefulWidget {
  final ProductModel       product;
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
  late Animation<Offset>   _slideAnim;

  @override
  void initState() {
    super.initState();
    _current = widget.product;

    _slideController = AnimationController(
      vsync:    this,
      duration: const Duration(milliseconds: 400),
    );
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 1),
      end:   Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve:  Curves.easeOutCubic,
    ));
    _slideController.forward();
  }

  @override
  void dispose() {
    _slideController.dispose();
    super.dispose();
  }

  void _switchProduct(ProductModel product) {
    setState(() {
      _current = product;
      _currentImageIndex = 0;
    });
  }

  List<String> get _images {
    if (_current.images.isNotEmpty) return _current.images;
    return [_current.displayImage];
  }

  @override
  Widget build(BuildContext context) {
    final cart     = context.watch<CartProvider>();
    final wishlist = context.watch<WishlistProvider>();
    final inCart   = cart.isInCart(_current.id);
    final qty      = cart.getQuantity(_current.id);
    final isFav    = wishlist.isInWishlist(_current.id);
    final height   = MediaQuery.of(context).size.height;

    return SlideTransition(
      position: _slideAnim,
      child: DraggableScrollableSheet(
        initialChildSize: 0.85,
        maxChildSize:     0.95,
        minChildSize:     0.5,
        expand:           false,
        builder: (context, scrollController) {
          return Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Column(
              children: [
                // Drag handle
                Container(
                  margin: const EdgeInsets.only(top: 8),
                  width:  40, height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2)),
                ),

                // Top bar - close, bookmark, share
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            shape: BoxShape.circle),
                          child: const Icon(Icons.keyboard_arrow_down,
                            color: Colors.black87, size: 22),
                        ),
                        onPressed: () => Navigator.pop(context),
                      ),
                      Row(
                        children: [
                          IconButton(
                            icon: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade100,
                                shape: BoxShape.circle),
                              child: AnimatedSwitcher(
                                duration: const Duration(milliseconds: 200),
                                transitionBuilder: (child, anim) =>
                                  ScaleTransition(scale: anim, child: child),
                                child: Icon(
                                  isFav ? Icons.bookmark : Icons.bookmark_outline,
                                  key: ValueKey(isFav),
                                  color: isFav ? AppConstants_Color.primary : Colors.black87,
                                  size: 22),
                              ),
                            ),
                            onPressed: () {
                              context.read<WishlistProvider>().toggleWishlist(_current);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(isFav
                                      ? 'Removed from wishlist'
                                      : 'Saved to wishlist ❤️'),
                                  backgroundColor: isFav ? Colors.grey : AppConstants_Color.primary,
                                  behavior: SnackBarBehavior.floating,
                                  duration: const Duration(seconds: 1),
                                ),
                              );
                            },
                          ),
                          IconButton(
                            icon: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade100,
                                shape: BoxShape.circle),
                              child: const Icon(Icons.share_outlined,
                                color: Colors.black87, size: 22),
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
                        // IMAGE CAROUSEL (Instamart style)
                        Container(
                          height: 280,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: CarouselSlider.builder(
                            carouselController: _carouselCtrl,
                            itemCount: _images.length,
                            options: CarouselOptions(
                              height:              280,
                              viewportFraction:    1.0,
                              enableInfiniteScroll: _images.length > 1,
                              autoPlay:            false,
                              enlargeCenterPage:   false,
                              onPageChanged: (i, _) =>
                                setState(() => _currentImageIndex = i),
                            ),
                            itemBuilder: (context, index, _) {
                              final img = _images[index];
                              return Container(
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: img.startsWith('http')
                                    ? ClipRRect(
                                        borderRadius: BorderRadius.circular(12),
                                        child: Image.network(img,
                                          fit: BoxFit.contain,
                                          loadingBuilder: (_, child, progress) =>
                                            progress == null ? child :
                                            const Center(
                                              child: CircularProgressIndicator(
                                                color: AppConstants_Color.primary,
                                                strokeWidth: 2)),
                                          errorBuilder: (_, __, ___) =>
                                            Center(
                                              child: Text(img,
                                                style: const TextStyle(fontSize: 100))),
                                        ),
                                      )
                                    : Center(
                                        child: Text(img,
                                          style: const TextStyle(fontSize: 120))),
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
                                  count:       _images.length,
                                  effect: const ExpandingDotsEffect(
                                    activeDotColor: AppConstants_Color.primary,
                                    dotColor:       Color(0xFFCCCCCC),
                                    dotHeight:      8,
                                    dotWidth:       8,
                                    expansionFactor: 2.5,
                                    spacing:        4,
                                  ),
                                )
                              else
                                const SizedBox(),
                              Row(
                                children: [
                                  const Icon(Icons.access_time, size: 14,
                                    color: Colors.grey),
                                  const SizedBox(width: 4),
                                  const Text('30 MINS',
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12)),
                                  const SizedBox(width: 12),
                                  Icon(Icons.star, size: 16,
                                    color: AppConstants_Color.primary),
                                  const SizedBox(width: 2),
                                  Text(
                                    '${_current.rating.toStringAsFixed(1)} (${_current.reviewCount})',
                                    style: const TextStyle(
                                      color: AppConstants_Color.primary,
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
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey.shade200),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (_current.categoryName != null)
                                Text('Explore all ${_current.categoryName} items >',
                                  style: const TextStyle(
                                    color: Colors.blue,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500)),
                              const SizedBox(height: 8),
                              Text(_current.name,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87)),
                              const SizedBox(height: 6),
                              Text(_current.description.isNotEmpty
                                  ? _current.description
                                  : 'Fresh ${_current.name} - Premium quality from trusted sources',
                                style: TextStyle(
                                  color: Colors.grey.shade600,
                                  fontSize: 13,
                                  height: 1.4)),
                              const SizedBox(height: 12),
                              Text('Quantity: ${_current.unit}',
                                style: const TextStyle(
                                  color: Colors.black87, fontSize: 13)),
                            ],
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Quantity selector cards
                        if (widget.relatedProducts.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade50,
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(
                                        color: Colors.grey.shade300),
                                    ),
                                    child: Column(
                                      children: [
                                        Text('2 x ${_current.unit}',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold)),
                                        Text(
                                          '${AppConstants.currency}${(_current.finalPrice * 2).toStringAsFixed(0)}',
                                          style: TextStyle(
                                            color: AppConstants_Color.primary,
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
                                      color: AppConstants_Color.primaryLight,
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(
                                        color: AppConstants_Color.primary, width: 2),
                                    ),
                                    child: Column(
                                      children: [
                                        Text(_current.unit,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold)),
                                        Text(
                                          '${AppConstants.currency}${_current.finalPrice.toStringAsFixed(0)}',
                                          style: TextStyle(
                                            color: AppConstants_Color.primary,
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

                // BOTTOM ACTION BAR - Instamart style
                Container(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border(
                      top: BorderSide(color: Colors.grey.shade200, width: 1)),
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
                                  style: const TextStyle(fontSize: 13)),
                                if (_current.hasDiscount) ...[
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: AppConstants_Color.primaryLight,
                                      borderRadius: BorderRadius.circular(4)),
                                    child: Text(
                                      '${_current.discount.toInt()}% OFF',
                                      style: TextStyle(
                                        color: AppConstants_Color.primary,
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
                                Text(
                                  '${AppConstants.currency}${_current.finalPrice.toStringAsFixed(0)}',
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87)),
                                if (_current.hasDiscount) ...[
                                  const SizedBox(width: 6),
                                  Text(
                                    '${AppConstants.currency}${_current.price.toStringAsFixed(0)}',
                                    style: TextStyle(
                                      color: Colors.grey.shade500,
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
                                    color: AppConstants_Color.primary,
                                    borderRadius: BorderRadius.circular(8)),
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
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 16),
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
                              : Container(
                                  key: const ValueKey('add'),
                                  width: 130, height: 48,
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppConstants_Color.primary,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8)),
                                      padding: EdgeInsets.zero),
                                    onPressed: () =>
                                      context.read<CartProvider>().addItem(_current),
                                    child: const Text('ADD',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                        letterSpacing: 1)),
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

// Color constants
class AppConstants_Color {
  static const Color primary      = Color(0xFF1BA672);
  static const Color primaryLight = Color(0xFFE8F5E9);
}
