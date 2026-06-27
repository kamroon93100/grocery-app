import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../main.dart';

/// ═══════════════════════════════════════════════════════
/// 🧩 BRAND COMPONENT LIBRARY
/// All reusable UI components following brand guidelines
/// ═══════════════════════════════════════════════════════

// ─── BUTTONS ───────────────────────────────────────────

class PrimaryButton extends StatelessWidget {
  final String        label;
  final VoidCallback? onPressed;
  final IconData?     icon;
  final bool          isLoading;
  final bool          fullWidth;

  const PrimaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.isLoading = false,
    this.fullWidth = true,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width:  fullWidth ? double.infinity : null,
      height: 52,
      child: ElevatedButton(
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
                    Icon(icon, size: 18, color: Colors.white),
                    const SizedBox(width: AppSpacing.x8),
                  ],
                  Text(label, style: AppText.button.copyWith(color: Colors.white)),
                ],
              ),
      ),
    );
  }
}

class SecondaryButton extends StatelessWidget {
  final String        label;
  final VoidCallback? onPressed;
  final IconData?     icon;

  const SecondaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity, height: 52,
      child: OutlinedButton(
        onPressed: onPressed,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 18, color: AppColors.primary),
              const SizedBox(width: AppSpacing.x8),
            ],
            Text(label, style: AppText.button.copyWith(color: AppColors.primary)),
          ],
        ),
      ),
    );
  }
}

// ─── BADGES ────────────────────────────────────────────

class OfferBadge extends StatelessWidget {
  final String   label;
  final Color    color;
  final Color    textColor;
  final IconData? icon;

  const OfferBadge({
    super.key,
    required this.label,
    this.color     = AppColors.accent,
    this.textColor = Colors.white,
    this.icon,
  });

  factory OfferBadge.discount(int percent) => OfferBadge(
    label: '$percent% OFF',
    color: AppColors.accent);

  factory OfferBadge.fast() => const OfferBadge(
    label: '30 MIN',
    color: AppColors.primary,
    icon:  Icons.flash_on);

  factory OfferBadge.lowStock(int qty) => OfferBadge(
    label: 'Only $qty left',
    color: AppColors.warning);

  factory OfferBadge.new_() => const OfferBadge(
    label: 'NEW',
    color: AppColors.primary);

  factory OfferBadge.outOfStock() => OfferBadge(
    label: 'OUT OF STOCK',
    color: AppColors.textMuted);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 9, color: textColor),
            const SizedBox(width: 2),
          ],
          Text(label,
            style: TextStyle(
              color:      textColor,
              fontSize:   9,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.4,
            )),
        ],
      ),
    );
  }
}

// ─── TIMER PILL ────────────────────────────────────────

class TimerPill extends StatelessWidget {
  final String minutes;

  const TimerPill({super.key, required this.minutes});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.borderLight,
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.schedule, size: 11, color: AppColors.textMuted),
          const SizedBox(width: 3),
          Text('$minutes mins',
            style: AppText.caption.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.textMuted)),
        ],
      ),
    );
  }
}

// ─── PRICE DISPLAY ─────────────────────────────────────

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
        Text('$currency${price.toStringAsFixed(0)}',
          style: large ? AppText.price : AppText.priceSmall),
        if (showStrike) ...[
          const SizedBox(width: 6),
          Text('$currency${originalPrice!.toStringAsFixed(0)}',
            style: AppText.priceStrike),
        ],
      ],
    );
  }
}

// ─── SECTION HEADER ────────────────────────────────────

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
        AppSpacing.x16, AppSpacing.x24, AppSpacing.x16, AppSpacing.x12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppText.h2),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(subtitle!, style: AppText.caption),
                ],
              ],
            ),
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
                  Text('See all', style: AppText.smallStrong.copyWith(
                    color: AppColors.primary)),
                  const Icon(Icons.arrow_forward, size: 14,
                    color: AppColors.primary),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

