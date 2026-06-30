import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/category_model.dart';
import '../providers/product_provider.dart';
import '../app/theme/theme.dart';
import 'brand_image.dart';

/// Standardized category card - bold color block + clean image
class BrandCategoryCard extends StatelessWidget {
  final CategoryModel category;
  final Color         backgroundColor;
  final bool          selected;

  const BrandCategoryCard({
    super.key,
    required this.category,
    this.backgroundColor = AppColors.primaryLight,
    this.selected        = false,
  });

  // Color palette for category cards
  static const List<Color> categoryColors = [
    Color(0xFFE7F8EF),  // Mint green
    Color(0xFFFFEEE6),  // Soft coral
    Color(0xFFE0F2FE),  // Sky blue
    Color(0xFFFEF3C7),  // Warm yellow
    Color(0xFFF3E8FF),  // Soft purple
    Color(0xFFFFE4E6),  // Soft pink
    Color(0xFFD1FAE5),  // Fresh green
    Color(0xFFFFF7ED),  // Cream orange
  ];

  static Color colorForIndex(int index) =>
    categoryColors[index % categoryColors.length];

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.read<ProductProvider>().selectCategory(category.name),
      child: Column(
        children: [
          // Image with bold color background
          Expanded(
            child: AnimatedContainer(
              duration: AppMotion.fast,
              decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius: BorderRadius.circular(AppRadius.featured),
                border: selected
                    ? Border.all(color: AppColors.primary, width: 2)
                    : null,
              ),
              padding: const EdgeInsets.all(AppSpacing.x12),
              child: category.image != null && category.image!.startsWith('http')
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                      child: BrandImage(
                        imageUrl: category.image,
                        fallbackEmoji: category.icon,
                        context: ImageContext.category,
                      ),
                    )
                  : Center(
                      child: Text(category.icon,
                        style: const TextStyle(fontSize: 42))),
            ),
          ),
          const SizedBox(height: AppSpacing.x8),
          // Name
          Text(
            category.name,
            style: AppText.smallStrong,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}


