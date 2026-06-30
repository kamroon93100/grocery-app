import 'package:flutter/material.dart';

class KohliQuantityStepper extends StatelessWidget {
  final int quantity;
  final VoidCallback onAdd;
  final VoidCallback onRemove;

  const KohliQuantityStepper({
    super.key,
    required this.quantity,
    required this.onAdd,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 36,
      decoration: BoxDecoration(
        color: const Color(0xff0c8f43),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: InkWell(
              onTap: onRemove,
              child: const Center(child: Icon(Icons.remove, color: Colors.white, size: 18)),
            ),
          ),
          Text(
            '$quantity',
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900),
          ),
          Expanded(
            child: InkWell(
              onTap: onAdd,
              child: const Center(child: Icon(Icons.add, color: Colors.white, size: 18)),
            ),
          ),
        ],
      ),
    );
  }
}


