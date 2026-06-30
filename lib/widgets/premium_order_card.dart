import 'package:flutter/material.dart';
import '../models/order_model.dart';
import '../constants/app_constants.dart';

class PremiumOrderCard extends StatelessWidget {
  final OrderModel order;
  final Color statusColor;
  final IconData statusIcon;
  final VoidCallback onTrack;
  final VoidCallback onInvoice;
  final VoidCallback onReorder;

  const PremiumOrderCard({
    super.key,
    required this.order,
    required this.statusColor,
    required this.statusIcon,
    required this.onTrack,
    required this.onInvoice,
    required this.onReorder,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Color(0x12000000),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            Row(
              children: [
                Expanded(
                  child: Text(
                    'Order #${order.orderNumber}',
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(.12),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(statusIcon, size: 14, color: statusColor),
                      const SizedBox(width: 6),
                      Text(
                        order.status.replaceAll('_', ' ').toUpperCase(),
                        style: TextStyle(
                          color: statusColor,
                          fontWeight: FontWeight.w800,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 14),

            Text(
              order.deliveryAddress['line1'] ?? '',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Colors.grey),
            ),

            const SizedBox(height: 12),

            Row(
              children: [
                const Icon(Icons.shopping_bag_outlined, size: 18),
                const SizedBox(width: 6),
                Text('${order.items.length} items'),
                const Spacer(),
                Text(
                  '${AppConstants.currency}${order.totalAmount.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 20,
                    color: Color(0xff0c8f43),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 18),

            Row(
              children: [

                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onInvoice,
                    icon: const Icon(Icons.download),
                    label: const Text('Invoice'),
                  ),
                ),

                const SizedBox(width: 10),

                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: onTrack,
                    icon: const Icon(Icons.location_searching),
                    label: const Text('Track'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xff0c8f43),
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),

              ],
            ),

            const SizedBox(height: 10),

            SizedBox(
              width: double.infinity,
              child: TextButton.icon(
                onPressed: onReorder,
                icon: const Icon(Icons.refresh),
                label: const Text('Re-order'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
