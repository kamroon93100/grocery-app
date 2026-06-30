import 'package:flutter/material.dart';
import 'package:grocery_local/app/theme/app_radius.dart';
import 'package:grocery_local/app/theme/color_scheme_ext.dart';

class KohliCategoryTile extends StatelessWidget {
  final String label;
  final String? icon;
  final bool selected;
  final VoidCallback onTap;

  const KohliCategoryTile({
    super.key,
    required this.label,
    this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? colorScheme.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(AppRadius.pill),
          border: Border.all(
            color: selected ? colorScheme.primary : colorScheme.border,
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Text(icon!, style: TextStyle(fontSize: 16, color: selected ? Colors.white : colorScheme.textPrimary)),
              const SizedBox(width: 6),
            ],
            Text(label,
              style: TextStyle(
                fontSize: 13, fontWeight: FontWeight.w600,
                color: selected ? Colors.white : colorScheme.textPrimary,
              )),
          ],
        ),
      ),
    );
  }
}

