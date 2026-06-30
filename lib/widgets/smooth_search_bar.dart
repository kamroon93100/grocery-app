import 'package:flutter/material.dart';
import 'dart:async';

class SmoothSearchBar extends StatefulWidget {
  final TextEditingController? controller;
  final String                 hintText;
  final List<String>           rotatingHints;
  final ValueChanged<String>?  onChanged;
  final VoidCallback?          onClear;
  final IconData               prefixIcon;
  final Widget?                suffixIcon;
  final Color                  primaryColor;
  final Color?                 fillColor;
  final double                 fontSize;
  final EdgeInsets             padding;

  const SmoothSearchBar({
    super.key,
    this.controller,
    this.hintText      = 'Search...',
    this.rotatingHints = const [],
    this.onChanged,
    this.onClear,
    this.prefixIcon    = Icons.search,
    this.suffixIcon,
    this.primaryColor  = const Color(0xFF99E1D9),
    this.fillColor,
    this.fontSize      = 14,
    this.padding       = const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
  });

  @override
  State<SmoothSearchBar> createState() => _SmoothSearchBarState();
}

class _SmoothSearchBarState extends State<SmoothSearchBar>
    with TickerProviderStateMixin {

  late TextEditingController _ctrl;
  late AnimationController   _caretController;
  late AnimationController   _hintController;

  // Typing animation for placeholder
  Timer?  _typingTimer;
  Timer?  _hintRotateTimer;
  int     _currentHintIndex = 0;
  String  _displayedHint    = '';
  int     _charIndex        = 0;
  bool    _isDeleting       = false;
  bool    _isFocused        = false;
  FocusNode _focusNode      = FocusNode();

  @override
  void initState() {
    super.initState();
    _ctrl = widget.controller ?? TextEditingController();

    // Blinking caret animation
    _caretController = AnimationController(
      vsync:    this,
      duration: const Duration(milliseconds: 500),
    )..repeat(reverse: true);

    // Hint typing animation
    _hintController = AnimationController(
      vsync:    this,
      duration: const Duration(milliseconds: 300),
    );

    _focusNode.addListener(() {
      setState(() => _isFocused = _focusNode.hasFocus);
      if (_focusNode.hasFocus) {
        _stopTypingAnimation();
      } else {
        _startTypingAnimation();
      }
    });

    // Start typing animation if rotating hints provided
    if (widget.rotatingHints.isNotEmpty) {
      _startTypingAnimation();
    } else {
      _displayedHint = widget.hintText;
    }
  }

  @override
  void dispose() {
    _typingTimer?.cancel();
    _hintRotateTimer?.cancel();
    _caretController.dispose();
    _hintController.dispose();
    _focusNode.dispose();
    if (widget.controller == null) _ctrl.dispose();
    super.dispose();
  }

  void _startTypingAnimation() {
    if (widget.rotatingHints.isEmpty) return;
    _typingTimer?.cancel();
    _typeNextChar();
  }

  void _stopTypingAnimation() {
    _typingTimer?.cancel();
    _hintRotateTimer?.cancel();
  }

  void _typeNextChar() {
    if (widget.rotatingHints.isEmpty) return;

    final currentHint = widget.rotatingHints[_currentHintIndex];

    setState(() {
      if (!_isDeleting) {
        if (_charIndex <= currentHint.length) {
          _displayedHint = currentHint.substring(0, _charIndex.clamp(0, currentHint.length));
          _charIndex++;
        } else {
          _isDeleting = true;
          _typingTimer = Timer(const Duration(milliseconds: 1500), _typeNextChar);
          return;
        }
      } else {
        if (_charIndex > 0) {
          _charIndex--;
          _displayedHint = currentHint.substring(0, _charIndex.clamp(0, currentHint.length));
        } else {
          _isDeleting = false;
          _currentHintIndex = (_currentHintIndex + 1) % widget.rotatingHints.length;
        }
      }
    });

    final delay = _isDeleting
        ? const Duration(milliseconds: 40)
        : const Duration(milliseconds: 80);
    _typingTimer = Timer(delay, _typeNextChar);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color:        widget.fillColor ?? Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _isFocused
              ? widget.primaryColor
              : Colors.grey.shade300,
          width: _isFocused ? 1.5 : 1,
        ),
        boxShadow: _isFocused
            ? [
                BoxShadow(
                  color: widget.primaryColor.withOpacity(0.15),
                  blurRadius: 8,
                  spreadRadius: 1,
                ),
              ]
            : null,
      ),
      padding: widget.padding,
      child: Row(
        children: [
          // Animated icon
          AnimatedScale(
            scale:    _isFocused ? 1.1 : 1.0,
            duration: const Duration(milliseconds: 200),
            child: Icon(
              widget.prefixIcon,
              color: widget.primaryColor,
              size:  20,
            ),
          ),
          const SizedBox(width: 10),

          // Text field with smooth caret
          Expanded(
            child: Stack(
              alignment: Alignment.centerLeft,
              children: [
                // Animated placeholder (only when empty + not focused)
                if (_ctrl.text.isEmpty)
                  AnimatedBuilder(
                    animation: _caretController,
                    builder: (context, _) {
                      return Row(
                        children: [
                          Text(
                            _displayedHint,
                            style: TextStyle(
                              color: Colors.grey.shade500,
                              fontSize: widget.fontSize,
                            ),
                          ),
                          // Smooth blinking caret
                          if (widget.rotatingHints.isNotEmpty && !_isFocused)
                            Opacity(
                              opacity: _caretController.value,
                              child: Container(
                                margin: const EdgeInsets.only(left: 2),
                                width:  2,
                                height: widget.fontSize + 4,
                                decoration: BoxDecoration(
                                  color: widget.primaryColor,
                                  borderRadius: BorderRadius.circular(1),
                                ),
                              ),
                            ),
                        ],
                      );
                    },
                  ),

                // Actual text input
                TextField(
                  controller: _ctrl,
                  focusNode:  _focusNode,
                  onChanged: (val) {
                    setState(() {}); // Rebuild for placeholder
                    widget.onChanged?.call(val);
                  },
                  cursorColor:        widget.primaryColor,
                  cursorWidth:        2,
                  cursorRadius:       const Radius.circular(1),
                  cursorOpacityAnimates: true,
                  style: TextStyle(
                    fontSize: widget.fontSize,
                    color:    Colors.black87,
                  ),
                  decoration: const InputDecoration(
                    border:     InputBorder.none,
                    isDense:    true,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ],
            ),
          ),

          // Clear button (animated)
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            transitionBuilder: (child, animation) {
              return ScaleTransition(scale: animation, child: child);
            },
            child: _ctrl.text.isNotEmpty
                ? IconButton(
                    key: const ValueKey('clear'),
                    icon: const Icon(Icons.close, size: 18),
                    color: Colors.grey.shade600,
                    constraints: const BoxConstraints(),
                    padding: const EdgeInsets.all(4),
                    onPressed: () {
                      _ctrl.clear();
                      setState(() {});
                      widget.onClear?.call();
                      widget.onChanged?.call('');
                    },
                  )
                : (widget.suffixIcon ??
                    Icon(Icons.mic_outlined,
                      key: const ValueKey('mic'),
                      color: widget.primaryColor,
                      size: 20)),
          ),
        ],
      ),
    );
  }
}




