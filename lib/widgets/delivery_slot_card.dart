import 'package:flutter/material.dart';

class DeliverySlotCard extends StatelessWidget {
  final String selectedSlot;
  final ValueChanged<String> onSelected;

  const DeliverySlotCard({
    super.key,
    required this.selectedSlot,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final slots = const [
      '10-15 mins',
      '30 mins',
      'Today Evening',
      'Tomorrow Morning',
    ];

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Delivery Time', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
          const SizedBox(height: 14),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: slots.map((slot) {
              final active = selectedSlot == slot;
              return GestureDetector(
                onTap: () => onSelected(slot),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: active ? const Color(0xffe8fff1) : const Color(0xfff6f7f9),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(
                      color: active ? const Color(0xff0c8f43) : Colors.transparent,
                    ),
                  ),
                  child: Text(
                    slot,
                    style: TextStyle(
                      color: active ? const Color(0xff0c8f43) : Colors.black87,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
