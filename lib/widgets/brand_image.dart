import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../app/theme/theme.dart';

/// ═══════════════════════════════════════════════════════
/// 📸 BRAND IMAGE SYSTEM
/// Enforces consistent image style across the entire app
///
/// Rules enforced automatically:
/// • Same background (white/neutral)
/// • Same crop ratio
/// • Same padding
/// • Same shadow direction
/// • Same loading/error states
/// ═══════════════════════════════════════════════════════

enum ImageContext {
  productCardSmall,   // Grid product cards
  productCardLarge,   // Detail page
  category,           // Category tiles
  banner,             // Promo banners
  thumbnail,          // Tiny preview
  hero,               // Featured hero
}

class BrandImage extends StatelessWidget {
  final String?       imageUrl;
  final String?       fallbackEmoji;
  final ImageContext  context;
  final double?       width;
  final double?       height;
  final BoxFit        fit;
  final bool          showShadow;

  const BrandImage({
    super.key,
    this.imageUrl,
    this.fallbackEmoji,
    this.context     = ImageContext.productCardSmall,
    this.width,
    this.height,
    this.fit         = BoxFit.contain,
    this.showShadow  = false,
  });

  // Image style by context
  _ImageStyle get _style {
    switch (context) {
      case ImageContext.productCardSmall:
        return _ImageStyle(
          backgroundColor: AppColors.surface,
          padding:         8,
          radius:          AppRadius.sm,
          emojiSize:       54,
          aspectRatio:     1.0,
        );
      case ImageContext.productCardLarge:
        return _ImageStyle(
          backgroundColor: AppColors.surfaceAlt,
          padding:         24,
          radius:          AppRadius.featured,
          emojiSize:       140,
          aspectRatio:     1.0,
        );
      case ImageContext.category:
        return _ImageStyle(
          backgroundColor: AppColors.primaryLight,
          padding:         12,
          radius:          AppRadius.featured,
          emojiSize:       42,
          aspectRatio:     1.0,
        );
      case ImageContext.banner:
        return _ImageStyle(
          backgroundColor: AppColors.surface,
          padding:         0,
          radius:          AppRadius.featured,
          emojiSize:       80,
          aspectRatio:     16 / 9,
        );
      case ImageContext.thumbnail:
        return _ImageStyle(
          backgroundColor: AppColors.surfaceAlt,
          padding:         4,
          radius:          AppRadius.sm,
          emojiSize:       28,
          aspectRatio:     1.0,
        );
      case ImageContext.hero:
        return _ImageStyle(
          backgroundColor: AppColors.surface,
          padding:         32,
          radius:          AppRadius.featured,
          emojiSize:       180,
          aspectRatio:     1.0,
        );
    }
  }

  bool get _isUrl => imageUrl != null && imageUrl!.startsWith('http');
  bool get _isEmoji => imageUrl != null && imageUrl!.length <= 4 && !_isUrl;

  @override
  Widget build(BuildContext ctx) {
    final style = _style;

    return Container(
      width:  width,
      height: height,
      decoration: BoxDecoration(
        color:        style.backgroundColor,
        borderRadius: BorderRadius.circular(style.radius),
        boxShadow:    showShadow ? AppShadows.subtle : null,
      ),
      padding: EdgeInsets.all(style.padding),
      child: AspectRatio(
        aspectRatio: style.aspectRatio,
        child: _buildContent(style),
      ),
    );
  }

  Widget _buildContent(_ImageStyle style) {
    // Network image
    if (_isUrl) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(style.radius - 4),
        child: CachedNetworkImage(
          imageUrl: imageUrl!,
          fit:      fit,
          fadeInDuration: const Duration(milliseconds: 200),
          placeholder: (ctx, _) => _SkeletonShimmer(radius: style.radius - 4),
          errorWidget: (ctx, _, __) => _emojiOrFallback(style),
        ),
      );
    }

    // Emoji image
    if (_isEmoji) {
      return Center(
        child: Text(
          imageUrl!,
          style: TextStyle(fontSize: style.emojiSize),
        ),
      );
    }

    // Fallback
    return _emojiOrFallback(style);
  }

  Widget _emojiOrFallback(_ImageStyle style) {
    if (fallbackEmoji != null) {
      return Center(
        child: Text(
          fallbackEmoji!,
          style: TextStyle(fontSize: style.emojiSize),
        ),
      );
    }
    return Center(
      child: Icon(
        Icons.image_outlined,
        size:  style.emojiSize * 0.6,
        color: AppColors.textSubtle,
      ),
    );
  }
}

class _ImageStyle {
  final Color  backgroundColor;
  final double padding;
  final double radius;
  final double emojiSize;
  final double aspectRatio;

  _ImageStyle({
    required this.backgroundColor,
    required this.padding,
    required this.radius,
    required this.emojiSize,
    required this.aspectRatio,
  });
}

// ─── SKELETON SHIMMER ─────────────────────────────────

class _SkeletonShimmer extends StatefulWidget {
  final double radius;
  const _SkeletonShimmer({required this.radius});

  @override
  State<_SkeletonShimmer> createState() => _SkeletonShimmerState();
}

class _SkeletonShimmerState extends State<_SkeletonShimmer>
    with SingleTickerProviderStateMixin {

  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync:    this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (ctx, _) {
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.radius),
            gradient: LinearGradient(
              colors: [
                AppColors.borderLight,
                AppColors.border,
                AppColors.borderLight,
              ],
              stops: [
                (_ctrl.value - 0.3).clamp(0.0, 1.0),
                _ctrl.value.clamp(0.0, 1.0),
                (_ctrl.value + 0.3).clamp(0.0, 1.0),
              ],
            ),
          ),
        );
      },
    );
  }
}

