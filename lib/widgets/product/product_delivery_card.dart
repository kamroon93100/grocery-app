import 'package:flutter/material.dart';

class ProductDeliveryCard extends StatelessWidget {
  const ProductDeliveryCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xfff5fff8),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xffd7f5e3)),
        ),
        child: const Column(
          children: [
            Row(
              children: [
                Icon(Icons.flash_on_rounded, color: Color(0xff0c8f43)),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Delivery in 10 minutes',
                    style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15),
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.payments_outlined, color: Color(0xff0c8f43), size: 20),
                SizedBox(width: 10),
                Text('COD available', style: TextStyle(fontWeight: FontWeight.w700)),
                Spacer(),
                Icon(Icons.verified_outlined, color: Color(0xff0c8f43), size: 20),
                SizedBox(width: 8),
                Text('Fresh quality', style: TextStyle(fontWeight: FontWeight.w700)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