// ─── QUANTITY STEPPER ──────────────────────────────────

class QuantityStepper extends StatelessWidget {
  final int          quantity;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;
  final bool         compact;

  const QuantityStepper({
    super.key,
    required this.quantity,
    required this.onIncrement,
    required this.onDecrement,
    this.compact = true,
  });

  @override
  Widget build(BuildContext context) {
    final height = compact ? 32.0 : 40.0;
    final iconSize = compact ? 14.0 : 18.0;

    return Container(
      height: height,
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _StepperButton(
            icon:    Icons.remove,
            onTap:   onDecrement,
            size:    iconSize,
            height:  height),
          Container(
            constraints: BoxConstraints(minWidth: height),
            alignment: Alignment.center,
            child: Text('$quantity',
              style: GoogleFonts.inter(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: compact ? 13 : 15,
                fontFeatures: const [FontFeature.tabularFigures()],
              )),
          ),
          _StepperButton(
            icon:    Icons.add,
            onTap:   onIncrement,
            size:    iconSize,
            height:  height),
        ],
      ),
    );
  }
}

class _StepperButton extends StatelessWidget {
  final IconData     icon;
  final VoidCallback onTap;
  final double       size;
  final double       height;

  const _StepperButton({
    required this.icon,
    required this.onTap,
    required this.size,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.sm),
        child: SizedBox(
          width: height,
          child: Icon(icon, color: Colors.white, size: size),
        ),
      ),
    );
  }
}

// ─── ADD BUTTON (for product cards) ────────────────────

class CardAddButton extends StatelessWidget {
  final VoidCallback onPressed;

  const CardAddButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 32,
      decoration: BoxDecoration(
        color: AppColors.primaryLight,
        borderRadius: BorderRadius.circular(AppRadius.sm),
        border: Border.all(color: AppColors.primary, width: 1.2),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(AppRadius.sm),
          onTap: onPressed,
          child: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Center(
              child: Text('ADD',
                style: TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                  letterSpacing: 1,
                )),
            ),
          ),
        ),
      ),
    );
  }
}

// ─── SKELETON LOADER ───────────────────────────────────

class SkeletonBox extends StatefulWidget {
  final double  width;
  final double  height;
  final double  radius;

  const SkeletonBox({
    super.key,
    this.width   = double.infinity,
    required this.height,
    this.radius  = AppRadius.sm,
  });

  @override
  State<SkeletonBox> createState() => _SkeletonBoxState();
}

class _SkeletonBoxState extends State<SkeletonBox>
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
      builder: (context, _) {
        return Container(
          width:  widget.width,
          height: widget.height,
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

// ─── EMPTY STATE ───────────────────────────────────────

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
        padding: const EdgeInsets.all(AppSpacing.x40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 96, height: 96,
              decoration: const BoxDecoration(
                color: AppColors.primaryLight,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 44, color: AppColors.primary),
            ),
            const SizedBox(height: AppSpacing.x24),
            Text(title, style: AppText.h3, textAlign: TextAlign.center),
            if (subtitle != null) ...[
              const SizedBox(height: AppSpacing.x8),
              Text(subtitle!,
                style: AppText.small.copyWith(color: AppColors.textMuted),
                textAlign: TextAlign.center),
            ],
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: AppSpacing.x24),
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

// ─── CATEGORY CHIP ─────────────────────────────────────

class BrandCategoryChip extends StatelessWidget {
  final String       label;
  final String?      icon;
  final bool         selected;
  final VoidCallback onTap;

  const BrandCategoryChip({
    super.key,
    required this.label,
    this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: AppMotion.fast,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.x16, vertical: AppSpacing.x8),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.pill),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.border,
            width: 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Text(icon!, style: const TextStyle(fontSize: 14)),
              const SizedBox(width: 6),
            ],
            Text(label,
              style: AppText.smallStrong.copyWith(
                color: selected ? Colors.white : AppColors.textStrong)),
          ],
        ),
      ),
    );
  }
}

