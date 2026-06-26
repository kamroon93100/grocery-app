import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/order_provider.dart';
import '../../models/order_model.dart';
import 'order_tracking_screen.dart';
import '../../providers/cart_provider.dart';
import '../../services/product_service.dart';

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
      case 'pending':          return Colors.orange;
      case 'confirmed':        return Colors.blue;
      case 'preparing':        return Colors.purple;
      case 'ready':            return Colors.teal;
      case 'picked_up':        return Colors.indigo;
      case 'out_for_delivery': return Colors.cyan;
      case 'delivered':        return Colors.green;
      case 'cancelled':        return Colors.red;
      default:                 return Colors.grey;
    }
  }

  IconData _statusIcon(String s) {
    switch (s) {
      case 'pending':          return Icons.hourglass_empty;
      case 'confirmed':        return Icons.check_circle_outline;
      case 'preparing':        return Icons.restaurant;
      case 'ready':            return Icons.done_all;
      case 'picked_up':        return Icons.directions_bike;
      case 'out_for_delivery': return Icons.local_shipping;
      case 'delivered':        return Icons.done_all;
      case 'cancelled':        return Icons.cancel_outlined;
      default:                 return Icons.info_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    final orders = context.watch<OrderProvider>();
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: orders.isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.green))
          : orders.orders.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.receipt_long_outlined,
                        size: 80, color: Colors.grey.shade300),
                      const SizedBox(height: 16),
                      Text('No orders yet',
                        style: TextStyle(fontSize: 20, color: Colors.grey.shade500)),
                      const SizedBox(height: 8),
                      Text('Start shopping to place orders',
                        style: TextStyle(color: Colors.grey.shade400)),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: () => context.read<OrderProvider>().loadMyOrders(),
                  color:     Colors.green,
                  child: ListView.builder(
                    padding:   const EdgeInsets.all(12),
                    itemCount: orders.orders.length,
                    itemBuilder: (context, index) {
                      final o = orders.orders[index];
                      return GestureDetector(
                        onTap: () => Navigator.push(context,
                          MaterialPageRoute(
                            builder: (_) => OrderTrackingScreen(orderId: o.id))),
                        child: Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('Order #${o.orderNumber}',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold, fontSize: 16)),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: _statusColor(o.status).withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(color: _statusColor(o.status)),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(_statusIcon(o.status),
                                            size: 14, color: _statusColor(o.status)),
                                          const SizedBox(width: 4),
                                          Text(o.status.replaceAll('_',' ').toUpperCase(),
                                            style: TextStyle(
                                              color: _statusColor(o.status),
                                              fontSize: 11,
                                              fontWeight: FontWeight.bold)),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const Divider(height: 20),
                                Row(
                                  children: [
                                    Icon(Icons.location_on_outlined,
                                      size: 16, color: Colors.grey),
                                    const SizedBox(width: 6),
                                    Expanded(
                                      child: Text(o.deliveryAddress['line1'] ?? '',
                                        style: const TextStyle(
                                          color: Colors.grey, fontSize: 13))),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Row(
                                  children: [
                                    Icon(Icons.shopping_bag_outlined,
                                      size: 16, color: Colors.grey),
                                    const SizedBox(width: 6),
                                    Text('${o.items.length} items',
                                      style: const TextStyle(
                                        color: Colors.grey, fontSize: 13)),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Row(
                                  children: [
                                    Icon(Icons.access_time_outlined,
                                      size: 16, color: Colors.grey),
                                    const SizedBox(width: 6),
                                    Text(o.createdAt.substring(0, 16),
                                      style: const TextStyle(
                                        color: Colors.grey, fontSize: 13)),
                                  ],
                                ),
                                const Divider(height: 20),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text('Total',
                                      style: TextStyle(fontSize: 15)),
                                    Text('\$${o.totalAmount.toStringAsFixed(2)}',
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.green)),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                SizedBox(
                                  width: double.infinity,
                                  child: OutlinedButton.icon(
                                    icon: const Icon(Icons.refresh),
                                    label: const Text('Re-order'),
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: Colors.blue,
                                      side: const BorderSide(color: Colors.blue)),
                                    onPressed: () async {
                                      final productService = ProductService();
                                      int added = 0;
                                      for (final item in o.items) {
                                        final product = await productService.getProductById(item.productId);
                                        if (product != null && product.inStock) {
                                          for (int i = 0; i < item.quantity; i++) {
                                            context.read<CartProvider>().addItem(product);
                                          }
                                          added++;
                                        }
                                      }
                                      if (context.mounted) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Text('$added items added to cart'),
                                            backgroundColor: Colors.green,
                                          ),
                                        );
                                      }
                                    },
                                  ),
                                ),
                                const SizedBox(height: 8),
                                SizedBox(
                                  width: double.infinity,
                                  child: OutlinedButton.icon(
                                    icon: const Icon(Icons.location_searching),
                                    label: const Text('Track Order'),
                                    onPressed: () => Navigator.push(context,
                                      MaterialPageRoute(builder: (_) =>
                                        OrderTrackingScreen(orderId: o.id))),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}

