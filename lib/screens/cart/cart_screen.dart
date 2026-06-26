import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/cart_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/order_provider.dart';
import '../../services/order_service.dart';
import '../../services/whatsapp_service.dart';
import '../../constants/app_constants.dart';
import '../../services/notification_service.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    return Scaffold(
      appBar: AppBar(
        title: Text('Cart (${cart.itemCount} items)'),
        actions: [
          if (cart.items.isNotEmpty)
            TextButton.icon(
              onPressed: () {
                cart.clearCart();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Cart cleared'),
                    backgroundColor: Colors.red),
                );
              },
              icon:  const Icon(Icons.delete_outline, color: Colors.white),
              label: const Text('Clear', style: TextStyle(color: Colors.white)),
            ),
        ],
      ),
      body: cart.items.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.shopping_cart_outlined,
                    size: 80, color: Colors.grey.shade300),
                  const SizedBox(height: 16),
                  Text('Your cart is empty',
                    style: TextStyle(fontSize: 20, color: Colors.grey.shade500)),
                  const SizedBox(height: 8),
                  Text('Add items to get started',
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade400)),
                ],
              ),
            )
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    padding:   const EdgeInsets.all(12),
                    itemCount: cart.items.length,
                    itemBuilder: (context, index) {
                      final item = cart.items[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            children: [
                              Text(item.product.displayImage,
                                style: const TextStyle(fontSize: 40)),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(item.product.name,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold, fontSize: 15)),
                                    Text(item.product.categoryName ?? '',
                                      style: TextStyle(
                                        color:    Colors.grey.shade500,
                                        fontSize: 12)),
                                    Text(
                                      '\$${item.product.finalPrice.toStringAsFixed(2)} each',
                                      style: const TextStyle(color: Colors.green)),
                                  ],
                                ),
                              ),
                              Column(
                                children: [
                                  Text('\$${item.subtotal.toStringAsFixed(2)}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize:   16,
                                      color:      Colors.green)),
                                  Row(
                                    children: [
                                      IconButton(
                                        icon: const Icon(
                                          Icons.remove_circle_outline,
                                          color: Colors.green),
                                        onPressed: () => context
                                            .read<CartProvider>()
                                            .decreaseQuantity(item.product.id),
                                        constraints: const BoxConstraints(),
                                        padding: const EdgeInsets.all(4),
                                      ),
                                      Text('${item.quantity}',
                                        style: const TextStyle(
                                          fontSize:   16,
                                          fontWeight: FontWeight.bold)),
                                      IconButton(
                                        icon: const Icon(
                                          Icons.add_circle_outline,
                                          color: Colors.green),
                                        onPressed: () => context
                                            .read<CartProvider>()
                                            .increaseQuantity(item.product.id),
                                        constraints: const BoxConstraints(),
                                        padding: const EdgeInsets.all(4),
                                      ),
                                    ],
                                  ),
                                  TextButton(
                                    onPressed: () => context
                                        .read<CartProvider>()
                                        .removeItem(item.product.id),
                                    style: TextButton.styleFrom(
                                      foregroundColor: Colors.red,
                                      padding:         EdgeInsets.zero,
                                    ),
                                    child: const Text('Remove',
                                      style: TextStyle(fontSize: 12)),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                _buildSummary(context, cart),
              ],
            ),
    );
  }

  Widget _buildSummary(BuildContext context, CartProvider cart) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [BoxShadow(color: Colors.grey.shade300, blurRadius: 10)],
      ),
      child: Column(
        children: [
          _row('Subtotal',  '\$${cart.subtotal.toStringAsFixed(2)}'),
          if (cart.couponDiscount > 0)
            _row('Coupon (${cart.couponCode})',
              '-\$${cart.couponDiscount.toStringAsFixed(2)}',
              color: Colors.green),
          _row('Delivery',
            cart.deliveryFee > 0
                ? '\$${cart.deliveryFee.toStringAsFixed(2)}'
                : 'FREE',
            color: cart.deliveryFee == 0 ? Colors.green : null),
          _row('Tax (${AppConstants.taxPercent.toInt()}%)',
            '\$${cart.tax.toStringAsFixed(2)}'),
          const Divider(),
          _row('Total', '\$${cart.totalAmount.toStringAsFixed(2)}',
            bold: true, large: true),
          const SizedBox(height: 14),
          // COD + WhatsApp badges
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color:        Colors.green.shade50,
                    borderRadius: BorderRadius.circular(10),
                    border:       Border.all(color: Colors.green.shade200),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.money, color: Colors.green, size: 18),
                      SizedBox(width: 6),
                      Text('Cash on Delivery',
                        style: TextStyle(color: Colors.green,
                          fontWeight: FontWeight.bold, fontSize: 12)),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color:        Colors.teal.shade50,
                    borderRadius: BorderRadius.circular(10),
                    border:       Border.all(color: Colors.teal.shade200),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.message, color: Colors.teal, size: 18),
                      SizedBox(width: 6),
                      Text('WhatsApp Alert',
                        style: TextStyle(color: Colors.teal,
                          fontWeight: FontWeight.bold, fontSize: 12)),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          SizedBox(
            width:  double.infinity,
            height: 55,
            child: ElevatedButton.icon(
              icon:  const Icon(Icons.shopping_bag_outlined),
              label: const Text('Proceed to Checkout',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              onPressed: () => _showCheckout(context, cart),
            ),
          ),
        ],
      ),
    );
  }

  Widget _row(String label, String value,
    {Color? color, bool bold = false, bool large = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
            style: TextStyle(
              fontSize:   large ? 18 : 14,
              fontWeight: bold ? FontWeight.bold : FontWeight.normal)),
          Text(value,
            style: TextStyle(
              fontSize:   large ? 20 : 14,
              fontWeight: bold ? FontWeight.bold : FontWeight.normal,
              color:      color ?? (bold ? Colors.green : null))),
        ],
      ),
    );
  }

  void _showCheckout(BuildContext context, CartProvider cart) {
    final nameCtrl    = TextEditingController();
    final phoneCtrl   = TextEditingController();
    final addressCtrl = TextEditingController();
    final cityCtrl    = TextEditingController();
    final notesCtrl   = TextEditingController();
    final couponCtrl  = TextEditingController();
    final auth        = context.read<AuthProvider>();

    nameCtrl.text  = auth.userName;
    phoneCtrl.text = auth.userPhone;

    showModalBottomSheet(
      context:            context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => StatefulBuilder(
        builder: (context, setS) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 20, right: 20, top: 24,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize:       MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Checkout',
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                    IconButton(
                      onPressed: () => Navigator.pop(ctx),
                      icon: const Icon(Icons.close)),
                  ],
                ),
                const Divider(),
                const Text('📍 Delivery Details',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                const SizedBox(height: 12),
                _buildField(nameCtrl,    'Full Name *',       Icons.person_outline),
                const SizedBox(height: 10),
                _buildField(phoneCtrl,   'Phone Number *',    Icons.phone_outlined,
                  type: TextInputType.phone),
                const SizedBox(height: 10),
                TextField(
                  controller: addressCtrl,
                  maxLines:   2,
                  decoration: InputDecoration(
                    labelText:  'Delivery Address *',
                    prefixIcon: const Icon(Icons.location_on_outlined,
                      color: Colors.green),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 10),
                _buildField(cityCtrl, 'City *', Icons.location_city_outlined),
                const SizedBox(height: 10),
                // Coupon
                TextField(
                  controller: couponCtrl,
                  decoration: InputDecoration(
                    labelText:  'Coupon Code (optional)',
                    prefixIcon: const Icon(Icons.discount_outlined,
                      color: Colors.green),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                    suffixIcon: TextButton(
                      onPressed: () async {
                        if (couponCtrl.text.isEmpty) return;
                        final result = await OrderService().validateCoupon(
                          couponCtrl.text.trim().toUpperCase(),
                          cart.subtotal,
                        );
                        if (result['success'] == true) {
                          final disc = double.parse(
                            result['data']['discount'].toString());
                          context.read<CartProvider>().applyCoupon(
                            couponCtrl.text.trim().toUpperCase(), disc);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                '✅ Coupon applied! -\$${disc.toStringAsFixed(2)}'),
                              backgroundColor: Colors.green,
                            ),
                          );
                          setS(() {});
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(result['message'] ?? 'Invalid coupon'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      },
                      child: const Text('Apply',
                        style: TextStyle(color: Colors.green,
                          fontWeight: FontWeight.bold)),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                _buildField(notesCtrl, 'Order Notes (optional)', Icons.note_outlined),
                const SizedBox(height: 16),
                // Payment COD
                Container(
                  width:   double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color:        Colors.green.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border:       Border.all(color: Colors.green),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.money, color: Colors.green, size: 30),
                      SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Cash on Delivery',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize:   16,
                              color:      Colors.green)),
                          Text('Pay when you receive your order',
                            style: TextStyle(color: Colors.grey, fontSize: 12)),
                        ],
                      ),
                      Spacer(),
                      Icon(Icons.check_circle, color: Colors.green),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                // WhatsApp info
                Container(
                  width:   double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color:        Colors.teal.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border:       Border.all(color: Colors.teal.shade200),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.message, color: Colors.teal),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Order details will be sent to store via WhatsApp',
                          style: TextStyle(color: Colors.teal, fontSize: 13)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                // Order Summary
                Container(
                  width:   double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color:        Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border:       Border.all(color: Colors.grey.shade200),
                  ),
                  child: Column(
                    children: [
                      _summaryRow('Items',    '${cart.itemCount}'),
                      _summaryRow('Subtotal', '\$${cart.subtotal.toStringAsFixed(2)}'),
                      if (cart.couponDiscount > 0)
                        _summaryRow('Discount',
                          '-\$${cart.couponDiscount.toStringAsFixed(2)}',
                          color: Colors.green),
                      _summaryRow('Delivery',
                        cart.deliveryFee > 0
                            ? '\$${cart.deliveryFee.toStringAsFixed(2)}'
                            : 'FREE',
                        color: cart.deliveryFee == 0 ? Colors.green : null),
                      _summaryRow('Tax', '\$${cart.tax.toStringAsFixed(2)}'),
                      const Divider(),
                      _summaryRow('Total',
                        '\$${cart.totalAmount.toStringAsFixed(2)}',
                        bold: true),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                // Place Order Button
                SizedBox(
                  width:  double.infinity,
                  height: 60,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                    ),
                    onPressed: () async {
                      if (nameCtrl.text.trim().isEmpty) {
                        _showSnack(context, 'Enter your name'); return;
                      }
                      if (phoneCtrl.text.trim().isEmpty) {
                        _showSnack(context, 'Enter phone number'); return;
                      }
                      if (addressCtrl.text.trim().isEmpty) {
                        _showSnack(context, 'Enter delivery address'); return;
                      }
                      if (cityCtrl.text.trim().isEmpty) {
                        _showSnack(context, 'Enter city'); return;
                      }

                      final orderProvider = context.read<OrderProvider>();
                      final result = await orderProvider.placeOrder(
                        items: cart.items,
                        deliveryAddress: {
                          'name':    nameCtrl.text.trim(),
                          'phone':   phoneCtrl.text.trim(),
                          'line1':   addressCtrl.text.trim(),
                          'city':    cityCtrl.text.trim(),
                          'state':   'State',
                          'pincode': '000000',
                          'country': 'India',
                        },
                        paymentMethod: 'cod',
                        couponCode:    cart.couponCode,
                        notes:         notesCtrl.text.trim(),
                      );

                      if (!context.mounted) return;

                      if (result['success'] == true) {
                        final order = result['data']?['order'];
                        cart.clearCart();
                        Navigator.pop(ctx);
                        Navigator.pop(context);

                        // Send WhatsApp to store
                        if (order != null) {
                          try {
                            await WhatsAppService().sendOrderToStore(
                              order,
                              nameCtrl.text.trim(),
                              phoneCtrl.text.trim(),
                              '${addressCtrl.text.trim()}, ${cityCtrl.text.trim()}',
                            );
                          } catch (_) {}
                        }

                        NotificationService().showOrderPlacedNotification(
                            order?['orderNumber'] ?? '',
                            cart.totalAmount,
                          );
                          _showSuccess(context, result);
                      } else {
                        _showSnack(context,
                          result['message'] ?? 'Order failed', error: true);
                      }
                    },
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.shopping_bag_outlined),
                        SizedBox(width: 8),
                        Text('Place Order - Cash on Delivery',
                          style: TextStyle(
                            fontSize:   18,
                            fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildField(TextEditingController ctrl, String label, IconData icon,
    {TextInputType type = TextInputType.text}) {
    return TextField(
      controller:  ctrl,
      keyboardType: type,
      decoration: InputDecoration(
        labelText:  label,
        prefixIcon: Icon(icon, color: Colors.green),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Widget _summaryRow(String label, String value,
    {Color? color, bool bold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
            style: TextStyle(
              fontWeight: bold ? FontWeight.bold : FontWeight.normal)),
          Text(value,
            style: TextStyle(
              fontWeight: bold ? FontWeight.bold : FontWeight.normal,
              color:      color ?? (bold ? Colors.green : null),
              fontSize:   bold ? 16 : 14)),
        ],
      ),
    );
  }

  void _showSnack(BuildContext context, String msg, {bool error = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content:         Text(msg),
        backgroundColor: error ? Colors.red : Colors.green,
      ),
    );
  }

  void _showSuccess(BuildContext context, Map<String, dynamic> result) {
    final order = result['data']?['order'];
    showDialog(
      context:            context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding:    const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color:  Colors.green.shade50,
                shape:  BoxShape.circle,
                border: Border.all(color: Colors.green, width: 2),
              ),
              child: const Icon(Icons.check_circle,
                color: Colors.green, size: 60),
            ),
            const SizedBox(height: 16),
            const Text('Order Placed!',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            if (order != null)
              Text('Order #${order['orderNumber'] ?? ''}',
                style: const TextStyle(color: Colors.grey, fontSize: 13)),
            const SizedBox(height: 12),
            Container(
              padding:    const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color:        Colors.green.shade50,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Column(children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.money, color: Colors.green),
                    SizedBox(width: 8),
                    Text('Cash on Delivery',
                      style: TextStyle(
                        color:      Colors.green,
                        fontWeight: FontWeight.bold)),
                  ],
                ),
                SizedBox(height: 4),
                Text('Pay when you receive your order',
                  style: TextStyle(color: Colors.grey, fontSize: 12)),
              ]),
            ),
            const SizedBox(height: 12),
            Container(
              padding:    const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color:        Colors.teal.shade50,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.message, color: Colors.teal, size: 18),
                  SizedBox(width: 6),
                  Text('Store notified via WhatsApp',
                    style: TextStyle(color: Colors.teal, fontSize: 13)),
                ],
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'We will deliver your order soon!\nThank you for shopping with us.',
              textAlign: TextAlign.center,
              style:     TextStyle(color: Colors.grey),
            ),
          ],
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK - Track My Order'),
            ),
          ),
        ],
      ),
    );
  }
}

