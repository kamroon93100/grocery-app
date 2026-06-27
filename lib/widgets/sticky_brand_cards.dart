import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../main.dart';

class BrandAdData {
  final String  id;
  final String  brandName;
  final String  tagline;
  final String  ctaText;
  final String  imageUrl;
  final String  emoji;
  final List<Color> gradientColors;
  final VoidCallback? onTap;

  BrandAdData({
    required this.id,
    required this.brandName,
    required this.tagline,
    this.ctaText        = 'Shop Now',
    this.imageUrl       = '',
    this.emoji          = '🛒',
    required this.gradientColors,
    this.onTap,
  });
}

/// Instagram/Instamart-style sticky scroll card animations
class StickyBrandCards extends StatefulWidget {
  final List<BrandAdData> ads;
  final double            cardHeight;

  const StickyBrandCards({
    super.key,
    required this.ads,
    this.cardHeight = 280,
  });

  @override
  State<StickyBrandCards> createState() => _StickyBrandCardsState();
}

class _StickyBrandCardsState extends State<StickyBrandCards> {
  final ScrollController _scrollCtrl = ScrollController();
  double                 _scrollOffset = 0;

  @override
  void initState() {
    super.initState();
    _scrollCtrl.addListener(() {
      setState(() => _scrollOffset = _scrollCtrl.offset);
    });
  }

  @override
  void dispose() {
    _scrollCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final totalHeight = widget.cardHeight * widget.ads.length;

    return Container(
      height: widget.cardHeight + 40,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListView.builder(
        controller: _scrollCtrl,
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        physics: const BouncingScrollPhysics(),
        itemCount: widget.ads.length,
        itemBuilder: (context, index) {
          // Calculate scale based on scroll position
          final itemPosition = index * 280.0;
          final distance     = (itemPosition - _scrollOffset).abs();
          final scale        = (1.0 - (distance / 800)).clamp(0.85, 1.0);
          final opacity      = (1.0 - (distance / 600)).clamp(0.6, 1.0);

          return _BrandCard(
            ad:      widget.ads[index],
            scale:   scale,
            opacity: opacity,
            height:  widget.cardHeight,
          );
        },
      ),
    );
  }
}

class _BrandCard extends StatefulWidget {
  final BrandAdData ad;
  final double      scale;
  final double      opacity;
  final double      height;

  const _BrandCard({
    required this.ad,
    required this.scale,
    required this.opacity,
    required this.height,
  });

  @override
  State<_BrandCard> createState() => _BrandCardState();
}

class _BrandCardState extends State<_BrandCard>
    with SingleTickerProviderStateMixin {

  late AnimationController _shimmerCtrl;
  late AnimationController _floatCtrl;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _shimmerCtrl = AnimationController(
      vsync:    this,
      duration: const Duration(seconds: 3),
    )..repeat();

    _floatCtrl = AnimationController(
      vsync:    this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _shimmerCtrl.dispose();
    _floatCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      scale:    widget.scale * (_isPressed ? 0.95 : 1.0),
      duration: const Duration(milliseconds: 200),
      curve:    Curves.easeOut,
      child: AnimatedOpacity(
        opacity:  widget.opacity,
        duration: const Duration(milliseconds: 200),
        child: GestureDetector(
          onTapDown:   (_) => setState(() => _isPressed = true),
          onTapUp:     (_) => setState(() => _isPressed = false),
          onTapCancel: ()  => setState(() => _isPressed = false),
          onTap:       widget.ad.onTap,
          child: Container(
            width:  260,
            height: widget.height,
            margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 10),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: widget.ad.gradientColors,
                begin:  Alignment.topLeft,
                end:    Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: widget.ad.gradientColors[0].withOpacity(0.3),
                  blurRadius:   15,
                  offset:       const Offset(0, 8),
                  spreadRadius: 1),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Stack(
                children: [
                  // Shimmer effect
                  AnimatedBuilder(
                    animation: _shimmerCtrl,
                    builder: (context, _) {
                      return Positioned(
                        left: _shimmerCtrl.value * 400 - 100,
                        top:  -50, bottom: -50,
                        child: Transform.rotate(
                          angle: 0.3,
                          child: Container(
                            width: 80,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.white.withOpacity(0),
                                  Colors.white.withOpacity(0.15),
                                  Colors.white.withOpacity(0),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),

                  // Background floating emoji
                  AnimatedBuilder(
                    animation: _floatCtrl,
                    builder: (context, _) {
                      return Positioned(
                        right: -20 + (_floatCtrl.value * 10),
                        top:   -20 + (_floatCtrl.value * 8),
                        child: Opacity(
                          opacity: 0.2,
                          child: Text(widget.ad.emoji,
                            style: const TextStyle(fontSize: 180)),
                        ),
                      );
                    },
                  ),

                  // Sponsored badge
                  Positioned(
                    top: 12, left: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.3))),
                      child: const Text('SPONSORED',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1)),
                    ),
                  ),

                  // Floating emoji small
                  Positioned(
                    top: 50, right: 20,
                    child: AnimatedBuilder(
                      animation: _floatCtrl,
                      builder: (context, _) {
                        return Transform.translate(
                          offset: Offset(0, _floatCtrl.value * 8),
                          child: Text(widget.ad.emoji,
                            style: const TextStyle(fontSize: 70)),
                        );
                      },
                    ),
                  ),

                  // Content
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(widget.ad.brandName.toUpperCase(),
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 2)),
                        const SizedBox(height: 6),
                        Text(widget.ad.tagline,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            height: 1.2)),
                        const SizedBox(height: 14),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 10),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(30),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 4,
                                offset: const Offset(0, 2)),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(widget.ad.ctaText,
                                style: TextStyle(
                                  color: widget.ad.gradientColors[0],
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13)),
                              const SizedBox(width: 4),
                              Icon(Icons.arrow_forward,
                                color: widget.ad.gradientColors[0], size: 16),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Vertical sticky cards (parallax style for home feed)
