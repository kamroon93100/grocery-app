import 'package:flutter/material.dart';

class PaymentMethodCard extends StatelessWidget {
  final String selectedMethod;
  final ValueChanged<String> onSelected;

  const PaymentMethodCard({
    super.key,
    required this.selectedMethod,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final methods = const [
      ['cod', 'Cash on Delivery', 'Pay when you receive', Icons.payments_outlined],
      ['upi', 'UPI Payment', 'Google Pay / PhonePe / Paytm', Icons.qr_code_2_outlined],
    ];

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(color: Color(0x14000000), blurRadius: 12, offset: Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Payment Method', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
          const SizedBox(height: 14),
          ...methods.map((m) {
            final id = m[0] as String;
            final active = selectedMethod == id;

            return InkWell(
              onTap: () => onSelected(id),
              child: Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: active ? const Color(0xffe8fff1) : const Color(0xfff6f7f9),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: active ? const Color(0xff0c8f43) : Colors.transparent,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(m[3] as IconData, color: const Color(0xff0c8f43)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(m[1] as String, style: const TextStyle(fontWeight: FontWeight.w900)),
                          const SizedBox(height: 3),
                          Text(m[2] as String, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                        ],
                      ),
                    ),
                    Icon(
                      active ? Icons.radio_button_checked : Icons.radio_button_off,
                      color: active ? const Color(0xff0c8f43) : Colors.grey,
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
