import 'package:flutter/material.dart';
import 'dart:async';
import '../../models/order_model.dart';
import '../../services/order_service.dart';

class OrderTrackingScreen extends StatefulWidget {
  final String orderId;
  const OrderTrackingScreen({super.key, required this.orderId});

  @override
  State<OrderTrackingScreen> createState() => _OrderTrackingScreenState();
}

class _OrderTrackingScreenState extends State<OrderTrackingScreen> {
  OrderModel? _order;
  bool        _loading = true;
  Timer?      _timer;

  final List<Map<String, dynamic>> _stages = [
    {'status':'pending',          'title':'Order Placed',      'icon':Icons.shopping_bag_outlined,    'desc':'Your order has been placed'},
    {'status':'confirmed',        'title':'Order Confirmed',   'icon':Icons.check_circle_outline,     'desc':'Store accepted your order'},
    {'status':'preparing',        'title':'Preparing',         'icon':Icons.restaurant,               'desc':'Items being prepared'},
    {'status':'ready',            'title':'Ready',             'icon':Icons.done_all,                 'desc':'Order ready for pickup'},
    {'status':'out_for_delivery', 'title':'Out for Delivery',  'icon':Icons.local_shipping_outlined,  'desc':'On the way to you'},
    {'status':'delivered',        'title':'Delivered',         'icon':Icons.check_circle,             'desc':'Order delivered successfully'},
  ];

  @override
  void initState() {
    super.initState();
    _loadOrder();
    // Auto refresh every 10 seconds
    _timer = Timer.periodic(const Duration(seconds: 10), (_) => _loadOrder());
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _loadOrder() async {
    final order = await OrderService().getOrderById(widget.orderId);
    if (mounted) {
      setState(() {
        _order   = order;
        _loading = false;
      });
    }
  }

  int _getCurrentStageIndex() {
    if (_order == null) return 0;
    return _stages.indexWhere((s) => s['status'] == _order!.status);
  }

  Color _getStageColor(int index, int current) {
    if (index <  current) return Colors.green;
    if (index == current) return Colors.orange;
    return Colors.grey.shade300;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text('Track Order'),
        actions: [
          IconButton(
            icon:     const Icon(Icons.refresh),
            onPressed: _loadOrder,
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: Colors.green))
          : _order == null
              ? const Center(child: Text('Order not found'))
              : _buildContent(),
    );
  }

