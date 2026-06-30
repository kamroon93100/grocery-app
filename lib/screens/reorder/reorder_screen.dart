import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/order_provider.dart';
import '../../providers/cart_provider.dart';
import '../../services/product_service.dart';
import '../../constants/app_constants.dart';

class ReorderScreen extends StatefulWidget {
  const ReorderScreen({super.key});
  @override
  State<ReorderScreen> createState() => _ReorderScreenState();
}

class _ReorderScreenState extends State<ReorderScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<OrderProvider>().loadMyOrders();
    });
  }

  @override
  Widget build(BuildContext context) {
    final orders = context.watch<OrderProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Text('Reorder',
                style: TextStyle(
                  fontSize:   24,
                  fontWeight: FontWeight.w800,
                  color:      Color(0xFF101828),
                  letterSpacing: -0.3)),
            ),

            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text('Quickly reorder your past purchases',
                style: TextStyle(
                  fontSize: 14,
                  color:    Color(0xFF667085))),
            ),

            const SizedBox(height: 16),

            // Orders list
            Expanded(
              child: orders.isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF12B76A)))
                  : orders.orders.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 80, height: 80,
                                decoration: const BoxDecoration(
                                  color: Color(0xFFE7F8EF),
                                  shape: BoxShape.circle),
                                child: const Icon(Icons.shopping_bag_outlined,
                                  color: Color(0xFF12B76A), size: 36),
                              ),
                              const SizedBox(height: 16),
                              const Text('No past orders yet',
                                style: TextStyle(
                                  fontSize:   16,
                                  fontWeight: FontWeight.w600,
                                  color:      Color(0xFF101828))),
                              const SizedBox(height: 4),
                              const Text('Your order history will appear here',
                                style: TextStyle(
                                  fontSize: 13,
                                  color:    Color(0xFF667085))),
                            ],
                          ),
                        )
                      : RefreshIndicator(
                          color: const Color(0xFF12B76A),
                          onRefresh: () =>
                            context.read<OrderProvider>().loadMyOrders(),
                          child: ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            itemCount: orders.orders.length,
                            itemBuilder: (context, index) {
                              final order = orders.orders[index];
                              return Container(
                                margin: const EdgeInsets.only(bottom: 12),
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: const Color(0xFFE4E7EC)),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Order header
                                    Row(
                                      mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text('#${order.orderNumber}',
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w700,
                                            color: Color(0xFF101828))),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8, vertical: 3),
                                          decoration: BoxDecoration(
                                            color: order.isDelivered
                                                ? const Color(0xFFE7F8EF)
                                                : const Color(0xFFFFF4ED),
                                            borderRadius:
                                              BorderRadius.circular(100)),
                                          child: Text(
                                            order.status.toUpperCase(),
                                            style: TextStyle(
                                              fontSize: 10,
                                              fontWeight: FontWeight.w700,
                                              color: order.isDelivered
                                                  ? const Color(0xFF12B76A)
                                                  : const Color(0xFFF79009))),
                                        ),
                                      ],
                                    ),

                                    const SizedBox(height: 8),

                                    // Items summary
                                    Text(
                                      '${order.items.length} items  •  ${AppConstants.currency}${order.totalAmount.toStringAsFixed(0)}',
                                      style: const TextStyle(
                                        fontSize: 13,
                                        color:    Color(0xFF667085))),

                                    const SizedBox(height: 4),

                                    Text(
                                      order.createdAt.substring(0, 10),
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color:    Color(0xFF98A2B3))),

                                    const SizedBox(height: 12),

                                    // Reorder button
                                    SizedBox(
                                      width: double.infinity,
                                      height: 40,
                                      child: OutlinedButton.icon(
                                        icon: const Icon(Icons.refresh,
                                          size: 16,
                                          color: Color(0xFF12B76A)),
                                        label: const Text('Reorder',
                                          style: TextStyle(
                                            color: Color(0xFF12B76A),
                                            fontWeight: FontWeight.w600,
                                            fontSize: 13)),
                                        style: OutlinedButton.styleFrom(
                                          side: const BorderSide(
                                            color: Color(0xFF12B76A)),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                              BorderRadius.circular(8))),
                                        onPressed: () async {
                                          int added = 0;
                                          final ps = ProductService();
                                          for (final item in order.items) {
                                            final product = await ps
                                                .getProductById(item.productId);
                                            if (product != null &&
                                                product.inStock) {
                                              for (int i = 0;
                                                  i < item.quantity; i++) {
                                                context
                                                    .read<CartProvider>()
                                                    .addItem(product);
                                              }
                                              added++;
                                            }
                                          }
                                          if (context.mounted) {
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(SnackBar(
                                              content: Text(
                                                '$added items added to cart'),
                                              backgroundColor:
                                                const Color(0xFF12B76A)));
                                          }
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
            ),
          ],
        ),
      ),
    );
  }
}


