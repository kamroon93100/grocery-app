import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../providers/Cart_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/order_provider.dart';

import '../../services/whatsapp_service.dart';
import '../../services/notification_service.dart';
import '../../services/location_service.dart';
import '../../constants/app_constants.dart';
import '../../constants/app_colors.dart';
import '../../widgets/brand_components.dart';
import '../../widgets/Cart_item_card.dart';
import '../../widgets/Cart_bill_card.dart';
import '../../widgets/sticky_checkout_bar.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final Cart = context.watch<CartProvider>();
    return Scaffold(
      appBar: AppBar(title: Text('Cart (${Cart.itemCount} items)')),
      body: Cart.items.isEmpty
          ? EmptyState(
              icon: Icons.shopping_cart_outlined,
              title: 'Your Cart is empty',
              subtitle: 'Add items from the store to get started',
            )
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: Cart.items.length,
                    itemBuilder: (context, index) {
                      final item = Cart.items[index];
                      return CartItemCard(
                        item: item,
                        onAdd: () => context.read<CartProvider>().increaseQuantity(item.product.id),
                        onRemove: () => context.read<CartProvider>().decreaseQuantity(item.product.id),
                      );
                    },
                  ),
                ),
                Container(
                  padding: const EdgeInsets.fromLTRB(0, 0, 0, 12),
                  decoration: const BoxDecoration(color: Colors.white),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CartBillCard(
                        subtotal: Cart.subtotal,
                        delivery: Cart.deliveryFee,
                        tax: Cart.tax,
                        total: Cart.totalAmount,
                      ),
                      StickyCheckoutBar(
                        total: Cart.totalAmount,
                        onCheckout: () => _showCheckout(context, Cart),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  void _showCheckout(BuildContext context, CartProvider Cart) {
    final nameCtrl     = TextEditingController();
    final phoneCtrl    = TextEditingController();
    final addressCtrl  = TextEditingController();
    final cityCtrl     = TextEditingController();
    final pincodeCtrl  = TextEditingController();
    final stateCtrl    = TextEditingController();
    final notesCtrl    = TextEditingController();
    final auth         = context.read<AuthProvider>();

    nameCtrl.text  = auth.userName;
    phoneCtrl.text = auth.userPhone;

    final isProcessing = ValueNotifier<bool>(false);
    double?  latitude;
    double?  longitude;
    double?  accuracy;
    String?  googleMapsLink;
    bool     detecting = false;

    showModalBottomSheet(
      context:            context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => StatefulBuilder(
        builder: (context, setS) {

          Future<void> detectLocation() async {
            setS(() => detecting = true);

            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Row(children: [
                  SizedBox(width: 20, height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2, color: Colors.white)),
                  SizedBox(width: 12),
                  Text('Detecting your location...'),
                ]),
                duration: Duration(seconds: 20),
              ),
            );

            final result = await LocationService().getCurrentLocation();
            ScaffoldMessenger.of(context).hideCurrentSnackBar();

            setS(() => detecting = false);

            if (!context.mounted) return;

            if (result.success) {
              setS(() {
                latitude       = result.latitude;
                longitude      = result.longitude;
                accuracy       = result.accuracy;
                googleMapsLink = result.googleMapsUrl;
                addressCtrl.text = result.line1.isNotEmpty
                    ? result.line1
                    : result.fullAddress;
                cityCtrl.text  = result.city;
              });

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Row(children: [
                    const Icon(Icons.check_circle, color: Colors.white),
                    const SizedBox(width: 8),
                    Expanded(child: Text(
                      'Location captured! Accuracy: ${result.accuracy?.toStringAsFixed(0) ?? "?"}m')),
                  ]),
                  backgroundColor: Colors.white,
                ),
              );
            } else {
              showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                  title: const Row(
                    children: [
                      Icon(Icons.location_off, color: Colors.red),
                      SizedBox(width: 8),
                      Text('Location Error'),
                    ],
                  ),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(result.message),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(8)),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text('?? Tips:',
                              style: TextStyle(fontWeight: FontWeight.w900,
                                color: Colors.blue)),
                            SizedBox(height: 4),
                            Text('1. Turn on GPS (Quick settings)',
                              style: TextStyle(fontSize: 12)),
                            Text('2. Allow location permission',
                              style: TextStyle(fontSize: 12)),
                            Text('3. Go outside for better signal',
                              style: TextStyle(fontSize: 12)),
                            Text('4. Try again',
                              style: TextStyle(fontSize: 12)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel')),
                    if (result.errorType == LocationErrorType.serviceDisabled)
                      ElevatedButton.icon(
                        icon: const Icon(Icons.settings),
                        label: const Text('Enable GPS'),
                        onPressed: () async {
                          Navigator.pop(context);
                          await LocationService().openLocationSettings();
                        }),
                    if (result.errorType == LocationErrorType.permissionDeniedForever)
                      ElevatedButton.icon(
                        icon: const Icon(Icons.settings),
                        label: const Text('Open Settings'),
                        onPressed: () async {
                          Navigator.pop(context);
                          await LocationService().openAppSettings();
                        }),
                    if (result.errorType != LocationErrorType.serviceDisabled &&
                        result.errorType != LocationErrorType.permissionDeniedForever)
                      ElevatedButton.icon(
                        icon: const Icon(Icons.refresh),
                        label: const Text('Try Again'),
                        onPressed: () {
                          Navigator.pop(context);
                          detectLocation();
                        }),
                  ],
                ),
              );
            }
          }

          return Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
              left: 20, right: 20, top: 24),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Checkout',
                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900)),
                      IconButton(
                        onPressed: () => Navigator.pop(ctx),
                        icon: const Icon(Icons.close)),
                    ],
                  ),
                  const Divider(),

                  // GPS Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: googleMapsLink != null
                            ? [const Color(0xffe8f7ef), const Color(0xffd1f2df)]
                            : [Colors.blue.shade50, Colors.blue.shade100],
                      ),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: googleMapsLink != null ? const Color(0xff0c8f43) : Colors.blue,
                        width: 2),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: googleMapsLink != null
                                    ? const Color(0xff0c8f43) : Colors.blue,
                                shape: BoxShape.circle),
                              child: Icon(
                                googleMapsLink != null
                                    ? Icons.check : Icons.my_location,
                                color: Colors.white, size: 24),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    googleMapsLink != null
                                        ? '? Location Captured'
                                        : '?? Use Live Location',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w900,
                                      color: googleMapsLink != null
                                          ? const Color(0xff0c8f43) : Colors.blue,
                                      fontSize: 15)),
                                  if (googleMapsLink != null && accuracy != null)
                                    Text(
                                      'Accuracy: ${accuracy!.toStringAsFixed(0)}m • Tap to update',
                                      style: const TextStyle(
                                        color: Colors.grey, fontSize: 11))
                                  else
                                    const Text(
                                      'Fast & accurate like Zomato/Swiggy',
                                      style: TextStyle(
                                        color: Colors.grey, fontSize: 11)),
                                ],
                              ),
                            ),
                            if (detecting)
                              const SizedBox(
                                width: 24, height: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5, color: Colors.blue))
                            else
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: googleMapsLink != null
                                      ? const Color(0xff0c8f43) : Colors.blue,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 10),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8)),
                                ),
                                onPressed: detectLocation,
                                child: Text(
                                  googleMapsLink != null ? 'Update' : 'Detect',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w900,
                                    fontSize: 13)),
                              ),
                          ],
                        ),
                        if (googleMapsLink != null) ...[
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8)),
                            child: Row(
                              children: [
                                const Icon(Icons.map, color: Colors.blue, size: 18),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    'Lat: ${latitude!.toStringAsFixed(4)}, Lng: ${longitude!.toStringAsFixed(4)}',
                                    style: const TextStyle(
                                      fontSize: 11,
                                      fontFamily: 'monospace')),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  const Text('?? Delivery Details',
                    style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15)),
                  const SizedBox(height: 12),
                  _field(nameCtrl, 'Full Name *', Icons.person_outline),
                  const SizedBox(height: 10),
                  _field(phoneCtrl, 'Phone Number *', Icons.phone_outlined,
                    type: TextInputType.phone),
                  const SizedBox(height: 10),
                  TextField(
                    controller: addressCtrl,
                    maxLines: 2,
                    decoration: InputDecoration(
                      labelText: 'Delivery Address *',
                      prefixIcon: const Icon(Icons.location_on_outlined,
                        color: const Color(0xff0c8f43)),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16)),
                    ),
                  ),
                  const SizedBox(height: 10),
                  _field(cityCtrl, 'City *', Icons.location_city_outlined),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: _field(pincodeCtrl, 'Pincode *', Icons.pin_drop_outlined,
                          type: TextInputType.number),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _field(stateCtrl, 'State *', Icons.map_outlined),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  _field(notesCtrl, 'Order Notes (optional)', Icons.note_outlined),
                  const SizedBox(height: 16),

                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xffe8f7ef),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xff0c8f43))),
                    child: const Row(children: [
                      Icon(Icons.money, color: const Color(0xff0c8f43), size: 28),
                      SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Cash on Delivery',
                              style: TextStyle(
                                fontWeight: FontWeight.w900,
                                color: const Color(0xff0c8f43), fontSize: 14)),
                            Text('Pay when you receive',
                              style: TextStyle(color: Colors.grey, fontSize: 11)),
                          ],
                        ),
                      ),
                      Icon(Icons.check_circle, color: const Color(0xff0c8f43)),
                    ]),
                  ),
                  const SizedBox(height: 16),

                  ValueListenableBuilder<bool>(
                    valueListenable: isProcessing,
                    builder: (context, processing, _) {
                      return SizedBox(
                        width: double.infinity, height: 60,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20)),
                          ),
                          onPressed: processing
                              ? null
                              : () async {
                                  if (nameCtrl.text.trim().isEmpty ||
                                      phoneCtrl.text.trim().isEmpty ||
                                      addressCtrl.text.trim().isEmpty ||
                                      cityCtrl.text.trim().isEmpty ||
                                      pincodeCtrl.text.trim().isEmpty ||
                                      stateCtrl.text.trim().isEmpty) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Fill all required fields'),
                                        backgroundColor: Colors.red));
                                    return;
                                  }
                                  if (pincodeCtrl.text.trim().length < 6) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Enter a valid 6-digit pincode'),
                                        backgroundColor: Colors.red));
                                    return;
                                  }

                                  isProcessing.value = true;
                                  final orderProvider = context.read<OrderProvider>();
                                  final result = await orderProvider.placeOrder(
                                    items: Cart.items,
                                    deliveryAddress: {
                                      'name':    nameCtrl.text.trim(),
                                      'phone':   phoneCtrl.text.trim(),
                                      'line1':   addressCtrl.text.trim(),
                                      'city':    cityCtrl.text.trim(),
                                      'state':   stateCtrl.text.trim(),
                                      'pincode': pincodeCtrl.text.trim(),
                                      'country': 'India',
                                      'latitude':  latitude,
                                      'longitude': longitude,
                                    },
                                    paymentMethod: 'cod',
                                    couponCode:    Cart.couponCode,
                                    notes:         notesCtrl.text.trim(),
                                  );
                                  isProcessing.value = false;

                                  if (!context.mounted) return;
                                  if (result['success'] == true) {
                                    final order    = result['data']?['order'];
                                    final orderNum = order?['orderNumber'] ?? '';
                                    final totalAmt = Cart.totalAmount;

                                    Cart.clearCart();
                                    Navigator.pop(ctx);
                                    Navigator.pop(context);

                                    await WhatsAppService().sendOrderToStore(
                                      order: order ?? {},
                                      customerName:   nameCtrl.text.trim(),
                                      customerPhone:  phoneCtrl.text.trim(),
                                      address:        '${addressCtrl.text.trim()}, ${cityCtrl.text.trim()}',
                                      googleMapsLink: googleMapsLink,
                                      latitude:       latitude,
                                      longitude:      longitude,
                                    );

                                    NotificationService().showOrderPlacedNotification(
                                      orderNum, totalAmt);

                                    _showSuccess(context, orderNum);
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text(result['message'] ?? 'Failed'),
                                        backgroundColor: Colors.red));
                                  }
                                },
                                child: processing
                                    ? const SizedBox(
                                        width: 24, height: 24,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2.5, color: Colors.white))
                                    : const Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(Icons.send, color: Colors.white),
                                          SizedBox(width: 8),
                                          Text('Place Order & Notify Store',
                                            style: TextStyle(
                                              fontSize: 16, color: Colors.white,
                                              fontWeight: FontWeight.w900)),
                                        ],
                                      ),
                              ),
                            );
                          },
                        ),
                      const SizedBox(height: 20),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _field(TextEditingController ctrl, String label, IconData icon,
    {TextInputType type = TextInputType.text}) {
    return TextField(
      controller: ctrl,
      keyboardType: type,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: const Color(0xff0c8f43)),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
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
                color: const Color(0xffe8f7ef),
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xff0c8f43), width: 2)),
              child: const Icon(Icons.check_circle, color: const Color(0xff0c8f43), size: 60),
            ),
            const SizedBox(height: 16),
            const Text('Order Placed!',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900)),
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
                      'Store notified via WhatsApp with full details + live location',
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









