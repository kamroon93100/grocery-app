import 'package:flutter/material.dart';

class PlaceOrderBar extends StatelessWidget {
  final double total;
  final bool loading;
  final VoidCallback? onPlaceOrder;

  const PlaceOrderBar({
    super.key,
    required this.total,
    required this.loading,
    required this.onPlaceOrder,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
        decoration: const BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(color: Color(0x18000000), blurRadius: 18, offset: Offset(0, -4)),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                '₹${total.toStringAsFixed(0)}',
                style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900),
              ),
            ),
            SizedBox(
              width: 190,
              height: 54,
              child: ElevatedButton(
                onPressed: loading ? null : onPlaceOrder,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xff0c8f43),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: loading
                    ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white))
                    : const Text('Place Order', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
