import 'package:flutter/material.dart';
import 'package:grocery_local/app/theme/app_text_styles.dart';
import 'package:grocery_local/app/theme/app_spacing.dart';
import 'package:grocery_local/app/theme/color_scheme_ext.dart';

class KohliSectionHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final VoidCallback? onSeeAll;

  const KohliSectionHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.onSeeAll,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.screenPadding, AppSpacing.sectionGap,
        AppSpacing.screenPadding, AppSpacing.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTextStyles.sectionTitle(color: colorScheme.textPrimary)),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(subtitle!, style: AppTextStyles.caption(color: colorScheme.textMuted)),
                ],
              ],
            ),
          ),
          if (onSeeAll != null)
            GestureDetector(
              onTap: onSeeAll,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('See all',
                    style: AppTextStyles.bodyStrong(color: colorScheme.primary)),
                  const SizedBox(width: 4),
                  Icon(Icons.arrow_forward_rounded,
                    size: 16, color: colorScheme.primary),
                ],
              ),
            ),
        ],
      ),
    );
  }
}


