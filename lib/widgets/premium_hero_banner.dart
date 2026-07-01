import 'package:flutter/material.dart';

class PremiumHeroBanner extends StatefulWidget {
  const PremiumHeroBanner({super.key});

  @override
  State<PremiumHeroBanner> createState() => _PremiumHeroBannerState();
}

class _PremiumHeroBannerState extends State<PremiumHeroBanner> {
  final PageController _controller = PageController(viewportFraction: .92);
  int _index = 0;

  final banners = const [
    _BannerData(
      title: 'Fresh groceries\nin minutes',
      subtitle: 'Fruits, vegetables, milk & daily essentials',
      icon: '🥦',
      colors: [Color(0xff0c8f43), Color(0xff19b46b)],
    ),
    _BannerData(
      title: 'Save more on\nevery order',
      subtitle: 'Coupons, offers and free delivery deals',
      icon: '🎁',
      colors: [Color(0xffff7a1a), Color(0xffffb703)],
    ),
    _BannerData(
      title: 'Daily essentials\nat your door',
      subtitle: 'Rice, atta, snacks, drinks and more',
      icon: '🛒',
      colors: [Color(0xff2563eb), Color(0xff38bdf8)],
    ),
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 178,
          child: PageView.builder(
            controller: _controller,
            itemCount: banners.length,
            onPageChanged: (i) => setState(() => _index = i),
            itemBuilder: (_, i) {
              final b = banners[i];
              return AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                margin: EdgeInsets.fromLTRB(i == 0 ? 16 : 8, 8, i == banners.length - 1 ? 16 : 8, 8),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: b.colors, begin: Alignment.topLeft, end: Alignment.bottomRight),
                  borderRadius: BorderRadius.circular(32),
                  boxShadow: const [
                    BoxShadow(color: Color(0x22000000), blurRadius: 28, spreadRadius: -8, offset: Offset(0, 16)),
                  ],
                ),
                child: Stack(
                  children: [
                    Positioned(
                      right: -8,
                      bottom: -16,
                      child: Text(
                        b.icon,
                        style: const TextStyle(fontSize: 92),
                      ),
                    ),
                    Positioned(
                      right: 16,
                      top: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(color: Colors.white.withOpacity(.20), borderRadius: BorderRadius.circular(999)),
                        child: const Text('Kohli Store', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 11)),
                      ),
                    ),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * .56,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            b.title,
                            style: const TextStyle(color: Colors.white, fontSize: 27, height: 1.02, fontWeight: FontWeight.w900),
                          ),
                          const SizedBox(height: 9),
                          Text(
                            b.subtitle,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13, height: 1.25),
                          ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 8),
                            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(999)),
                            child: Text(
                              i == 1 ? 'View offers' : 'Shop now',
                              style: TextStyle(color: b.colors.first, fontWeight: FontWeight.w900, fontSize: 12),
                            ),
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
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            banners.length,
            (i) => AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: _index == i ? 18 : 6,
              height: 6,
              decoration: BoxDecoration(
                color: _index == i ? const Color(0xff0c8f43) : Colors.grey.shade300,
                borderRadius: BorderRadius.circular(999),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _BannerData {
  final String title;
  final String subtitle;
  final String icon;
  final List<Color> colors;

  const _BannerData({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.colors,
  });
}
