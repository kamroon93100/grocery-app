import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/cart_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/order_provider.dart';

import '../../services/whatsapp_service.dart';
import '../../services/notification_service.dart';
import '../../services/location_service.dart';
import '../../widgets/Cart_item_card.dart';
import '../../widgets/Cart_bill_card.dart';
import '../../widgets/sticky_checkout_bar.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();

    return Scaffold(
      backgroundColor: const Color(0xfff6f7f9),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xfff6f7f9),
        foregroundColor: const Color(0xff111827),
        title: Text(
          'Cart (${cart.itemCount} items)',
          style: const TextStyle(fontWeight: FontWeight.w900),
        ),
      ),
      body: cart.items.isEmpty
          ? const _CartEmptyState()
          : Stack(
              children: [
                ListView(
                  padding: const EdgeInsets.fromLTRB(14, 8, 14, 230),
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      margin: const EdgeInsets.only(bottom: 14),
                      decoration: BoxDecoration(
                        color: const Color(0xffe8f7ef),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: const Color(0xffd1f2df)),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.flash_on_rounded, color: Color(0xff0c8f43)),
                          SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Your order will be delivered in 10–15 mins',
                              style: TextStyle(fontWeight: FontWeight.w900, color: Color(0xff0c8f43)),
                            ),
                          ),
                        ],
                      ),
                    ),
                    ...cart.items.map(
                      (item) => CartItemCard(
                        item: item,
                        onAdd: () => context.read<CartProvider>().increaseQuantity(item.product.id),
                        onRemove: () => context.read<CartProvider>().decreaseQuantity(item.product.id),
                      ),
                    ),
                    CartBillCard(
                      subtotal: cart.subtotal,
                      delivery: cart.deliveryFee,
                      tax: cart.tax,
                      total: cart.totalAmount,
                    ),
                  ],
                ),
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: StickyCheckoutBar(
                    total: cart.totalAmount,
                    onCheckout: () => _showCheckout(context, cart),
                  ),
                ),
              ],
            ),
    );
  }

  void _showCheckout(BuildContext context, CartProvider cart) {
    final nameCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    final addressCtrl = TextEditingController();
    final cityCtrl = TextEditingController();
    final pincodeCtrl = TextEditingController();
    final stateCtrl = TextEditingController();
    final notesCtrl = TextEditingController();
    final auth = context.read<AuthProvider>();

    nameCtrl.text = auth.userName;
    phoneCtrl.text = auth.userPhone;

    final isProcessing = ValueNotifier<bool>(false);
    double? latitude;
    double? longitude;
    double? accuracy;
    String? googleMapsLink;
    bool detecting = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setS) {
          Future<void> detectLocation() async {
            setS(() => detecting = true);
            final result = await LocationService().getCurrentLocation();
            setS(() => detecting = false);

            if (!context.mounted) return;

            if (result.success) {
              setS(() {
                latitude = result.latitude;
                longitude = result.longitude;
                accuracy = result.accuracy;
                googleMapsLink = result.googleMapsUrl;
                addressCtrl.text = result.line1.isNotEmpty ? result.line1 : result.fullAddress;
                cityCtrl.text = result.city;
              });

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Location captured successfully'),
                  backgroundColor: Color(0xff0c8f43),
                ),
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(result.message), backgroundColor: Colors.red),
              );
            }
          }

          return DraggableScrollableSheet(
            initialChildSize: 0.88,
            minChildSize: 0.55,
            maxChildSize: 0.96,
            builder: (_, controller) {
              return Container(
                decoration: const BoxDecoration(
                  color: Color(0xfff6f7f9),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
                ),
                child: ListView(
                  controller: controller,
                  padding: const EdgeInsets.fromLTRB(18, 12, 18, 24),
                  children: [
                    Center(
                      child: Container(
                        width: 46,
                        height: 5,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(99),
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    Row(
                      children: [
                        const Text(
                          'Checkout',
                          style: TextStyle(fontSize: 28, height: 1, fontWeight: FontWeight.w900),
                        ),
                        const Spacer(),
                        IconButton(
                          onPressed: () => Navigator.pop(ctx),
                          icon: const Icon(Icons.close_rounded),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    _CheckoutCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Delivery Location', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: googleMapsLink != null ? const Color(0xffe8f7ef) : Colors.blue.shade50,
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(color: googleMapsLink != null ? const Color(0xff0c8f43) : Colors.blue.shade100),
                            ),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  backgroundColor: googleMapsLink != null ? const Color(0xff0c8f43) : Colors.blue,
                                  child: Icon(googleMapsLink != null ? Icons.check_rounded : Icons.my_location_rounded, color: Colors.white),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    googleMapsLink != null
                                        ? 'Location captured ${accuracy == null ? "" : "• ${accuracy!.toStringAsFixed(0)}m"}'
                                        : 'Use live location for accurate delivery',
                                    style: const TextStyle(fontWeight: FontWeight.w900),
                                  ),
                                ),
                                ElevatedButton(
                                  onPressed: detecting ? null : detectLocation,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xff0c8f43),
                                    foregroundColor: Colors.white,
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                  ),
                                  child: detecting
                                      ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                                      : Text(googleMapsLink != null ? 'Update' : 'Detect'),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 14),
                          _field(nameCtrl, 'Full Name *', Icons.person_outline),
                          const SizedBox(height: 10),
                          _field(phoneCtrl, 'Phone Number *', Icons.phone_outlined, type: TextInputType.phone),
                          const SizedBox(height: 10),
                          _field(addressCtrl, 'Delivery Address *', Icons.location_on_outlined, maxLines: 2),
                          const SizedBox(height: 10),
                          _field(cityCtrl, 'City *', Icons.location_city_outlined),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Expanded(child: _field(pincodeCtrl, 'Pincode *', Icons.pin_drop_outlined, type: TextInputType.number)),
                              const SizedBox(width: 10),
                              Expanded(child: _field(stateCtrl, 'State *', Icons.map_outlined)),
                            ],
                          ),
                          const SizedBox(height: 10),
                          _field(notesCtrl, 'Order Notes', Icons.note_outlined),
                        ],
                      ),
                    ),

                    const SizedBox(height: 14),
                    _CheckoutCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Payment Method', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: const Color(0xffe8f7ef),
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(color: const Color(0xff0c8f43)),
                            ),
                            child: const Row(
                              children: [
                                CircleAvatar(backgroundColor: Colors.white, child: Icon(Icons.payments_outlined, color: Color(0xff0c8f43))),
                                SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('Cash on Delivery', style: TextStyle(fontWeight: FontWeight.w900)),
                                      SizedBox(height: 3),
                                      Text('Pay when you receive your order', style: TextStyle(color: Colors.grey, fontSize: 12)),
                                    ],
                                  ),
                                ),
                                Icon(Icons.radio_button_checked, color: Color(0xff0c8f43)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 14),
                    CartBillCard(
                      subtotal: cart.subtotal,
                      delivery: cart.deliveryFee,
                      tax: cart.tax,
                      total: cart.totalAmount,
                    ),

                    const SizedBox(height: 14),
                    ValueListenableBuilder<bool>(
                      valueListenable: isProcessing,
                      builder: (context, processing, _) {
                        return SizedBox(
                          height: 58,
                          child: ElevatedButton(
                            onPressed: processing
                                ? null
                                : () async {
                                    if (nameCtrl.text.trim().isEmpty ||
                                        phoneCtrl.text.trim().isEmpty ||
                                        addressCtrl.text.trim().isEmpty ||
                                        cityCtrl.text.trim().isEmpty ||
                                        pincodeCtrl.text.trim().length < 6 ||
                                        stateCtrl.text.trim().isEmpty) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('Fill all required fields correctly'), backgroundColor: Colors.red),
                                      );
                                      return;
                                    }

                                    isProcessing.value = true;
                                    final orderProvider = context.read<OrderProvider>();
                                    final result = await orderProvider.placeOrder(
                                      items: cart.items,
                                      deliveryAddress: {
                                        'name': nameCtrl.text.trim(),
                                        'phone': phoneCtrl.text.trim(),
                                        'line1': addressCtrl.text.trim(),
                                        'city': cityCtrl.text.trim(),
                                        'state': stateCtrl.text.trim(),
                                        'pincode': pincodeCtrl.text.trim(),
                                        'country': 'India',
                                        'latitude': latitude,
                                        'longitude': longitude,
                                      },
                                      paymentMethod: 'cod',
                                      couponCode: cart.couponCode,
                                      notes: notesCtrl.text.trim(),
                                    );
                                    isProcessing.value = false;

                                    if (!context.mounted) return;
                                    if (result['success'] == true) {
                                      final order = result['data']?['order'];
                                      final orderNum = order?['orderNumber'] ?? '';
                                      final totalAmt = cart.totalAmount;

                                      cart.clearCart();
                                      Navigator.pop(ctx);
                                      Navigator.pop(context);

                                      await WhatsAppService().sendOrderToStore(
                                        order: order ?? {},
                                        customerName: nameCtrl.text.trim(),
                                        customerPhone: phoneCtrl.text.trim(),
                                        address: '${addressCtrl.text.trim()}, ${cityCtrl.text.trim()}',
                                        googleMapsLink: googleMapsLink,
                                        latitude: latitude,
                                        longitude: longitude,
                                      );

                                      NotificationService().showOrderPlacedNotification(orderNum, totalAmt);
                                      _showSuccess(context, orderNum);
                                    } else {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text(result['message'] ?? 'Failed'), backgroundColor: Colors.red),
                                      );
                                    }
                                  },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xff0c8f43),
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                            ),
                            child: processing
                                ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white))
                                : Text('Place Order • ₹${cart.totalAmount.toStringAsFixed(0)}', style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w900)),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _field(TextEditingController ctrl, String label, IconData icon, {TextInputType type = TextInputType.text, int maxLines = 1}) {
    return TextField(
      controller: ctrl,
      keyboardType: type,
      maxLines: maxLines,
      decoration: InputDecoration(
        filled: true,
        fillColor: const Color(0xfff8fafc),
        labelText: label,
        prefixIcon: Icon(icon, color: const Color(0xff0c8f43)),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: const BorderSide(color: Color(0xffeeeeee))),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: const BorderSide(color: Color(0xffeeeeee))),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: const BorderSide(color: Color(0xff0c8f43))),
      ),
    );
  }

  void _showSuccess(BuildContext context, String orderNum) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (_) => Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
      child: Padding(
        padding: const EdgeInsets.all(26),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TweenAnimationBuilder<double>(
              tween: Tween(begin: .4, end: 1),
              duration: const Duration(milliseconds: 520),
              curve: Curves.elasticOut,
              builder: (_, v, child) => Transform.scale(scale: v, child: child),
              child: Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  color: const Color(0xffe8f7ef),
                  borderRadius: BorderRadius.circular(32),
                ),
                child: const Icon(Icons.check_circle_rounded, color: Color(0xff0c8f43), size: 64),
              ),
            ),
            const SizedBox(height: 18),
            const Text('Order Placed!', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900)),
            const SizedBox(height: 8),
            Text('Order #$orderNum', style: TextStyle(color: Colors.grey.shade600, fontWeight: FontWeight.w700)),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xff0c8f43),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                ),
                child: const Text('Continue Shopping', style: TextStyle(fontWeight: FontWeight.w900)),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle_rounded, color: Color(0xff0c8f43), size: 74),
            const SizedBox(height: 14),
            const Text('Order Placed!', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900)),
            const SizedBox(height: 8),
            Text('Order #$orderNum', style: const TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}

class _CheckoutCard extends StatelessWidget {
  final Widget child;
  const _CheckoutCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xffeeeeee)),
        boxShadow: const [BoxShadow(color: Color(0x0d000000), blurRadius: 24, spreadRadius: -6, offset: Offset(0, 10))],
      ),
      child: child,
    );
  }
}

class _CartEmptyState extends StatelessWidget {
  const _CartEmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
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
              child: const Icon(Icons.shopping_cart_outlined, size: 48, color: Colors.grey),
            ),
            const SizedBox(height: 18),
            const Text('Your cart is empty', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900)),
            const SizedBox(height: 8),
            Text('Add items from Kohli Store to get started', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey.shade600, fontWeight: FontWeight.w700)),
          ],
        ),
      ),
    );
  }
}