  Widget _buildContent() {
    final order   = _order!;
    final current = _getCurrentStageIndex();
    final isCancelled = order.status == 'cancelled';

    return RefreshIndicator(
      onRefresh: _loadOrder,
      color: Colors.green,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Order Header Card
            Container(
              width:   double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end:   Alignment.bottomRight,
                  colors: [Colors.green, Color(0xFF66BB6A)],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Order',
                            style: TextStyle(color: Colors.white70, fontSize: 12)),
                          Text('#${order.orderNumber}',
                            style: const TextStyle(
                              color:      Colors.white,
                              fontSize:   20,
                              fontWeight: FontWeight.bold)),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color:        Colors.white,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          order.status.replaceAll('_', ' ').toUpperCase(),
                          style: TextStyle(
                            color: isCancelled ? Colors.red : Colors.green,
                            fontWeight: FontWeight.bold,
                            fontSize:   11)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(children: [
                    const Icon(Icons.access_time, color: Colors.white70, size: 16),
                    const SizedBox(width: 6),
                    Text('Estimated: ${order.estimatedTime} mins',
                      style: const TextStyle(color: Colors.white, fontSize: 13)),
                  ]),
                  const SizedBox(height: 4),
                  Row(children: [
                    const Icon(Icons.shopping_basket_outlined,
                      color: Colors.white70, size: 16),
                    const SizedBox(width: 6),
                    Text('${order.items.length} items',
                      style: const TextStyle(color: Colors.white, fontSize: 13)),
                  ]),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Tracking Timeline
            if (!isCancelled) ...[
              const Text('Order Status',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color:        Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: List.generate(_stages.length, (index) {
                    final stage    = _stages[index];
                    final isActive = index <= current;
                    final isCurrent= index == current;
                    final isLast   = index == _stages.length - 1;

                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Column(
                          children: [
                            Container(
                              width:  40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: _getStageColor(index, current),
                                shape: BoxShape.circle,
                                boxShadow: isCurrent ? [
                                  BoxShadow(
                                    color: Colors.orange.withOpacity(0.4),
                                    blurRadius: 12,
                                    spreadRadius: 2)
                                ] : null,
                              ),
                              child: Icon(
                                stage['icon'],
                                color: isActive
                                    ? Colors.white : Colors.grey.shade500,
                                size:  20),
                            ),
                            if (!isLast)
                              Container(
                                width:  2,
                                height: 50,
                                color: index < current
                                    ? Colors.green : Colors.grey.shade300),
                          ],
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(stage['title'],
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize:   15,
                                    color: isActive
                                        ? Colors.black : Colors.grey.shade500)),
                                Text(stage['desc'],
                                  style: TextStyle(
                                    color: Colors.grey.shade600, fontSize: 12)),
                                if (isCurrent)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 4),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: Colors.orange.shade50,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: const Text('Current Status',
                                        style: TextStyle(
                                          color: Colors.orange,
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold)),
                                    ),
                                  ),
                                const SizedBox(height: 30),
                              ],
                            ),
                          ),
                        ),
                      ],
                    );
                  }),
                ),
              ),
            ] else
              Container(
                width:   double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color:        Colors.red.shade50,
                  borderRadius: BorderRadius.circular(16),
                  border:       Border.all(color: Colors.red),
                ),
                child: Column(
                  children: [
                    const Icon(Icons.cancel, color: Colors.red, size: 50),
                    const SizedBox(height: 12),
                    const Text('Order Cancelled',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold,
                        color: Colors.red)),
                    if (order.cancelReason != null) ...[
                      const SizedBox(height: 8),
                      Text('Reason: ${order.cancelReason}',
                        style: const TextStyle(color: Colors.red)),
                    ],
                  ],
                ),
              ),

            const SizedBox(height: 20),

            // Items
            const Text('Order Items',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                color:        Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: order.items.map((item) {
                  final isLast = item == order.items.last;
                  return Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      border: isLast ? null : Border(
                        bottom: BorderSide(color: Colors.grey.shade200)),
                    ),
                    child: Row(
                      children: [
                        Text(item.productImage,
                          style: const TextStyle(fontSize: 32)),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(item.productName,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 14)),
                              Text('\$${item.price.toStringAsFixed(2)} x ${item.quantity}',
                                style: TextStyle(
                                  color: Colors.grey.shade600, fontSize: 12)),
                            ],
                          ),
                        ),
                        Text('\$${item.subtotal.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.green, fontSize: 15)),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),

            const SizedBox(height: 20),

            // Delivery Address
            const Text('Delivery Address',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Container(
              width:   double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color:        Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.location_on, color: Colors.green),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(order.deliveryAddress['name'] ?? '',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 14)),
                        Text(order.deliveryAddress['phone'] ?? '',
                          style: TextStyle(
                            color: Colors.grey.shade700, fontSize: 13)),
                        const SizedBox(height: 4),
                        Text(
                          '${order.deliveryAddress['line1']}, ${order.deliveryAddress['city']}',
                          style: TextStyle(
                            color: Colors.grey.shade600, fontSize: 13)),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Bill Details
            const Text('Bill Details',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color:        Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  _billRow('Subtotal',  '\$${order.subtotal.toStringAsFixed(2)}'),
                  if (order.couponDiscount > 0)
                    _billRow('Discount (${order.couponCode})',
                      '-\$${order.couponDiscount.toStringAsFixed(2)}',
                      color: Colors.green),
                  _billRow('Delivery Fee',
                    order.deliveryFee > 0
                        ? '\$${order.deliveryFee.toStringAsFixed(2)}'
                        : 'FREE',
                    color: order.deliveryFee == 0 ? Colors.green : null),
                  _billRow('Tax', '\$${order.tax.toStringAsFixed(2)}'),
                  const Divider(),
                  _billRow('Total Paid', '\$${order.totalAmount.toStringAsFixed(2)}',
                    bold: true, large: true),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color:        Colors.green.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.money, color: Colors.green, size: 18),
                        const SizedBox(width: 6),
                        Text(order.paymentMethod.toUpperCase(),
                          style: const TextStyle(
                            color: Colors.green, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _billRow(String label, String value,
    {Color? color, bool bold = false, bool large = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
            style: TextStyle(
              fontSize:   large ? 16 : 14,
              fontWeight: bold ? FontWeight.bold : FontWeight.normal,
              color:      large ? Colors.black : Colors.grey.shade700)),
          Text(value,
            style: TextStyle(
              fontSize:   large ? 18 : 14,
              fontWeight: bold ? FontWeight.bold : FontWeight.w500,
              color:      color ?? (large ? Colors.green : null))),
        ],
      ),
    );
  }
}
