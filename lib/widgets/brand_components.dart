import 'package:flutter/material.dart';
import '../main.dart';

/// REUSABLE BRAND COMPONENTS
/// Use these everywhere for consistency

// PRIMARY BUTTON - Main CTA
class PrimaryButton extends StatelessWidget {
  final String           label;
  final VoidCallback?    onPressed;
  final IconData?        icon;
  final bool             isLoading;
  final bool             fullWidth;
  final double           height;

  const PrimaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.isLoading = false,
    this.fullWidth = true,
    this.height    = 52,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width:  fullWidth ? double.infinity : null,
      height: height,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.md)),
          elevation: 0,
        ),
        onPressed: isLoading ? null : onPressed,
        child: isLoading
            ? const SizedBox(
                width: 20, height: 20,
                child: CircularProgressIndicator(
                  color: Colors.white, strokeWidth: 2.5))
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (icon != null) ...[
                    Icon(icon, size: 18),
                    const SizedBox(width: AppSpacing.sm),
                  ],
                  Text(label, style: AppText.button.copyWith(
                    color: Colors.white, fontSize: 15)),
                ],
              ),
      ),
    );
  }
}

// GHOST BUTTON - Secondary CTA
class GhostButton extends StatelessWidget {
  final String        label;
  final VoidCallback? onPressed;
  final IconData?     icon;

  const GhostButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.primary,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md, vertical: AppSpacing.sm),
      ),
      onPressed: onPressed,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 16),
            const SizedBox(width: AppSpacing.xs),
          ],
          Text(label, style: AppText.button.copyWith(
            color: AppColors.primary)),
        ],
      ),
    );
  }
}

// BRAND BADGE - One style only
class BrandBadge extends StatelessWidget {
  final String label;
  final Color? color;
  final Color? textColor;
  final IconData? icon;

  const BrandBadge({
    super.key,
    required this.label,
    this.color,
    this.textColor,
    this.icon,
  });

  // Variants
  factory BrandBadge.discount(String percent) => BrandBadge(
    label: '$percent% OFF',
    color: AppColors.coral,
    textColor: Colors.white);

  factory BrandBadge.fast() => const BrandBadge(
    label: '30 MIN',
    color: AppColors.primary,
    textColor: Colors.white,
    icon: Icons.flash_on);

  factory BrandBadge.lowStock(int count) => BrandBadge(
    label: 'Only $count left',
    color: AppColors.lowStock,
    textColor: Colors.white);

  factory BrandBadge.new_() => const BrandBadge(
    label: 'NEW',
    color: AppColors.primaryAccent,
    textColor: Colors.white);

  factory BrandBadge.outOfStock() => const BrandBadge(
    label: 'OUT OF STOCK',
    color: AppColors.graySoft,
    textColor: Colors.white);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm, vertical: 3),
      decoration: BoxDecoration(
        color: color ?? AppColors.primary,
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 10, color: textColor ?? Colors.white),
            const SizedBox(width: 2),
          ],
          Text(label,
            style: TextStyle(
              color: textColor ?? Colors.white,
              fontSize: 9,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
            )),
        ],
      ),
    );
  }
}

// PRICE DISPLAY - Tabular numerals
class PriceDisplay extends StatelessWidget {
  final double  price;
  final double? originalPrice;
  final String  currency;
  final bool    large;

  const PriceDisplay({
    super.key,
    required this.price,
    this.originalPrice,
    this.currency = 'Rs',
    this.large    = false,
  });

  @override
  Widget build(BuildContext context) {
    final showStrike = originalPrice != null && originalPrice! > price;

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        Text(
          '$currency${price.toStringAsFixed(0)}',
          style: large
              ? AppText.price.copyWith(fontSize: 20)
              : AppText.price,
        ),
        if (showStrike) ...[
          const SizedBox(width: 6),
          Text(
            '$currency${originalPrice!.toStringAsFixed(0)}',
            style: large
                ? AppText.priceStrike.copyWith(fontSize: 14)
                : AppText.priceStrike,
          ),
        ],
      ],
    );
  }
}

// SECTION HEADER - Consistent everywhere
class SectionHeader extends StatelessWidget {
  final String        title;
  final String?       subtitle;
  final VoidCallback? onSeeAll;

  const SectionHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.onSeeAll,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg, AppSpacing.xl, AppSpacing.lg, AppSpacing.md),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: AppText.h2),
              if (subtitle != null) ...[
                const SizedBox(height: 2),
                Text(subtitle!, style: AppText.bodySmall),
              ],
            ],
          ),
          if (onSeeAll != null)
            TextButton(
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: const Size(0, 32),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              onPressed: onSeeAll,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('See all', style: AppText.button.copyWith(
                    color: AppColors.primary, fontSize: 13)),
                  const Icon(Icons.arrow_forward,
                    size: 14, color: AppColors.primary),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

// QUANTITY CONTROL - Add/remove
class QuantityControl extends StatelessWidget {
  final int           quantity;
  final VoidCallback  onIncrement;
  final VoidCallback  onDecrement;
  final double        height;

  const QuantityControl({
    super.key,
    required this.quantity,
    required this.onIncrement,
    required this.onDecrement,
    this.height = 32,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          InkWell(
            onTap: onDecrement,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: height * 0.3),
              child: const Icon(Icons.remove,
                color: Colors.white, size: 14),
            ),
          ),
          Container(
            constraints: BoxConstraints(minWidth: height * 0.8),
            child: Text(
              '$quantity',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 13,
                fontFeatures: [FontFeature.tabularFigures()],
              ),
            ),
          ),
          InkWell(
            onTap: onIncrement,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: height * 0.3),
              child: const Icon(Icons.add,
                color: Colors.white, size: 14),
            ),
          ),
        ],
      ),
    );
  }
}

// ADD BUTTON - Outlined style
class AddButton extends StatelessWidget {
  final VoidCallback onPressed;
  final double       height;

  const AddButton({
    super.key,
    required this.onPressed,
    this.height = 32,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: AppColors.primaryLight,
        borderRadius: BorderRadius.circular(AppRadius.sm),
        border: Border.all(color: AppColors.primary, width: 1.2),
      ),
      child: TextButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 18),
          minimumSize: Size.zero,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
        child: Text('ADD',
          style: TextStyle(
            color: AppColors.primary,
            fontWeight: FontWeight.w700,
            fontSize: 12,
            letterSpacing: 1)),
      ),
    );
  }
}

// EMPTY STATE - Friendly minimal
class EmptyState extends StatelessWidget {
  final IconData      icon;
  final String        title;
  final String?       subtitle;
  final String?       actionLabel;
  final VoidCallback? onAction;

  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxxl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.xl),
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 48, color: AppColors.primary),
            ),
            const SizedBox(height: AppSpacing.xl),
            Text(title, style: AppText.h2, textAlign: TextAlign.center),
            if (subtitle != null) ...[
              const SizedBox(height: AppSpacing.sm),
              Text(subtitle!,
                style: AppText.body.copyWith(color: AppColors.graySoft),
                textAlign: TextAlign.center),
            ],
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: AppSpacing.xl),
              PrimaryButton(
                label: actionLabel!,
                onPressed: onAction,
                fullWidth: false,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
