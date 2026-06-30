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
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 12,
            offset: Offset(0,4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: const Color(0xff0c8f43).withOpacity(.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.location_on,
              color: Color(0xff0c8f43),
            ),
          ),

          const SizedBox(width:16),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                Text(
                  name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize:16,
                  ),
                ),

                const SizedBox(height:6),

                Text(
                  address,
                  style: const TextStyle(
                    color: Colors.grey,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),

          TextButton(
            onPressed: onChange,
            child: const Text(
              "CHANGE",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Color(0xff0c8f43),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
