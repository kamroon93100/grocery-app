import 'package:url_launcher/url_launcher.dart';
import '../constants/app_constants.dart';
import '../models/order_model.dart';

class WhatsAppService {
  static final WhatsAppService _instance = WhatsAppService._internal();
  factory WhatsAppService() => _instance;
  WhatsAppService._internal();

  // Auto-send order to store WhatsApp
  Future<bool> sendOrderToStore({
    required OrderModel order,
    required String customerName,
    required String customerPhone,
    required String address,
    String? googleMapsLink,
    double? latitude,
    double? longitude,
  }) async {
    final mapLink = googleMapsLink ??
        (latitude != null && longitude != null
            ? 'https://www.google.com/maps?q=$latitude,$longitude'
            : '');

    final itemsList = order.items
        .map((i) => '• ${i.productName} x${i.quantity} = ${AppConstants.currency}${i.subtotal.toStringAsFixed(2)}')
        .join('\n');

    final message = '''
🛒 *NEW ORDER RECEIVED!*
━━━━━━━━━━━━━━━━━━━━
🏪 *${AppConstants.storeName}*

📦 *Order:* #${order.orderNumber}
⏰ *Time:* ${DateTime.now().toString().substring(0, 16)}

👤 *CUSTOMER DETAILS*
━━━━━━━━━━━━━━━━━━━━
*Name:* $customerName
*Phone:* $customerPhone
*Address:* $address
${mapLink.isNotEmpty ? '*📍 Live Location:* $mapLink' : ''}

🛍️ *ORDER ITEMS*
━━━━━━━━━━━━━━━━━━━━
$itemsList

💰 *BILL SUMMARY*
━━━━━━━━━━━━━━━━━━━━
Subtotal: ${AppConstants.currency}${order.subtotal.toStringAsFixed(2)}
${order.couponDiscount > 0 ? 'Discount (${order.couponCode}): -${AppConstants.currency}${order.couponDiscount.toStringAsFixed(2)}\n' : ''}Delivery: ${order.deliveryFee > 0 ? "${AppConstants.currency}${order.deliveryFee.toStringAsFixed(2)}" : "FREE"}
Tax: ${AppConstants.currency}${order.tax.toStringAsFixed(2)}
━━━━━━━━━━━━━━━━━━━━
💵 *TOTAL: ${AppConstants.currency}${order.totalAmount.toStringAsFixed(2)}*
💳 *Payment:* ${order.paymentMethod.toUpperCase()}
━━━━━━━━━━━━━━━━━━━━

${order.notes.isNotEmpty ? '📝 *Notes:* ${order.notes}\n' : ''}
✅ Please confirm & prepare for delivery!
    ''';

    return await _sendMessage(AppConstants.storeWhatsApp, message);
  }

  // Send confirmation to customer
  Future<bool> sendConfirmationToCustomer({
    required String customerPhone,
    required String orderNumber,
    required double totalAmount,
  }) async {
    final message = '''
✅ *Order Confirmed!*

Hi! Your order at *${AppConstants.storeName}* has been placed successfully.

📦 *Order:* #$orderNumber
💵 *Total:* ${AppConstants.currency}${totalAmount.toStringAsFixed(2)}
💳 *Payment:* Cash on Delivery
⏰ *Delivery:* 30-45 mins

We'll deliver fresh products to your door!

Need help? Contact us:
📞 ${AppConstants.storePhone}

Thank you for shopping with us! 🛒
    ''';

    return await _sendMessage(customerPhone, message);
  }

  Future<bool> _sendMessage(String phone, String message) async {
    try {
      final cleanPhone = phone.replaceAll(RegExp(r'[^\d]'), '');
      final encoded    = Uri.encodeComponent(message);
      final url        = 'https://wa.me/$cleanPhone?text=$encoded';

      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        return await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  // Open WhatsApp directly to chat with store
  Future<void> openStoreChat() async {
    final url = 'https://wa.me/${AppConstants.storeWhatsApp}';
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}
