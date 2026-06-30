import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/product_model.dart';
import '../providers/cart_provider.dart';
import '../constants/app_constants.dart';
import '../app/theme/theme.dart';
import 'brand_components.dart';
import 'brand_image.dart';
import '../widgets/product_quick_view.dart';

/// Standardized product card - same ratio everywhere
class BrandProductCard extends StatelessWidget {
  final ProductModel product;
  final bool         compact;

  const BrandProductCard({
    super.key,
    required this.product,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final cart    = context.watch<CartProvider>();
    final inCart  = cart.isInCart(product.id);
    final qty     = cart.getQuantity(product.id);

    return GestureDetector(
      onTap: () => ProductQuickView.show(context, product),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.card),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // IMAGE (standardized 1:1 ratio)
            Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.x8),
                  child: BrandImage(
                    imageUrl: product.displayImage,
                    fallbackEmoji: '🛒',
                    context: ImageContext.productCardSmall,
                  ),
                ),
                if (product.hasDiscount)
                  Positioned(
                    top: 8, left: 8,
                    child: OfferBadge.discount(product.discount.toInt())),
                if (product.stock < 10 && product.stock > 0)
                  Positioned(
                    bottom: 8, left: 8,
                    child: OfferBadge.lowStock(product.stock)),
                if (product.stock == 0)
                  Positioned.fill(
                    child: Container(
                      margin: const EdgeInsets.all(AppSpacing.x8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.8),
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                      ),
                      child: Center(child: OfferBadge.outOfStock()),
                    ),
                  ),
              ],
            ),

            // DETAILS
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.x12, AppSpacing.x4,
                AppSpacing.x12, AppSpacing.x12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Delivery time pill (only if needed)
                  TimerPill(minutes: '30'),
                  const SizedBox(height: AppSpacing.x8),

                  // Product name
                  Text(product.name,
                    style: AppText.smallStrong,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis),

                  const SizedBox(height: 2),

                  // Unit size
                  Text(product.unit,
                    style: AppText.caption),

                  const SizedBox(height: AppSpacing.x12),

                  // Price + Add button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: PriceDisplay(
                          price:         product.finalPrice,
                          originalPrice: product.hasDiscount
                              ? product.price : null,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.x8),
                      AnimatedSwitcher(
                        duration: AppMotion.fast,
                        transitionBuilder: (child, anim) =>
                          ScaleTransition(scale: anim, child: child),
                        child: product.stock == 0
                            ? const SizedBox(key: ValueKey('out'))
                            : inCart
                                ? QuantityStepper(
                                    key: const ValueKey('qty'),
                                    quantity: qty,
                                    onIncrement: () => context
                                        .read<CartProvider>()
                                        .increaseQuantity(product.id),
                                    onDecrement: () => context
                                        .read<CartProvider>()
                                        .decreaseQuantity(product.id),
                                  )
                                : CardAddButton(
                                    key: const ValueKey('add'),
                                    onPressed: () => context
                                        .read<CartProvider>()
                                        .addItem(product),
                                  ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}



