import 'package:url_launcher/url_launcher.dart';
import '../constants/app_constants.dart';
import '../models/order_model.dart';

class WhatsAppService {
  static final WhatsAppService _instance = WhatsAppService._internal();
  factory WhatsAppService() => _instance;
  WhatsAppService._internal();

  // Send order notification to store via WhatsApp
  Future<void> sendOrderToStore(OrderModel order, String customerName,
    String customerPhone, String address) async {

    final message = '''
🛒 *NEW ORDER - ${AppConstants.storeName}*
━━━━━━━━━━━━━━━━━━━━
📦 Order: *#${order.orderNumber}*
👤 Customer: *$customerName*
📞 Phone: *$customerPhone*
📍 Address: *$address*

🛍️ *Items:*
${order.items.map((i) => '• ${i.productName} x${i.quantity} = \$${i.subtotal.toStringAsFixed(2)}').join('\n')}

━━━━━━━━━━━━━━━━━━━━
💰 Subtotal:  \$${order.subtotal.toStringAsFixed(2)}
🚚 Delivery:  \$${order.deliveryFee.toStringAsFixed(2)}
🧾 Tax:       \$${order.tax.toStringAsFixed(2)}
━━━━━━━━━━━━━━━━━━━━
💵 *TOTAL: \$${order.totalAmount.toStringAsFixed(2)}*
💳 Payment: *Cash on Delivery*
━━━━━━━━━━━━━━━━━━━━
⏰ ${DateTime.now().toString().substring(0, 16)}
    ''';

    final encoded = Uri.encodeComponent(message);
    final url     = 'https://wa.me/${AppConstants.storeWhatsApp}?text=$encoded';

    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      // WhatsApp not available - skip
    }
  }

  // Send order confirmation to customer
  Future<void> sendConfirmationToCustomer(
    String customerPhone,
    String orderNumber,
    double totalAmount,
  ) async {
    final message = '''
✅ *Order Confirmed!*

Hi! Your order has been placed successfully.

📦 Order: *#$orderNumber*
💵 Total: *\$${totalAmount.toStringAsFixed(2)}*
💳 Payment: *Cash on Delivery*

We will deliver your order soon!

Thank you for shopping with *${AppConstants.storeName}* 🛒
    ''';

    final encoded = Uri.encodeComponent(message);
    final phone   = customerPhone.replaceAll(RegExp(r'[^\d]'), '');
    final url     = 'https://wa.me/$phone?text=$encoded';

    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      // Skip if WhatsApp not available
    }
  }
}
