import 'package:flutter/material.dart';

class DeliveryAddressCard extends StatelessWidget {
  final String name;
  final String address;
  final VoidCallback onChange;

  const DeliveryAddressCard({
    super.key,
    required this.name,
    required this.address,
    required this.onChange,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xffeeeeee)),
        boxShadow: const [
          BoxShadow(color: Color(0x0d000000), blurRadius: 24, spreadRadius: -6, offset: Offset(0, 10)),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xffe8f7ef),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.location_on_rounded, color: Color(0xff0c8f43)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name.isEmpty ? 'Delivery Address' : name, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: Color(0xff111827))),
                const SizedBox(height: 6),
                Text(address.isEmpty ? 'Add your delivery address' : address, style: TextStyle(color: Colors.grey.shade700, height: 1.4, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
          TextButton(
            onPressed: onChange,
            child: const Text('CHANGE', style: TextStyle(fontWeight: FontWeight.w900, color: Color(0xff0c8f43))),
          ),
        ],
      ),
    );
  }
}
