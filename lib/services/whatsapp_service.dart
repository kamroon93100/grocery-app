import 'package:url_launcher/url_launcher.dart';
import '../constants/app_constants.dart';

class WhatsAppService {
  static final WhatsAppService _instance = WhatsAppService._internal();
  factory WhatsAppService() => _instance;
  WhatsAppService._internal();

  Future<bool> sendOrderToStore({
    required dynamic order,
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

    final orderNumber = _read(order, 'orderNumber') ?? 'NEW';
    final items = _read(order, 'items');

    final itemsList = items is List && items.isNotEmpty
        ? items.map((i) {
            final name = _read(i, 'productName') ?? _read(i, 'name') ?? 'Product';
            final qty = _read(i, 'quantity') ?? 1;
            final subtotal = double.tryParse((_read(i, 'subtotal') ?? 0).toString()) ?? 0;
            return '• $name x$qty = ${AppConstants.currency}${subtotal.toStringAsFixed(0)}';
          }).join('\n')
        : '• Order items available in admin panel';

    final subtotal = _money(_read(order, 'subtotal'));
    final delivery = _money(_read(order, 'deliveryFee'));
    final tax = _money(_read(order, 'tax'));
    final total = _money(_read(order, 'totalAmount'));
    final notes = (_read(order, 'notes') ?? '').toString();

    final message = '''
🛒 *NEW COD ORDER*
━━━━━━━━━━━━━━━━━━━━
🏪 *${AppConstants.storeName}*

📦 *Order:* #$orderNumber
⏰ *Time:* ${DateTime.now().toString().substring(0, 16)}

👤 *CUSTOMER*
━━━━━━━━━━━━━━━━━━━━
*Name:* $customerName
*Phone:* $customerPhone
*Address:* $address
${mapLink.isNotEmpty ? '*Location:* $mapLink' : ''}

🛍️ *ITEMS*
━━━━━━━━━━━━━━━━━━━━
$itemsList

💰 *BILL*
━━━━━━━━━━━━━━━━━━━━
Subtotal: ${AppConstants.currency}${subtotal.toStringAsFixed(0)}
Delivery: ${delivery > 0 ? '${AppConstants.currency}${delivery.toStringAsFixed(0)}' : 'FREE'}
Tax: ${AppConstants.currency}${tax.toStringAsFixed(0)}
━━━━━━━━━━━━━━━━━━━━
💵 *TOTAL: ${AppConstants.currency}${total.toStringAsFixed(0)}*
💳 *Payment:* CASH ON DELIVERY

${notes.isNotEmpty ? '📝 *Notes:* $notes' : ''}
━━━━━━━━━━━━━━━━━━━━
✅ Please confirm and prepare this order.
''';

    return await _sendMessage(AppConstants.storeWhatsApp, message);
  }

  Future<bool> sendConfirmationToCustomer({
    required String customerPhone,
    required String orderNumber,
    required double totalAmount,
  }) async {
    final message = '''
✅ *Order Confirmed!*

Your order at *${AppConstants.storeName}* has been placed.

📦 Order: #$orderNumber
💵 Total: ${AppConstants.currency}${totalAmount.toStringAsFixed(0)}
💳 Payment: Cash on Delivery

Thank you for shopping with us! 🛒
''';

    return await _sendMessage(customerPhone, message);
  }

  dynamic _read(dynamic obj, String key) {
    if (obj is Map) return obj[key];

    try {
      switch (key) {
        case 'orderNumber': return obj.orderNumber;
        case 'items': return obj.items;
        case 'subtotal': return obj.subtotal;
        case 'deliveryFee': return obj.deliveryFee;
        case 'tax': return obj.tax;
        case 'totalAmount': return obj.totalAmount;
        case 'notes': return obj.notes;
        case 'productName': return obj.productName;
        case 'name': return obj.name;
        case 'quantity': return obj.quantity;
        case 'subtotal': return obj.subtotal;
      }
    } catch (_) {}

    return null;
  }

  double _money(dynamic value) {
    return double.tryParse((value ?? 0).toString()) ?? 0;
  }

  Future<bool> _sendMessage(String phone, String message) async {
    try {
      final cleanPhone = phone.replaceAll(RegExp(r'[^\d]'), '');
      final encoded = Uri.encodeComponent(message);
      final uri = Uri.parse('https://wa.me/$cleanPhone?text=$encoded');

      if (await canLaunchUrl(uri)) {
        return await launchUrl(uri, mode: LaunchMode.externalApplication);
      }

      return false;
    } catch (_) {
      return false;
    }
  }

  Future<void> openStoreChat() async {
    final cleanPhone = AppConstants.storeWhatsApp.replaceAll(RegExp(r'[^\d]'), '');
    final uri = Uri.parse('https://wa.me/$cleanPhone');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}



