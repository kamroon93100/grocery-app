import 'package:flutter/material.dart';
import '../constants/app_constants.dart';

class DeliveryEtaBadge extends StatelessWidget {
  const DeliveryEtaBadge({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin:  const EdgeInsets.symmetric(horizontal: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end:   Alignment.bottomRight,
          colors: [Color(0xFF4CAF50), Color(0xFF66BB6A)],
        ),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.green.shade200,
            blurRadius: 8,
            offset: const Offset(0, 3)),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color:        Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.flash_on, color: Colors.orange, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Express Delivery',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 15)),
                Text(
                  'Get it in 30-45 mins • ${AppConstants.storeName}',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 11)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color:        Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Row(
              children: [
                Icon(Icons.access_time, color: Colors.green, size: 14),
                SizedBox(width: 4),
                Text('30 min',
                  style: TextStyle(
                    color:      Colors.green,
                    fontWeight: FontWeight.bold,
                    fontSize:   12)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

