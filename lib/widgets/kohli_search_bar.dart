import 'package:flutter/material.dart';
import 'package:grocery_local/app/theme/app_text_styles.dart';
import 'package:grocery_local/app/theme/app_radius.dart';
import 'package:grocery_local/app/theme/app_spacing.dart';
import 'package:grocery_local/app/theme/color_scheme_ext.dart';

class KohliSearchBar extends StatefulWidget {
  final TextEditingController? controller;
  final String hintText;
  final List<String> rotatingHints;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onClear;
  final VoidCallback? onTap;
  final Widget? suffixIcon;
  final bool enabled;

  const KohliSearchBar({
    super.key,
    this.controller,
    this.hintText = 'Search for milk, atta, eggs...',
    this.rotatingHints = const [],
    this.onChanged,
    this.onClear,
    this.onTap,
    this.suffixIcon,
    this.enabled = true,
  });

  @override
  State<KohliSearchBar> createState() => _KohliSearchBarState();
}

class _KohliSearchBarState extends State<KohliSearchBar>
    with SingleTickerProviderStateMixin {
  late TextEditingController _ctrl;
  late AnimationController _shimmerCtrl;
  bool _isFocused = false;
  FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _ctrl = widget.controller ?? TextEditingController();
    _shimmerCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
    _focusNode.addListener(() {
      setState(() => _isFocused = _focusNode.hasFocus);
    });
  }

  @override
  void dispose() {
    _shimmerCtrl.dispose();
    _focusNode.dispose();
    if (widget.controller == null) _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      height: 58,
      decoration: BoxDecoration(
        color: colorScheme.softSurface,
        borderRadius: BorderRadius.circular(AppRadius.searchBar),
        border: Border.all(
          color: _isFocused ? colorScheme.primary : colorScheme.border,
          width: _isFocused ? 2 : 1,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.searchBar),
        onTap: widget.onTap ?? () => _focusNode.requestFocus(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: Row(
            children: [
              Icon(Icons.search_rounded,
                color: colorScheme.textMuted, size: 24),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: _ctrl,
                  focusNode: _focusNode,
                  enabled: widget.enabled,
                  onChanged: widget.onChanged,
                  style: AppTextStyles.body(color: colorScheme.textPrimary),
                  decoration: InputDecoration(
                    hintText: widget.hintText,
                    hintStyle: AppTextStyles.body(color: colorScheme.textMuted),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ),
              if (_ctrl.text.isNotEmpty)
                GestureDetector(
                  onTap: () {
                    _ctrl.clear();
                    widget.onClear?.call();
                  },
                  child: Icon(Icons.close_rounded,
                    color: colorScheme.textMuted, size: 20),
                )
              else
                widget.suffixIcon ??
                Icon(Icons.tune_rounded,
                  color: colorScheme.textMuted, size: 22),
            ],
          ),
        ),
      ),
    );
  }
}
