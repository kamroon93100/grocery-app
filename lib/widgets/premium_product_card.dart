import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/product_model.dart';
import '../providers/cart_provider.dart';
import '../constants/app_constants.dart';

/// ═══════════════════════════════════════════════════════
/// PREMIUM PRODUCT CARD
/// Pixel-perfect, compact, Instamart-grade
///
/// Hierarchy: Image → Timer → Name → Unit → Price + ADD
/// Card ratio: consistent across the app
/// ═══════════════════════════════════════════════════════

class PremiumProductCard extends StatefulWidget {
  final ProductModel product;
  final VoidCallback? onTap;

  const PremiumProductCard({
    super.key,
    required this.product,
    this.onTap,
  });

  @override
  State<PremiumProductCard> createState() => _PremiumProductCardState();
}

class _PremiumProductCardState extends State<PremiumProductCard>
    with SingleTickerProviderStateMixin {

  late AnimationController _pressCtrl;
  late Animation<double>   _pressScale;

  @override
  void initState() {
    super.initState();
    _pressCtrl = AnimationController(
      vsync:    this,
      duration: const Duration(milliseconds: 100),
    );
    _pressScale = Tween<double>(begin: 1.0, end: 0.97).animate(
      CurvedAnimation(parent: _pressCtrl, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _pressCtrl.dispose();
    super.dispose();
  }

  bool get _isNetworkImage =>
      widget.product.displayImage.startsWith('http');

  @override
  Widget build(BuildContext context) {
    final cart   = context.watch<CartProvider>();
    final p      = widget.product;
    final inCart = cart.isInCart(p.id);
    final qty    = cart.getQuantity(p.id);

    return GestureDetector(
      onTapDown:   (_) => _pressCtrl.forward(),
      onTapUp:     (_) => _pressCtrl.reverse(),
      onTapCancel: ()  => _pressCtrl.reverse(),
      onTap: widget.onTap,
      child: ScaleTransition(
        scale: _pressScale,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE8E8E8)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ─── IMAGE AREA ─────────────────────
              Expanded(
                flex: 5,
                child: Stack(
                  children: [
                    // Background + Image
                    Container(
                      width: double.infinity,
                      decoration: const BoxDecoration(
                        color: Color(0xFFF0FFF4),
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(12)),
                      ),
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: _buildImage(p),
                        ),
                      ),
                    ),

                    // Discount badge (top-left)
                    if (p.hasDiscount)
                      Positioned(
                        top: 8, left: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 3),
                          decoration: BoxDecoration(
                            color: const Color(0xFF12B76A),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            '${p.discount.toInt()}% OFF',
                            style: const TextStyle(
                              color:      Colors.white,
                              fontSize:   9,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.3),
                          ),
                        ),
                      ),

                    // Low stock (bottom-right)
                    if (p.stock > 0 && p.stock < 10)
                      Positioned(
                        bottom: 8, right: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 5, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF79009),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'Only ${p.stock} left',
                            style: const TextStyle(
                              color:    Colors.white,
                              fontSize: 8,
                              fontWeight: FontWeight.w700),
                          ),
                        ),
                      ),

                    // Out of stock overlay
                    if (p.stock == 0)
                      Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.7),
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(12)),
                          ),
                          child: const Center(
                            child: Text('OUT OF STOCK',
                              style: TextStyle(
                                color:    Color(0xFF667085),
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 1)),
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              // ─── DETAILS AREA ───────────────────
              Expanded(
                flex: 4,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Delivery time pill
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF2F4F7),
                          borderRadius: BorderRadius.circular(100),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.schedule,
                              size: 10, color: Color(0xFF667085)),
                            SizedBox(width: 3),
                            Text('30 mins',
                              style: TextStyle(
                                fontSize:   10,
                                fontWeight: FontWeight.w600,
                                color:      Color(0xFF667085))),
                          ],
                        ),
                      ),

                      const SizedBox(height: 6),

                      // Product name (bold, 2 lines max)
                      Text(
                        p.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize:   14,
                          fontWeight: FontWeight.w700,
                          color:      Color(0xFF101828),
                          height:     1.3),
                      ),

                      const SizedBox(height: 2),

                      // Unit
                      Text(
                        p.unit,
                        style: const TextStyle(
                          fontSize:   12,
                          fontWeight: FontWeight.w400,
                          color:      Color(0xFF667085)),
                      ),

                      const Spacer(),

                      // Price + ADD button
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          // Price column
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  '${AppConstants.currency}${p.finalPrice.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    fontSize:   16,
                                    fontWeight: FontWeight.w800,
                                    color:      Color(0xFF101828),
                                    fontFeatures: [FontFeature.tabularFigures()]),
                                ),
                                if (p.hasDiscount)
                                  Text(
                                    '${AppConstants.currency}${p.price.toStringAsFixed(2)}',
                                    style: const TextStyle(
                                      fontSize:   11,
                                      fontWeight: FontWeight.w400,
                                      color:      Color(0xFF98A2B3),
                                      decoration: TextDecoration.lineThrough,
                                      fontFeatures: [FontFeature.tabularFigures()]),
                                  ),
                              ],
                            ),
                          ),

                          // ADD or Quantity control
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 150),
                            transitionBuilder: (child, anim) =>
                              ScaleTransition(scale: anim, child: child),
                            child: p.stock == 0
                                ? const SizedBox(key: ValueKey('empty'))
                                : inCart
                                    ? _QuantityControl(
                                        key:    const ValueKey('qty'),
                                        qty:    qty,
                                        onAdd:  () => context.read<CartProvider>()
                                            .increaseQuantity(p.id),
                                        onMinus:() => context.read<CartProvider>()
                                            .decreaseQuantity(p.id),
                                      )
                                    : _AddButton(
                                        key: const ValueKey('add'),
                                        onTap: () => context.read<CartProvider>()
                                            .addItem(p),
                                      ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImage(ProductModel p) {
    if (_isNetworkImage) {
      return CachedNetworkImage(
        imageUrl: p.displayImage,
        fit:      BoxFit.contain,
        placeholder: (_, __) => _ShimmerBox(),
        errorWidget: (_, __, ___) => _emojiDisplay(p),
      );
    }
    return _emojiDisplay(p);
  }

  Widget _emojiDisplay(ProductModel p) {
    final display = p.displayImage.isNotEmpty ? p.displayImage : '🛒';
    return Text(display, style: const TextStyle(fontSize: 56));
  }
}

