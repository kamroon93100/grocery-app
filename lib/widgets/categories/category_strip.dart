import 'package:flutter/material.dart';

class CategoryStrip extends StatelessWidget {
  final List categories;

  const CategoryStrip({
    super.key,
    required this.categories,
  });

  static const _fallback = [
    {'name': 'Fruits', 'icon': '🍎'},
    {'name': 'Vegetables', 'icon': '🥦'},
    {'name': 'Dairy', 'icon': '🥛'},
    {'name': 'Bakery', 'icon': '🍞'},
    {'name': 'Eggs', 'icon': '🥚'},
    {'name': 'Rice', 'icon': '🌾'},
    {'name': 'Snacks', 'icon': '🍿'},
    {'name': 'Drinks', 'icon': '🥤'},
  ];

  String _emoji(String name) {
    final n = name.toLowerCase();
    if (n.contains('fruit')) return '🍎';
    if (n.contains('vegetable')) return '🥦';
    if (n.contains('milk') || n.contains('dairy')) return '🥛';
    if (n.contains('bread') || n.contains('bakery')) return '🍞';
    if (n.contains('drink')) return '🥤';
    if (n.contains('snack')) return '🍿';
    if (n.contains('rice')) return '🌾';
    if (n.contains('egg')) return '🥚';
    return '🛒';
  }

  String _name(dynamic c) {
    if (c is Map) return (c['name'] ?? '').toString();
    try {
      return c.name.toString();
    } catch (_) {
      return '';
    }
  }

  String _icon(dynamic c) {
    if (c is Map) return (c['icon'] ?? '').toString();
    try {
      return c.icon.toString();
    } catch (_) {
      return '';
    }
  }

  String? _image(dynamic c) {
    try {
      final v = c.image;
      if (v != null && v.toString().isNotEmpty) return v.toString();
    } catch (_) {}
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final items = categories.isEmpty ? _fallback : categories.take(12).toList();

    return Container(
      color: const Color(0xfff6f7f9),
      padding: const EdgeInsets.only(top: 4, bottom: 6),
      child: SizedBox(
        height: 104,
        child: ListView.separated(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          scrollDirection: Axis.horizontal,
          itemCount: items.length,
          separatorBuilder: (_, __) => const SizedBox(width: 14),
          itemBuilder: (_, i) {
            final c = items[i];
            final name = _name(c);
            final icon = _icon(c).isNotEmpty ? _icon(c) : _emoji(name);
            final image = _image(c);

            return SizedBox(
              width: 82,
              child: Column(
                children: [
                  Material(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(22),
                    elevation: 0,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(22),
                      onTap: () {},
                      child: Container(
                        width: 66,
                        height: 66,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(22),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x10000000),
                              blurRadius: 14,
                              offset: Offset(0, 5),
                            ),
                          ],
                        ),
                        child: image != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(22),
                                child: Image.network(
                                  image,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => Center(
                                    child: Text(icon, style: const TextStyle(fontSize: 30)),
                                  ),
                                ),
                              )
                            : Center(
                                child: Text(icon, style: const TextStyle(fontSize: 30)),
                              ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Color(0xff1f2937),
                      fontWeight: FontWeight.w800,
                      fontSize: 12,
                      height: 1.05,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

