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
      ['cod', 'Cash on Delivery', 'Pay when your order arrives', Icons.payments_outlined],
      ['upi', 'UPI Payment', 'Google Pay / PhonePe / Paytm', Icons.qr_code_2_outlined],
    ];

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xffeeeeee)),
        boxShadow: const [
          BoxShadow(color: Color(0x0d000000), blurRadius: 24, spreadRadius: -6, offset: Offset(0, 10)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.account_balance_wallet_outlined, color: Color(0xff0c8f43)),
              SizedBox(width: 8),
              Text('Payment Method', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Color(0xff111827))),
            ],
          ),
          const SizedBox(height: 14),
          ...methods.map((m) {
            final id = m[0] as String;
            final active = selectedMethod == id;

            return Material(
              color: active ? const Color(0xffe8f7ef) : const Color(0xfff8fafc),
              borderRadius: BorderRadius.circular(18),
              child: InkWell(
                borderRadius: BorderRadius.circular(18),
                onTap: () => onSelected(id),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: active ? const Color(0xff0c8f43) : const Color(0xffeeeeee)),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: Colors.white,
                        child: Icon(m[3] as IconData, color: const Color(0xff0c8f43)),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(m[1] as String, style: const TextStyle(fontWeight: FontWeight.w900, color: Color(0xff111827))),
                            const SizedBox(height: 3),
                            Text(m[2] as String, style: TextStyle(color: Colors.grey.shade600, fontSize: 12, fontWeight: FontWeight.w700)),
                          ],
                        ),
                      ),
                      Icon(active ? Icons.radio_button_checked : Icons.radio_button_off, color: active ? const Color(0xff0c8f43) : Colors.grey),
                    ],
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