// ─── ADD BUTTON (Outlined, Instamart style) ──────────

class _AddButton extends StatelessWidget {
  final VoidCallback onTap;
  const _AddButton({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: Container(
          width: 72, height: 34,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: const Color(0xFF12B76A),
              width: 1.5),
          ),
          child: const Center(
            child: Text('ADD',
              style: TextStyle(
                color:      Color(0xFF12B76A),
                fontSize:   13,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.8)),
          ),
        ),
      ),
    );
  }
}

// ─── QUANTITY CONTROL (Solid Green) ──────────────────

class _QuantityControl extends StatelessWidget {
  final int          qty;
  final VoidCallback onAdd;
  final VoidCallback onMinus;

  const _QuantityControl({
    super.key,
    required this.qty,
    required this.onAdd,
    required this.onMinus,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 34,
      decoration: BoxDecoration(
        color: const Color(0xFF12B76A),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          InkWell(
            onTap: onMinus,
            child: const SizedBox(
              width: 32,
              child: Center(
                child: Icon(Icons.remove,
                  color: Colors.white, size: 15)),
            ),
          ),
          SizedBox(
            width: 28,
            child: Center(
              child: Text(
                '$qty',
                style: const TextStyle(
                  color:      Colors.white,
                  fontSize:   14,
                  fontWeight: FontWeight.w700,
                  fontFeatures: [FontFeature.tabularFigures()]),
              ),
            ),
          ),
          InkWell(
            onTap: onAdd,
            child: const SizedBox(
              width: 32,
              child: Center(
                child: Icon(Icons.add,
                  color: Colors.white, size: 15)),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── SHIMMER LOADING ─────────────────────────────────

class _ShimmerBox extends StatefulWidget {
  @override
  State<_ShimmerBox> createState() => _ShimmerBoxState();
}

class _ShimmerBoxState extends State<_ShimmerBox>
    with SingleTickerProviderStateMixin {

  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync:    this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) => Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          gradient: LinearGradient(
            colors: [
              const Color(0xFFE8E8E8),
              const Color(0xFFF5F5F5),
              const Color(0xFFE8E8E8),
            ],
            stops: [
              (_ctrl.value - 0.3).clamp(0.0, 1.0),
              _ctrl.value,
              (_ctrl.value + 0.3).clamp(0.0, 1.0),
            ],
          ),
        ),
      ),
    );
  }
}
