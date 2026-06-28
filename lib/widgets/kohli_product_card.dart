import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:grocery_local/app/theme/app_colors.dart';
import 'package:grocery_local/app/theme/app_text_styles.dart';
import 'package:grocery_local/app/theme/app_radius.dart';
import 'package:grocery_local/app/theme/color_scheme_ext.dart';
import 'package:grocery_local/models/product_model.dart';
import 'package:grocery_local/providers/cart_provider.dart';
import 'package:grocery_local/constants/app_constants.dart';

class KohliProductCard extends StatefulWidget {
  final ProductModel product;
  final VoidCallback? onTap;
  final double width;

  const KohliProductCard({
    super.key,
    required this.product,
    this.onTap,
    this.width = 165,
  });

  @override
  State<KohliProductCard> createState() => _KohliProductCardState();
}

class _KohliProductCardState extends State<KohliProductCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _pressCtrl;
  late Animation<double> _pressScale;

  @override
  void initState() {
    super.initState();
    _pressCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 90),
    );
    _pressScale = Tween<double>(begin: 1.0, end: 0.96).animate(
      CurvedAnimation(parent: _pressCtrl, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _pressCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final cart = context.watch<CartProvider>();
    final p = widget.product;
    final inCart = cart.isInCart(p.id);
    final qty = cart.getQuantity(p.id);

    return GestureDetector(
      onTapDown: (_) => _pressCtrl.forward(),
      onTapUp: (_) => _pressCtrl.reverse(),
      onTapCancel: () => _pressCtrl.reverse(),
      onTap: widget.onTap,
      child: ScaleTransition(
        scale: _pressScale,
        child: Container(
          width: widget.width,
          decoration: BoxDecoration(
            color: colorScheme.card,
            borderRadius: BorderRadius.circular(AppRadius.productCardImage),
            border: Border.all(color: colorScheme.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image Area
              Container(
                height: widget.width - 16,
                decoration: BoxDecoration(
                  color: colorScheme.categoryBg,
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(AppRadius.productCardImage),
                  ),
                ),
                child: Stack(
                  children: [
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Hero(
                          tag: 'product_${p.id}',
                          child: _buildImage(p, colorScheme),
                        ),
                      ),
                    ),
                    // Badge top-left
                    if (p.hasDiscount)
                      Positioned(
                        top: 8, left: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.lightSuccess,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text('${p.discount.toInt()}% OFF',
                            style: const TextStyle(
                              color: Colors.white, fontSize: 9,
                              fontWeight: FontWeight.w700)),
                        ),
                      ),
                    // Wishlist top-right
                    Positioned(
                      top: 4, right: 4,
                      child: Icon(Icons.favorite_border_rounded,
                        color: colorScheme.textMuted, size: 20),
                    ),
                    if (p.stock == 0)
                      Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.7),
                            borderRadius: BorderRadius.vertical(
                              top: Radius.circular(AppRadius.productCardImage)),
                          ),
                          child: Center(
                            child: Text('OUT OF STOCK',
                              style: TextStyle(
                                color: colorScheme.textMuted,
                                fontSize: 11, fontWeight: FontWeight.w700,
                                letterSpacing: 1)),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              // Details
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Rating row optional
                    if (p.rating > 0)
                      Row(
                        children: [
                          Icon(Icons.star_rounded,
                            size: 14, color: AppColors.lightWarning),
                          const SizedBox(width: 2),
                          Text('${p.rating.toStringAsFixed(1)}',
                            style: TextStyle(
                              fontSize: 11, fontWeight: FontWeight.w600,
                              color: colorScheme.textMuted)),
                          const SizedBox(width: 4),
                          Text('(${p.reviewCount})',
                            style: TextStyle(
                              fontSize: 10, color: colorScheme.textMuted)),
                        ],
                      ),
                    const SizedBox(height: 4),
                    // Product name
                    Text(p.name,
                      maxLines: 2, overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.bodyStrong(color: colorScheme.textPrimary),
                    ),
                    const SizedBox(height: 2),
                    // Unit
                    Text(p.unit,
                      style: AppTextStyles.caption(color: colorScheme.textMuted),
                    ),
                    const SizedBox(height: 6),
                    // Price + Add button
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('${AppConstants.currency}${p.finalPrice.toStringAsFixed(0)}',
                                style: AppTextStyles.price(color: colorScheme.textPrimary),
                              ),
                              if (p.hasDiscount)
                                Text('${AppConstants.currency}${p.price.toStringAsFixed(0)}',
                                  style: TextStyle(
                                    fontSize: 11, fontWeight: FontWeight.w400,
                                    color: colorScheme.textMuted,
                                    decoration: TextDecoration.lineThrough),
                                ),
                            ],
                          ),
                        ),
                        // Add button
                        _AddStepper(
                          inCart: inCart,
                          qty: qty,
                          onAdd: () => context.read<CartProvider>().addItem(p),
                          onIncrement: () => context.read<CartProvider>().increaseQuantity(p.id),
                          onDecrement: () => context.read<CartProvider>().decreaseQuantity(p.id),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImage(ProductModel p, ColorScheme colorScheme) {
    if (p.isNetworkImage) {
      return CachedNetworkImage(
        imageUrl: p.displayImage,
        fit: BoxFit.contain,
        placeholder: (_, __) => Container(
          decoration: BoxDecoration(
            color: colorScheme.softSurface,
            borderRadius: BorderRadius.circular(AppRadius.productCardImage),
          ),
        ),
        errorWidget: (_, __, ___) => Text(p.displayImage.isNotEmpty ? p.displayImage : '🛒',
          style: const TextStyle(fontSize: 40)),
      );
    }
    return Text(p.displayImage.isNotEmpty ? p.displayImage : '🛒',
      style: const TextStyle(fontSize: 40));
  }
}

class _AddStepper extends StatelessWidget {
  final bool inCart;
  final int qty;
  final VoidCallback onAdd;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;

  const _AddStepper({
    required this.inCart,
    required this.qty,
    required this.onAdd,
    required this.onIncrement,
    required this.onDecrement,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final brandColor = colorScheme.primary;

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 150),
      transitionBuilder: (child, anim) => ScaleTransition(scale: anim, child: child),
      child: inCart
          ? Container(
              key: const ValueKey('qty'),
              height: 36,
              decoration: BoxDecoration(
                color: brandColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  InkWell(
                    onTap: onDecrement,
                    child: const SizedBox(
                      width: 32,
                      child: Center(child: Icon(Icons.remove, color: Colors.white, size: 16)),
                    ),
                  ),
                  SizedBox(
                    width: 28,
                    child: Center(
                      child: Text('$qty',
                        style: const TextStyle(
                          color: Colors.white, fontSize: 14, fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: onIncrement,
                    child: const SizedBox(
                      width: 32,
                      child: Center(child: Icon(Icons.add, color: Colors.white, size: 16)),
                    ),
                  ),
                ],
              ),
            )
          : SizedBox(
              key: const ValueKey('add'),
              height: 36,
              child: OutlinedButton(
                onPressed: onAdd,
                style: OutlinedButton.styleFrom(
                  foregroundColor: brandColor,
                  side: BorderSide(color: brandColor, width: 1.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                ),
                child: Text('ADD',
                  style: TextStyle(
                    color: brandColor, fontSize: 12,
                    fontWeight: FontWeight.w700, letterSpacing: 0.8)),
              ),
            ),
    );
  }
}
