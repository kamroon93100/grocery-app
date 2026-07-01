import 'package:flutter/material.dart';
import 'premium_skeletons.dart';

class PremiumNetworkImage extends StatelessWidget {
  final String imageUrl;
  final BoxFit fit;
  final double radius;
  final Widget? errorWidget;
  final EdgeInsetsGeometry padding;

  const PremiumNetworkImage({
    super.key,
    required this.imageUrl,
    this.fit = BoxFit.contain,
    this.radius = 18,
    this.errorWidget,
    this.padding = EdgeInsets.zero,
  });

  @override
  Widget build(BuildContext context) {
    if (imageUrl.isEmpty || !imageUrl.startsWith('http')) {
      return errorWidget ?? const Center(child: Icon(Icons.image_outlined, color: Colors.grey));
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: Padding(
        padding: padding,
        child: Image.network(
          imageUrl,
          fit: fit,
          width: double.infinity,
          height: double.infinity,
          filterQuality: FilterQuality.high,
          frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
            if (wasSynchronouslyLoaded) return child;
            return AnimatedOpacity(
              opacity: frame == null ? 0 : 1,
              duration: const Duration(milliseconds: 280),
              curve: Curves.easeOutCubic,
              child: child,
            );
          },
          loadingBuilder: (context, child, progress) {
            if (progress == null) return child;
            return const KohliShimmer(
              child: SkeletonBox(width: double.infinity, height: double.infinity, radius: 18),
            );
          },
          errorBuilder: (_, __, ___) {
            return errorWidget ??
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xfff6f7f9),
                    borderRadius: BorderRadius.circular(radius),
                  ),
                  child: const Center(
                    child: Icon(Icons.image_outlined, color: Colors.grey, size: 32),
                  ),
                );
          },
        ),
      ),
    );
  }
}
