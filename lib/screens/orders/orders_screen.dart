import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/order_provider.dart';
import '../../providers/cart_provider.dart';
import '../../services/product_service.dart';
import '../../services/invoice_service.dart';
import '../../widgets/premium_order_card.dart';
import 'order_tracking_screen.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<OrderProvider>().loadMyOrders();
    });
  }

  Color _statusColor(String s) {
    switch (s) {
      case 'pending':
        return Colors.orange;
      case 'confirmed':
        return Colors.blue;
      case 'preparing':
        return Colors.purple;
      case 'ready':
        return Colors.teal;
      case 'picked_up':
        return Colors.indigo;
      case 'out_for_delivery':
        return Colors.cyan;
      case 'delivered':
        return const Color(0xff0c8f43);
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _statusIcon(String s) {
    switch (s) {
      case 'pending':
        return Icons.hourglass_empty_rounded;
      case 'confirmed':
        return Icons.check_circle_outline_rounded;
      case 'preparing':
        return Icons.inventory_2_outlined;
      case 'ready':
        return Icons.done_all_rounded;
      case 'picked_up':
        return Icons.directions_bike_rounded;
      case 'out_for_delivery':
        return Icons.local_shipping_outlined;
      case 'delivered':
        return Icons.verified_rounded;
      case 'cancelled':
        return Icons.cancel_outlined;
      default:
        return Icons.info_outline_rounded;
    }
  }

  Future<void> _reorder(BuildContext context, dynamic order) async {
    final productService = ProductService();
    int added = 0;

    for (final item in order.items) {
      final product = await productService.getProductById(item.productId);
      if (product != null && product.inStock) {
        for (int i = 0; i < item.quantity; i++) {
          if (!context.mounted) return;
          context.read<CartProvider>().addItem(product);
        }
        added++;
      }
    }

    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$added items added to cart'),
        backgroundColor: const Color(0xff0c8f43),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final orders = context.watch<OrderProvider>();

    return Scaffold(
      backgroundColor: const Color(0xfff6f7f9),
      body: SafeArea(
        child: orders.isLoading
            ? const Center(child: CircularProgressIndicator(color: Color(0xff0c8f43)))
            : orders.orders.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 96,
                            height: 96,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(30),
                              border: Border.all(color: const Color(0xffeeeeee)),
                            ),
                            child: Icon(
                              Icons.receipt_long_outlined,
                              size: 48,
                              color: Colors.grey.shade400,
                            ),
                          ),
                          const SizedBox(height: 18),
                          const Text(
                            'No orders yet',
                            style: TextStyle(
                              fontSize: 23,
                              fontWeight: FontWeight.w900,
                              color: Color(0xff111827),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Start shopping to place your first order',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: () => context.read<OrderProvider>().loadMyOrders(),
                    color: const Color(0xff0c8f43),
                    child: CustomScrollView(
                      slivers: [
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(18, 18, 18, 10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Orders',
                                  style: TextStyle(
                                    fontSize: 31,
                                    height: 1,
                                    fontWeight: FontWeight.w900,
                                    color: Color(0xff111827),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Track and manage your deliveries',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SliverPadding(
                          padding: const EdgeInsets.fromLTRB(16, 12, 16, 120),
                          sliver: SliverList(
                            delegate: SliverChildBuilderDelegate(
                              (context, index) {
                                final o = orders.orders[index];

                                return PremiumOrderCard(
                                  order: o,
                                  statusColor: _statusColor(o.status),
                                  statusIcon: _statusIcon(o.status),
                                  onTrack: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => OrderTrackingScreen(orderId: o.id),
                                    ),
                                  ),
                                  onInvoice: () async {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Generating invoice...')),
                                    );
                                    await InvoiceService().downloadInvoice(o);
                                  },
                                  onReorder: () => _reorder(context, o),
                                );
                              },
                              childCount: orders.orders.length,
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