class VerticalStickyBrandCard extends StatelessWidget {
  final BrandAdData ad;
  final double      height;

  const VerticalStickyBrandCard({
    super.key,
    required this.ad,
    this.height = 180,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      height: height,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: ad.gradientColors,
          begin:  Alignment.topLeft,
          end:    Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: ad.gradientColors[0].withOpacity(0.25),
            blurRadius:   12,
            offset:       const Offset(0, 6)),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: ad.onTap,
          child: Stack(
            children: [
              Positioned(
                right: -30, top: -30,
                child: Opacity(
                  opacity: 0.25,
                  child: Text(ad.emoji,
                    style: const TextStyle(fontSize: 200))),
              ),
              Positioned(
                top: 12, left: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.25),
                    borderRadius: BorderRadius.circular(6)),
                  child: const Text('AD',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1)),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment:  MainAxisAlignment.end,
                  children: [
                    Text(ad.brandName.toUpperCase(),
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 2)),
                    const SizedBox(height: 4),
                    Text(ad.tagline,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        height: 1.1)),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20)),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(ad.ctaText,
                            style: TextStyle(
                              color: ad.gradientColors[0],
                              fontWeight: FontWeight.bold,
                              fontSize: 12)),
                          const SizedBox(width: 4),
                          Icon(Icons.arrow_forward,
                            color: ad.gradientColors[0], size: 14),
                        ],
                      ),
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
}

/// Demo brand data - replace with your sponsors
class DemoBrandAds {
  static List<BrandAdData> getAds() {
    return [
      BrandAdData(
        id:        'amul',
        brandName: 'Amul',
        tagline:   'Fresh Dairy\nDelivered Daily',
        ctaText:   'Shop Amul',
        emoji:     '🥛',
        gradientColors: const [Color(0xFFE91E63), Color(0xFFAD1457)],
      ),
      BrandAdData(
        id:        'nestle',
        brandName: 'Nestle',
        tagline:   'Premium\nQuality Foods',
        ctaText:   'Explore',
        emoji:     '☕',
        gradientColors: const [Color(0xFF795548), Color(0xFF4E342E)],
      ),
      BrandAdData(
        id:        'parle',
        brandName: 'Parle',
        tagline:   'Taste of\nChildhood',
        ctaText:   'Buy Now',
        emoji:     '🍪',
        gradientColors: const [Color(0xFFFF9800), Color(0xFFE65100)],
      ),
      BrandAdData(
        id:        'britannia',
        brandName: 'Britannia',
        tagline:   'Healthy &\nDelicious',
        ctaText:   'View All',
        emoji:     '🍞',
        gradientColors: const [Color(0xFFFF5722), Color(0xFFBF360C)],
      ),
      BrandAdData(
        id:        'mother-dairy',
        brandName: 'Mother Dairy',
        tagline:   'Pure & Fresh\nEvery Day',
        ctaText:   'Shop',
        emoji:     '🧀',
        gradientColors: const [Color(0xFF2196F3), Color(0xFF0D47A1)],
      ),
      BrandAdData(
        id:        'maggi',
        brandName: 'Maggi',
        tagline:   '2-Minute\nHappiness',
        ctaText:   'Try Now',
        emoji:     '🍜',
        gradientColors: const [Color(0xFFFFC107), Color(0xFFFF6F00)],
      ),
    ];
  }
}
