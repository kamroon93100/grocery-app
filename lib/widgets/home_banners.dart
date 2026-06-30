import 'package:flutter/material.dart';
import 'dart:async';
import '../constants/app_constants.dart';

class HomeBanners extends StatefulWidget {
  const HomeBanners({super.key});
  @override
  State<HomeBanners> createState() => _HomeBannersState();
}

class _HomeBannersState extends State<HomeBanners> {
  final PageController _ctrl = PageController();
  int   _currentPage         = 0;
  Timer? _timer;

  final List<Map<String, dynamic>> _banners = [
    {
      'title':    'Fresh Vegetables',
      'subtitle': 'Free delivery above ${AppConstants.currency}${AppConstants.freeDeliveryAbove.toInt()}',
      'icon':     'ðŸ¥¦',
      'colors':   [Color(0xFF4CAF50), Color(0xFF66BB6A)],
    },
    {
      'title':    'Use Code WELCOME10',
      'subtitle': 'Get 10% off your order',
      'icon':     'ðŸŽ«',
      'colors':   [Color(0xFFFF6B6B), Color(0xFFEE5A6F)],
    },
    {
      'title':    'Fresh Fruits',
      'subtitle': '15% off on Grapes',
      'icon':     'ðŸ‡',
      'colors':   [Color(0xFFFF9800), Color(0xFFFFA726)],
    },
    {
      'title':    'Save BIG50',
      'subtitle': '50% off above ${AppConstants.currency}100',
      'icon':     'ðŸ’°',
      'colors':   [Color(0xFF9C27B0), Color(0xFFAB47BC)],
    },
    {
      'title':    'Cash on Delivery',
      'subtitle': 'Pay when you receive',
      'icon':     'ðŸ’µ',
      'colors':   [Color(0xFF2196F3), Color(0xFF42A5F5)],
    },
  ];

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (_currentPage < _banners.length - 1) {
        _currentPage++;
      } else {
        _currentPage = 0;
      }
      if (_ctrl.hasClients) {
        _ctrl.animateToPage(_currentPage,
          duration: const Duration(milliseconds: 500),
          curve:    Curves.easeInOut);
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
        SizedBox(
          height: 150,
          child: PageView.builder(
            controller: _ctrl,
            itemCount:  _banners.length,
            onPageChanged: (page) => setState(() => _currentPage = page),
            itemBuilder: (context, index) {
              final b = _banners[index];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end:   Alignment.bottomRight,
                      colors: List<Color>.from(b['colors']),
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: (b['colors'][0] as Color).withOpacity(0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 4)),
                    ],
                  ),
                  child: Stack(
                    children: [
                      Positioned(
                        right:  -10, top: -10,
                        child: Opacity(
                          opacity: 0.3,
                          child: Text(b['icon'],
                            style: const TextStyle(fontSize: 150)),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(b['title'],
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.bold)),
                            const SizedBox(height: 6),
                            Text(b['subtitle'],
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14)),
                            const SizedBox(height: 12),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text('SHOP NOW',
                                style: TextStyle(
                                  color: b['colors'][0] as Color,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold)),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(_banners.length, (index) =>
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width:  _currentPage == index ? 24 : 8,
              height: 8,
              decoration: BoxDecoration(
                color: _currentPage == index
                    ? Colors.green : Colors.grey.shade300,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ),
      ],
    );
  }
}


