import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/product_provider.dart';
import '../../widgets/home/product_card_v6.dart';

class KohliSearchScreen extends StatefulWidget {
  const KohliSearchScreen({super.key});

  @override
  State<KohliSearchScreen> createState() => _KohliSearchScreenState();
}

class _KohliSearchScreenState extends State<KohliSearchScreen> {
  final controller = TextEditingController();
  Timer? debounce;

  static const quick = [
    'milk',
    'apple',
    'bread',
    'paneer',
    'banana',
    'eggs',
    'tomato',
    'potato',
  ];

  @override
  void dispose() {
    debounce?.cancel();
    controller.dispose();
    super.dispose();
  }

  void runSearch(String value) {
    debounce?.cancel();
    debounce = Timer(const Duration(milliseconds: 250), () {
      context.read<ProductProvider>().searchProducts(value.trim());
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ProductProvider>();
    final hasQuery = controller.text.trim().isNotEmpty;
    final results = provider.searchResults;

    return Scaffold(
      backgroundColor: const Color(0xfff6f7f9),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
                child: Row(
                  children: [
                    IconButton.filled(
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: const Color(0xff111827),
                      ),
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back_rounded),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Container(
                        height: 52,
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: const Color(0xffeeeeee)),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x0d000000),
                              blurRadius: 18,
                              spreadRadius: -5,
                              offset: Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.search_rounded, color: Colors.grey),
                            const SizedBox(width: 10),
                            Expanded(
                              child: TextField(
                                controller: controller,
                                autofocus: true,
                                onChanged: (v) {
                                  setState(() {});
                                  runSearch(v);
                                },
                                decoration: const InputDecoration(
                                  border: InputBorder.none,
                                  hintText: 'Search for groceries',
                                  hintStyle: TextStyle(
                                    color: Colors.grey,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                style: const TextStyle(fontWeight: FontWeight.w800),
                              ),
                            ),
                            if (hasQuery)
                              GestureDetector(
                                onTap: () {
                                  controller.clear();
                                  context.read<ProductProvider>().clearSearch();
                                  setState(() {});
                                },
                                child: const Icon(Icons.close_rounded, color: Colors.grey),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (!hasQuery)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(18, 10, 18, 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Popular searches',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          color: Color(0xff111827),
                        ),
                      ),
                      const SizedBox(height: 14),
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: quick.map((q) {
                          return ActionChip(
                            backgroundColor: Colors.white,
                            side: const BorderSide(color: Color(0xffeeeeee)),
                            label: Text(
                              q,
                              style: const TextStyle(fontWeight: FontWeight.w800),
                            ),
                            onPressed: () {
                              controller.text = q;
                              setState(() {});
                              context.read<ProductProvider>().searchProducts(q);
                            },
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              )
            else if (provider.isSearching)
              const SliverFillRemaining(
                child: Center(child: CircularProgressIndicator()),
              )
            else if (results.isEmpty)
              SliverFillRemaining(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('🔍', style: TextStyle(fontSize: 54)),
                        const SizedBox(height: 12),
                        const Text(
                          'No products found',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Try searching milk, apple, bread or snacks',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(14, 8, 14, 110),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 190,
                    mainAxisExtent: 262,
                    crossAxisSpacing: 14,
                    mainAxisSpacing: 14,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => ProductCardV6(product: results[index]),
                    childCount: results.length,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

