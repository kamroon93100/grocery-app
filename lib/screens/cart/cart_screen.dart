import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/cart_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/order_provider.dart';
import '../../services/order_service.dart';
import '../../services/whatsapp_service.dart';
import '../../services/notification_service.dart';
import '../../services/location_service.dart';
import '../../constants/app_constants.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    return Scaffold(
      appBar: AppBar(title: Text('Cart (${cart.itemCount} items)')),
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
                ],
              ),
            )
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: cart.items.length,
                    itemBuilder: (context, index) {
                      final item = cart.items[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 10),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            children: [
                              item.product.isNetworkImage
                                  ? ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: Image.network(item.product.displayImage,
                                        height: 50, width: 50, fit: BoxFit.cover,
                                        errorBuilder: (_, __, ___) =>
                                          const Icon(Icons.image, size: 40)),
                                    )
                                  : Text(item.product.displayImage.isNotEmpty
                                      ? item.product.displayImage : '🛒',
                                      style: const TextStyle(fontSize: 40)),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(item.product.name,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold, fontSize: 14)),
                                    Text('${AppConstants.currency}${item.product.finalPrice.toStringAsFixed(2)}',
                                      style: const TextStyle(color: Colors.green)),
                                  ],
                                ),
                              ),
                              Column(
                                children: [
                                  Text('${AppConstants.currency}${item.subtotal.toStringAsFixed(2)}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.green)),
                                  Row(children: [
                                    IconButton(
                                      icon: const Icon(Icons.remove_circle_outline,
                                        color: Colors.green),
                                      onPressed: () => context.read<CartProvider>()
                                        .decreaseQuantity(item.product.id),
                                      constraints: const BoxConstraints(),
                                      padding: const EdgeInsets.all(4)),
                                    Text('${item.quantity}',
                                      style: const TextStyle(fontWeight: FontWeight.bold)),
                                    IconButton(
                                      icon: const Icon(Icons.add_circle_outline,
                                        color: Colors.green),
                                      onPressed: () => context.read<CartProvider>()
                                        .increaseQuantity(item.product.id),
                                      constraints: const BoxConstraints(),
                                      padding: const EdgeInsets.all(4)),
                                  ]),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [BoxShadow(color: Colors.grey.shade300, blurRadius: 10)]),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Total',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          Text('${AppConstants.currency}${cart.totalAmount.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 22, fontWeight: FontWeight.bold,
                              color: Colors.green)),
                        ],
                      ),
                      const SizedBox(height: 14),
                      SizedBox(
                        width: double.infinity,
                        height: 55,
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.shopping_bag_outlined),
                          label: const Text('Proceed to Checkout',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          onPressed: () => _showCheckout(context, cart),
                        ),
                      ),
                    ],
                  ),
                ),
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
    final auth        = context.read<AuthProvider>();

    nameCtrl.text  = auth.userName;
    phoneCtrl.text = auth.userPhone;

    double? latitude;
    double? longitude;
    String? googleMapsLink;
    bool detecting = false;

    showModalBottomSheet(
      context:            context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => StatefulBuilder(
        builder: (context, setS) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 20, right: 20, top: 24),
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

                // GPS Location Button
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: googleMapsLink != null
                        ? Colors.green.shade50 : Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: googleMapsLink != null ? Colors.green : Colors.blue),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Icon(
                            googleMapsLink != null
                                ? Icons.check_circle : Icons.my_location,
                            color: googleMapsLink != null ? Colors.green : Colors.blue,
                            size: 28),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  googleMapsLink != null
                                      ? '✅ Live Location Captured'
                                      : 'Use Live Location',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: googleMapsLink != null
                                        ? Colors.green : Colors.blue,
                                    fontSize: 14)),
                                Text(
                                  googleMapsLink != null
                                      ? 'Store will see exact location'
                                      : 'For accurate delivery',
                                  style: const TextStyle(color: Colors.grey, fontSize: 11)),
                              ],
                            ),
                          ),
                          if (detecting)
                            const SizedBox(
                              width: 20, height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.blue))
                          else
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: googleMapsLink != null
                                    ? Colors.green : Colors.blue,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 8),
                              ),
                              onPressed: () async {
                                setS(() => detecting = true);
                                final location = await LocationService()
                                    .getCurrentLocation();
                                setS(() => detecting = false);

                                if (location != null) {
                                  latitude       = location['latitude'];
                                  longitude      = location['longitude'];
                                  googleMapsLink = location['googleMapsUrl'];
                                  addressCtrl.text = location['fullAddress'] ?? '';
                                  cityCtrl.text    = location['city'] ?? '';
                                  setS(() {});

                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('📍 Location captured!'),
                                        backgroundColor: Colors.green));
                                  }
                                } else {
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Could not get location - check GPS'),
                                        backgroundColor: Colors.red));
                                  }
                                }
                              },
                              child: Text(
                                googleMapsLink != null ? 'Update' : 'Detect',
                                style: const TextStyle(
                                  color: Colors.white, fontSize: 12)),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                const Text('📍 Delivery Details',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                const SizedBox(height: 12),
                _field(nameCtrl, 'Full Name *', Icons.person_outline),
                const SizedBox(height: 10),
                _field(phoneCtrl, 'Phone Number *', Icons.phone_outlined,
                  type: TextInputType.phone),
                const SizedBox(height: 10),
                TextField(
                  controller: addressCtrl,
                  maxLines:   2,
                  decoration: InputDecoration(
                    labelText: 'Delivery Address *',
                    prefixIcon: const Icon(Icons.location_on_outlined,
                      color: Colors.green),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 10),
                _field(cityCtrl, 'City *', Icons.location_city_outlined),
                const SizedBox(height: 10),
                _field(notesCtrl, 'Order Notes (optional)', Icons.note_outlined),
                const SizedBox(height: 16),

                // COD Box
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.green)),
                  child: const Row(
                    children: [
                      Icon(Icons.money, color: Colors.green, size: 28),
                      SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Cash on Delivery',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.green, fontSize: 14)),
                            Text('Pay when you receive',
                              style: TextStyle(color: Colors.grey, fontSize: 11)),
                          ],
                        ),
                      ),
                      Icon(Icons.check_circle, color: Colors.green),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // WhatsApp info
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.teal.shade50,
                    borderRadius: BorderRadius.circular(12)),
                  child: const Row(
                    children: [
                      Icon(Icons.send, color: Colors.teal, size: 20),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Order details auto-sent to store via WhatsApp with your location',
                          style: TextStyle(color: Colors.teal, fontSize: 12)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(12)),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Items'),
                          Text('${cart.itemCount}'),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Subtotal'),
                          Text('${AppConstants.currency}${cart.subtotal.toStringAsFixed(2)}'),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Delivery'),
                          Text(cart.deliveryFee > 0
                              ? '${AppConstants.currency}${cart.deliveryFee.toStringAsFixed(2)}'
                              : 'FREE',
                            style: TextStyle(
                              color: cart.deliveryFee == 0 ? Colors.green : null)),
                        ],
                      ),
                      const Divider(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Total',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          Text('${AppConstants.currency}${cart.totalAmount.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18, color: Colors.green)),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                SizedBox(
                  width: double.infinity,
                  height: 60,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                    ),
                    onPressed: () async {
                      if (nameCtrl.text.trim().isEmpty ||
                          phoneCtrl.text.trim().isEmpty ||
                          addressCtrl.text.trim().isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Fill all required fields'),
                            backgroundColor: Colors.red));
                        return;
                      }

                      final orderProvider = context.read<OrderProvider>();
                      final result = await orderProvider.placeOrder(
                        items: cart.items,
                        deliveryAddress: {
                          'name':    nameCtrl.text.trim(),
                          'phone':   phoneCtrl.text.trim(),
                          'line1':   addressCtrl.text.trim(),
                          'city':    cityCtrl.text.trim().isEmpty
                              ? 'City' : cityCtrl.text.trim(),
                          'state':   'State',
                          'pincode': '000000',
                          'country': 'India',
                          'latitude':  latitude,
                          'longitude': longitude,
                        },
                        paymentMethod: 'cod',
                        couponCode:    cart.couponCode,
                        notes:         notesCtrl.text.trim(),
                      );

                      if (!context.mounted) return;
                      if (result['success'] == true) {
                        final order    = result['data']?['order'];
                        final orderNum = order?['orderNumber'] ?? '';
                        final totalAmt = cart.totalAmount;

                        cart.clearCart();
                        Navigator.pop(ctx);
                        Navigator.pop(context);

                        // Auto-send to store WhatsApp
                        try {
                          if (order != null) {
                            await WhatsAppService().sendOrderToStore(
                              order: orderProvider.orders.isNotEmpty
                                  ? orderProvider.orders.first
                                  : null!,
                              customerName:   nameCtrl.text.trim(),
                              customerPhone:  phoneCtrl.text.trim(),
                              address:        '${addressCtrl.text.trim()}, ${cityCtrl.text.trim()}',
                              googleMapsLink: googleMapsLink,
                              latitude:       latitude,
                              longitude:      longitude,
                            );
                          }
                        } catch (_) {}

                        NotificationService().showOrderPlacedNotification(
                          orderNum, totalAmt);

                        _showSuccess(context, orderNum);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(result['message'] ?? 'Failed'),
                            backgroundColor: Colors.red));
                      }
                    },
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.send, color: Colors.white),
                        SizedBox(width: 8),
                        Text('Place Order & Notify Store',
                          style: TextStyle(
                            fontSize: 16, color: Colors.white,
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

  Widget _field(TextEditingController ctrl, String label, IconData icon,
    {TextInputType type = TextInputType.text}) {
    return TextField(
      controller:   ctrl,
      keyboardType: type,
      decoration: InputDecoration(
        labelText:  label,
        prefixIcon: Icon(icon, color: Colors.green),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _showSuccess(BuildContext context, String orderNum) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.green, width: 2)),
              child: const Icon(Icons.check_circle, color: Colors.green, size: 60),
            ),
            const SizedBox(height: 16),
            const Text('Order Placed!',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('Order #$orderNum',
              style: const TextStyle(color: Colors.grey, fontSize: 13)),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.teal.shade50,
                borderRadius: BorderRadius.circular(10)),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.send, color: Colors.teal),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Store notified via WhatsApp with your full details + live location',
                      style: TextStyle(color: Colors.teal, fontSize: 12))),
                ],
              ),
            ),
          ],
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Track Order')),
          ),
        ],
      ),
    );
  }
}
