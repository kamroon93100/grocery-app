import 'dart:async';
import 'package:flutter/material.dart';

class KohliBannerCarousel extends StatefulWidget {
  const KohliBannerCarousel({super.key});

  @override
  State<KohliBannerCarousel> createState() => _KohliBannerCarouselState();
}

class _KohliBannerCarouselState extends State<KohliBannerCarousel> {
  final PageController _controller = PageController(viewportFraction: 1.0);
  int _index = 0;
  Timer? _timer;

  final banners = const [
    _BannerData(
      title: 'Fresh groceries',
      subtitle: 'Delivered in 10 mins',
      emoji: '🥬',
      colors: [Color(0xff0c8f43), Color(0xff18b56b)],
    ),
    _BannerData(
      title: 'Daily essentials',
      subtitle: 'Milk, bread, eggs & more',
      emoji: '🥛',
      colors: [Color(0xff2563eb), Color(0xff60a5fa)],
    ),
    _BannerData(
      title: 'Big savings',
      subtitle: 'Up to 40% off today',
      emoji: '🔥',
      colors: [Color(0xfff97316), Color(0xffffb703)],
    ),
  ];

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 3), (_) {
      if (!_controller.hasClients) return;
      final next = (_index + 1) % banners.length;
      _controller.animateToPage(
        next,
        duration: const Duration(milliseconds: 450),
        curve: Curves.easeOutCubic,
      );
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 164,
      child: Column(
        children: [
          Expanded(
            child: PageView.builder(
              controller: _controller,
              itemCount: banners.length,
              onPageChanged: (i) => setState(() => _index = i),
              itemBuilder: (_, i) {
                final b = banners[i];
                return Container(
                  margin: const EdgeInsets.fromLTRB(16, 10, 16, 10),
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: b.colors),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x18000000),
                        blurRadius: 16,
                        offset: Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              b.title,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 25,
                                fontWeight: FontWeight.w900,
                                height: 1.05,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              b.subtitle,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: const Text(
                                'Shop now',
                                style: TextStyle(
                                  color: Color(0xff0c8f43),
                                  fontWeight: FontWeight.w900,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(b.emoji, style: const TextStyle(fontSize: 58)),
                    ],
                  ),
                );
              },
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              banners.length,
              (i) => AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                margin: const EdgeInsets.symmetric(horizontal: 3),
                height: 6,
                width: _index == i ? 18 : 6,
                decoration: BoxDecoration(
                  color: _index == i ? const Color(0xff0c8f43) : Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BannerData {
  final String title;
  final String subtitle;
  final String emoji;
  final List<Color> colors;

  const _BannerData({
    required this.title,
    required this.subtitle,
    required this.emoji,
    required this.colors,
  });
}

