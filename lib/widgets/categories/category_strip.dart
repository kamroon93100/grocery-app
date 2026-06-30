import 'package:flutter/material.dart';
import '../../models/category_model.dart';

class CategoryStrip extends StatelessWidget {
  final List<CategoryModel> categories;

  const CategoryStrip({
    super.key,
    required this.categories,
  });

  String _emoji(String name) {
    final n = name.toLowerCase();

    if (n.contains('fruit')) return '🍎';
    if (n.contains('vegetable')) return '🥦';
    if (n.contains('milk')) return '🥛';
    if (n.contains('dairy')) return '🥛';
    if (n.contains('bread')) return '🍞';
    if (n.contains('bakery')) return '🥐';
    if (n.contains('drink')) return '🥤';
    if (n.contains('snack')) return '🍿';
    if (n.contains('rice')) return '🌾';
    if (n.contains('egg')) return '🥚';

    return '🛒';
  }

  @override
  Widget build(BuildContext context) {
    if (categories.isEmpty) return const SizedBox.shrink();

    return SizedBox(
      height: 108,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 14),
        itemBuilder: (_, i) {
          final c = categories[i];

          return SizedBox(
            width: 82,
            child: Column(
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x12000000),
                        blurRadius: 12,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: c.image != null && c.image!.isNotEmpty
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(18),
                          child: Image.network(
                            c.image!,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Center(
                              child: Text(
                                _emoji(c.name),
                                style: const TextStyle(fontSize: 30),
                              ),
                            ),
                          ),
                        )
                      : Center(
                          child: Text(
                            c.icon.isNotEmpty ? c.icon : _emoji(c.name),
                            style: const TextStyle(fontSize: 30),
                          ),
                        ),
                ),
                const SizedBox(height: 8),
                Text(
                  c.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

