import 'package:flutter/material.dart';

class CategoryChipBar extends StatelessWidget {
  final List<String> categories;
  final String selected;
  final ValueChanged<String> onSelected;

  const CategoryChipBar({
    super.key,
    required this.categories,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (_, i) {
          final item = categories[i];
          final active = item == selected;

          return GestureDetector(
            onTap: () => onSelected(item),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              padding: const EdgeInsets.symmetric(horizontal: 18),
              decoration: BoxDecoration(
                color: active
                    ? const Color(0xff0c8f43)
                    : Colors.white,
                borderRadius: BorderRadius.circular(999),
                border: Border.all(
                  color: active
                      ? const Color(0xff0c8f43)
                      : Colors.grey.shade300,
                ),
              ),
              child: Center(
                child: Text(
                  item,
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    color: active
                        ? Colors.white
                        : Colors.black87,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}


