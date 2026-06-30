import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/app_constants.dart';
import '../models/product_model.dart';
import '../providers/cart_provider.dart';
import '../providers/product_provider.dart';
import '../screens/product/product_detail_screen.dart';

class PremiumSearchEntry extends StatelessWidget {
  const PremiumSearchEntry({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => showPremiumSearch(context),
      child: Container(
        height: 62,
        margin: const EdgeInsets.fromLTRB(20, 14, 20, 18),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: const Color(0xffeef0f2),
          borderRadius: BorderRadius.circular(22),
        ),
        child: Row(
          children: [
            Icon(Icons.search_rounded, color: Colors.grey.shade600),
            const SizedBox(width: 12),
            Text(
              'Search for fruits, milk, bread...',
              style: TextStyle(color: Colors.grey.shade600, fontSize: 17, fontWeight: FontWeight.w700),
            ),
            const Spacer(),
            Icon(Icons.mic_none_rounded, color: Colors.grey.shade600),
          ],
        ),
      ),
    );
  }
}

void showPremiumSearch(BuildContext context) {
  showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'Search',
    barrierColor: Colors.black.withOpacity(.18),
    transitionDuration: const Duration(milliseconds: 220),
    pageBuilder: (_, __, ___) => const _PremiumSearchOverlay(),
    transitionBuilder: (_, anim, __, child) {
      return Transform.translate(
        offset: Offset(0, 36 * (1 - anim.value)),
        child: Opacity(opacity: anim.value, child: child),
      );
    },
  );
}

class _PremiumSearchOverlay extends StatefulWidget {
  const _PremiumSearchOverlay();

  @override
  State<_PremiumSearchOverlay> createState() => _PremiumSearchOverlayState();
}

class _PremiumSearchOverlayState extends State<_PremiumSearchOverlay> {
  final TextEditingController _ctrl = TextEditingController();
  Timer? _debounce;
  String _query = '';

  static final List<String> _recent = [];
  final List<String> _trending = const [
    'Milk',
    'Bread',
    'Banana',
    'Rice',
    'Atta',
    'Chips',
    'Cold drinks',
    'Paneer',
  ];

  @override
  void dispose() {
    _debounce?.cancel();
    _ctrl.dispose();
    super.dispose();
  }

  void _onChanged(String v) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      if (mounted) setState(() => _query = v.trim());
    });
  }

  void _submit(String q) {
    final clean = q.trim();
    if (clean.isEmpty) return;
    _recent.removeWhere((x) => x.toLowerCase() == clean.toLowerCase());
    _recent.insert(0, clean);
    if (_recent.length > 10) _recent.removeLast();
    setState(() => _query = clean);
    _ctrl.text = clean;
  }

  List<ProductModel> _results(List<ProductModel> products) {
    final q = _query.toLowerCase();
    if (q.isEmpty) return [];
    return products.where((p) {
      final hay = [
        p.name,
        p.description,
        p.unit,
        p.categoryName ?? '',
        p.categoryIcon ?? '',
        ...p.tags,
      ].join(' ').toLowerCase();
      return hay.contains(q);
    }).take(40).toList();
  }

  @override
  Widget build(BuildContext context) {
    final products = context.watch<ProductProvider>().products;
    final results = _results(products);

    return SafeArea(
      child: Material(
        color: Colors.transparent,
        child: Container(
          margin: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xfff6f7f9),
            borderRadius: BorderRadius.circular(30),
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 56,
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: const Color(0xffeeeeee)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.search_rounded, color: Color(0xff0c8f43)),
                            const SizedBox(width: 10),
                            Expanded(
                              child: TextField(
                                controller: _ctrl,
                                autofocus: true,
                                onChanged: _onChanged,
                                onSubmitted: _submit,
                                decoration: const InputDecoration(
                                  border: InputBorder.none,
                                  hintText: 'Search groceries',
                                  hintStyle: TextStyle(fontWeight: FontWeight.w700, color: Colors.grey),
                                ),
                              ),
                            ),
                            if (_ctrl.text.isNotEmpty)
                              IconButton(
                                icon: const Icon(Icons.close_rounded),
                                onPressed: () {
                                  _ctrl.clear();
                                  setState(() => _query = '');
                                },
                              ),
                            const Icon(Icons.mic_none_rounded, color: Colors.grey),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel', style: TextStyle(fontWeight: FontWeight.w900, color: Color(0xff0c8f43))),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: _query.isEmpty
                    ? _SuggestionView(
                        title: _recent.isEmpty ? 'Trending searches' : 'Recent searches',
                        items: _recent.isEmpty ? _trending : _recent,
                        onTap: _submit,
                      )
                    : results.isEmpty
                        ? const _NoSearchResult()
                        : ListView.separated(
                            padding: const EdgeInsets.fromLTRB(14, 8, 14, 24),
                            itemCount: results.length,
                            separatorBuilder: (_, __) => const SizedBox(height: 10),
                            itemBuilder: (_, i) => _SearchResultTile(
                              product: results[i],
                              query: _query,
                              onOpen: () {
                                _submit(_query);
                                Navigator.pop(context);
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (_) => ProductDetailScreen(product: results[i])),
                                );
                              },
                            ),
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SuggestionView extends StatelessWidget {
  final String title;
  final List<String> items;
  final ValueChanged<String> onTap;

  const _SuggestionView({required this.title, required this.items, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 12, 18, 24),
      children: [
        Text(title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900)),
        const SizedBox(height: 14),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: items.map((x) {
            return ActionChip(
              label: Text(x, style: const TextStyle(fontWeight: FontWeight.w800)),
              avatar: const Icon(Icons.trending_up_rounded, size: 18),
              onPressed: () => onTap(x),
              backgroundColor: Colors.white,
              side: const BorderSide(color: Color(0xffeeeeee)),
            );
          }).toList(),
        ),
      ],
    );
  }
}

