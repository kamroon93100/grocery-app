import 'package:flutter/material.dart';
import 'dart:async';
import '../constants/app_constants.dart';

/// ═══════════════════════════════════════════════════════
/// PREMIUM PROMO BANNER
/// Auto-scrolling carousel + offer chips below
/// Pixel-perfect, no overflow bugs
/// ═══════════════════════════════════════════════════════

class PremiumPromoBanner extends StatefulWidget {
  const PremiumPromoBanner({super.key});

  @override
  State<PremiumPromoBanner> createState() => _PremiumPromoBannerState();
}

class _PremiumPromoBannerState extends State<PremiumPromoBanner> {
  final PageController _ctrl = PageController();
  int    _current = 0;
  Timer? _timer;

  final List<_PromoData> _promos = [
    _PromoData(
      title:    'FREE Delivery',
      subtitle: 'On orders above ${AppConstants.currency}50',
      cta:      'SHOP NOW',
      emoji:    '🚚',
      colors:   [Color(0xFF12B76A), Color(0xFF0E8A52)],
    ),
    _PromoData(
      title:    'Use WELCOME10',
      subtitle: '10% off your first order',
      cta:      'APPLY CODE',
      emoji:    '🎉',
      colors:   [Color(0xFFFF7A45), Color(0xFFE5603A)],
    ),
    _PromoData(
      title:    'Fresh Daily',
      subtitle: 'Farm to door in 30 mins',
      cta:      'ORDER NOW',
      emoji:    '🌿',
      colors:   [Color(0xFF0BA5EC), Color(0xFF0086C9)],
    ),
    _PromoData(
      title:    'Save More',
      subtitle: 'Up to 25% on daily essentials',
      cta:      'VIEW DEALS',
      emoji:    '💰',
      colors:   [Color(0xFFF79009), Color(0xFFDC6803)],
    ),
  ];

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (_ctrl.hasClients) {
        _current = (_current + 1) % _promos.length;
        _ctrl.animateToPage(
          _current,
          duration: const Duration(milliseconds: 400),
          curve:    Curves.easeOutCubic,
        );
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // CAROUSEL
        Container(
          height:  140,
          margin:  const EdgeInsets.fromLTRB(16, 12, 16, 0),
          child: PageView.builder(
            controller:    _ctrl,
            itemCount:     _promos.length,
            onPageChanged: (i) => setState(() => _current = i),
            itemBuilder: (context, index) {
              final promo = _promos[index];
              return Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: promo.colors,
                    begin:  Alignment.topLeft,
                    end:    Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Stack(
                  clipBehavior: Clip.hardEdge,
                  children: [
                    // Background emoji (decorative)
                    Positioned(
                      right:  -10,
                      bottom: -10,
                      child: Opacity(
                        opacity: 0.2,
                        child: Text(promo.emoji,
                          style: const TextStyle(fontSize: 110)),
                      ),
                    ),
                    // Content
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment:  MainAxisAlignment.center,
                        children: [
                          Text(promo.title,
                            style: const TextStyle(
                              color:      Colors.white,
                              fontSize:   22,
                              fontWeight: FontWeight.w800,
                              height:     1.2)),
                          const SizedBox(height: 4),
                          Text(promo.subtitle,
                            style: TextStyle(
                              color:    Colors.white.withOpacity(0.9),
                              fontSize: 13,
                              fontWeight: FontWeight.w400)),
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(promo.cta,
                              style: TextStyle(
                                color:      promo.colors[0],
                                fontSize:   12,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.5)),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),

        // PAGE INDICATORS
        Padding(
          padding: const EdgeInsets.only(top: 10, bottom: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(_promos.length, (i) {
              final isActive = _current == i;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                margin:   const EdgeInsets.symmetric(horizontal: 3),
                width:    isActive ? 18 : 6,
                height:   6,
                decoration: BoxDecoration(
                  color: isActive
                      ? const Color(0xFF12B76A)
                      : const Color(0xFFD0D5DD),
                  borderRadius: BorderRadius.circular(3),
                ),
              );
            }),
          ),
        ),
      ],
    );
  }
}

class _PromoData {
  final String       title;
  final String       subtitle;
  final String       cta;
  final String       emoji;
  final List<Color>  colors;

  const _PromoData({
    required this.title,
    required this.subtitle,
    required this.cta,
    required this.emoji,
    required this.colors,
  });
}

/// ═══════════════════════════════════════════════════════
/// OFFER CHIPS (Horizontal scroll below banner)
/// ═══════════════════════════════════════════════════════

class OfferChipsRow extends StatelessWidget {
  const OfferChipsRow({super.key});

  @override
  Widget build(BuildContext context) {
    final offers = [
      _OfferChip(
        emoji: '🥦', name: 'Fresh Veggies',
        offer: '20% OFF',
        bgColor: const Color(0xFFE7F8EF),
        textColor: const Color(0xFF12B76A)),
      _OfferChip(
        emoji: '🍎', name: 'Fresh Fruits',
        offer: '15% OFF',
        bgColor: const Color(0xFFFEF3F2),
        textColor: const Color(0xFFF04438)),
      _OfferChip(
        emoji: '🥛', name: 'Daily Essentials',
        offer: 'Up to 25%',
        bgColor: const Color(0xFFEFF8FF),
        textColor: const Color(0xFF0BA5EC)),
      _OfferChip(
        emoji: '🍗', name: 'Meat & Fish',
        offer: '10% OFF',
        bgColor: const Color(0xFFFFF4ED),
        textColor: const Color(0xFFFF7A45)),
      _OfferChip(
        emoji: '🍪', name: 'Snacks',
        offer: 'Buy 2 Get 1',
        bgColor: const Color(0xFFF9F5FF),
        textColor: const Color(0xFF7A5AF8)),
    ];

    return SizedBox(
      height: 95,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        physics: const BouncingScrollPhysics(),
        itemCount: offers.length,
        itemBuilder: (context, index) {
          final o = offers[index];
          return Container(
            width:  140,
            margin: const EdgeInsets.symmetric(horizontal: 4),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: o.bgColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment:  MainAxisAlignment.spaceBetween,
              children: [
                Text(o.emoji, style: const TextStyle(fontSize: 26)),
                Text(o.name,
                  style: TextStyle(
                    color:      o.textColor,
                    fontSize:   13,
                    fontWeight: FontWeight.w700)),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: o.textColor,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(o.offer,
                    style: const TextStyle(
                      color:      Colors.white,
                      fontSize:   9,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.3)),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _OfferChip {
  final String emoji;
  final String name;
  final String offer;
  final Color  bgColor;
  final Color  textColor;

  const _OfferChip({
    required this.emoji,
    required this.name,
    required this.offer,
    required this.bgColor,
    required this.textColor,
  });
}

/// ═══════════════════════════════════════════════════════
/// URGENCY BANNER (Ending Soon)
/// ═══════════════════════════════════════════════════════

class UrgencyBanner extends StatelessWidget {
  const UrgencyBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8F0),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFFDDB5)),
      ),
      child: Row(
        children: [
          Container(
            width: 36, height: 36,
            decoration: const BoxDecoration(
              color: Color(0xFFF79009),
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Text('🔥', style: TextStyle(fontSize: 18))),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Ending Soon!',
                  style: TextStyle(
                    color:      Color(0xFFF79009),
                    fontSize:   14,
                    fontWeight: FontWeight.w700)),
                Text('Get groceries delivered in 30 mins',
                  style: TextStyle(
                    color:    const Color(0xFF667085),
                    fontSize: 12)),
              ],
            ),
          ),
          const Text('🔥', style: TextStyle(fontSize: 22)),
        ],
      ),
    );
  }
}

/// ═══════════════════════════════════════════════════════
/// FREE DELIVERY STICKY BOTTOM BANNER
/// ═══════════════════════════════════════════════════════

class FreeDeliveryBanner extends StatelessWidget {
  const FreeDeliveryBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFFE7F8EF),
            const Color(0xFFD1FAE5),
          ],
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('FREE DELIVERY ',
            style: TextStyle(
              color:      const Color(0xFF12B76A),
              fontSize:   13,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.3)),
          Text('on orders above ${AppConstants.currency}50',
            style: const TextStyle(
              color:    Color(0xFF344054),
              fontSize: 13,
              fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}