class _SearchResultTile extends StatelessWidget {
  final ProductModel product;
  final String query;
  final VoidCallback onOpen;

  const _SearchResultTile({required this.product, required this.query, required this.onOpen});

  TextSpan _highlight(String text) {
    final lower = text.toLowerCase();
    final q = query.toLowerCase();
    final idx = lower.indexOf(q);
    if (idx < 0 || q.isEmpty) {
      return TextSpan(text: text, style: const TextStyle(color: Color(0xff111827), fontWeight: FontWeight.w900));
    }
    return TextSpan(
      children: [
        TextSpan(text: text.substring(0, idx)),
        TextSpan(text: text.substring(idx, idx + q.length), style: const TextStyle(color: Color(0xff0c8f43), fontWeight: FontWeight.w900)),
        TextSpan(text: text.substring(idx + q.length)),
      ],
      style: const TextStyle(color: Color(0xff111827), fontWeight: FontWeight.w900),
    );
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onOpen,
      borderRadius: BorderRadius.circular(22),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: const Color(0xffeeeeee)),
        ),
        child: Row(
          children: [
            Container(
              width: 72,
              height: 72,
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(color: const Color(0xfff8fafc), borderRadius: BorderRadius.circular(18)),
              child: product.displayImage.startsWith('http')
                  ? Image.network(product.displayImage, fit: BoxFit.contain, errorBuilder: (_, __, ___) => const Icon(Icons.image_outlined))
                  : Center(child: Text(product.displayImage, style: const TextStyle(fontSize: 30))),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RichText(maxLines: 2, overflow: TextOverflow.ellipsis, text: _highlight(product.name)),
                  const SizedBox(height: 4),
                  Text(product.unit, style: TextStyle(color: Colors.grey.shade600, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 6),
                  Text('${AppConstants.currency}${product.price.toStringAsFixed(0)}', style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w900)),
                ],
              ),
            ),
            Consumer<CartProvider>(
              builder: (context, cart, _) {
                final qty = cart.getQuantity(product.id);
                return SizedBox(
                  width: 78,
                  height: 36,
                  child: qty <= 0
                      ? OutlinedButton(
                          onPressed: () => cart.addItem(product),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xff0c8f43),
                            side: const BorderSide(color: Color(0xff0c8f43)),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: const Text('ADD', style: TextStyle(fontWeight: FontWeight.w900)),
                        )
                      : Container(
                          decoration: BoxDecoration(color: const Color(0xff0c8f43), borderRadius: BorderRadius.circular(12)),
                          child: Row(
                            children: [
                              Expanded(child: InkWell(onTap: () => cart.decreaseQuantity(product.id), child: const Icon(Icons.remove, color: Colors.white, size: 17))),
                              Text('$qty', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900)),
                              Expanded(child: InkWell(onTap: () => cart.increaseQuantity(product.id), child: const Icon(Icons.add, color: Colors.white, size: 17))),
                            ],
                          ),
                        ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _NoSearchResult extends StatelessWidget {
  const _NoSearchResult();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.search_off_rounded, size: 70, color: Colors.grey.shade400),
            const SizedBox(height: 14),
            const Text('No products found', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900)),
            const SizedBox(height: 8),
            Text('Try milk, bread, rice, snacks or browse categories.', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey.shade600, fontWeight: FontWeight.w700)),
          ],
        ),
      ),
    );
  }
}
