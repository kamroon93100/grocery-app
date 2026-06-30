import 'package:flutter/material.dart';

class SmoothTextField extends StatefulWidget {
  final TextEditingController controller;
  final String                label;
  final IconData              prefixIcon;
  final Widget?               suffixIcon;
  final TextInputType         keyboardType;
  final bool                  obscureText;
  final String?               Function(String?)? validator;
  final ValueChanged<String>? onChanged;
  final List<String>?         autoFillSuggestions;
  final Color                 primaryColor;

  const SmoothTextField({
    super.key,
    required this.controller,
    required this.label,
    required this.prefixIcon,
    this.suffixIcon,
    this.keyboardType        = TextInputType.text,
    this.obscureText         = false,
    this.validator,
    this.onChanged,
    this.autoFillSuggestions,
    this.primaryColor        = const Color(0xFF99E1D9),
  });

  @override
  State<SmoothTextField> createState() => _SmoothTextFieldState();
}

class _SmoothTextFieldState extends State<SmoothTextField>
    with SingleTickerProviderStateMixin {

  late AnimationController _animController;
  late Animation<double>   _scaleAnim;
  late FocusNode           _focusNode;
  bool _isFocused = false;
  bool _hasText   = false;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _animController = AnimationController(
      vsync:    this,
      duration: const Duration(milliseconds: 200),
    );
    _scaleAnim = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOut));

    _focusNode.addListener(() {
      setState(() => _isFocused = _focusNode.hasFocus);
      if (_focusNode.hasFocus) {
        _animController.forward();
      } else {
        _animController.reverse();
      }
    });

    widget.controller.addListener(() {
      final hasText = widget.controller.text.isNotEmpty;
      if (hasText != _hasText) {
        setState(() => _hasText = hasText);
      }
    });

    _hasText = widget.controller.text.isNotEmpty;
  }

  @override
  void dispose() {
    _animController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve:    Curves.easeOut,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: _isFocused
            ? [
                BoxShadow(
                  color: widget.primaryColor.withOpacity(0.15),
                  blurRadius:  12,
                  spreadRadius: 1,
                ),
              ]
            : [],
      ),
      child: TextFormField(
        controller:   widget.controller,
        focusNode:    _focusNode,
        keyboardType: widget.keyboardType,
        obscureText:  widget.obscureText,
        onChanged:    widget.onChanged,
        validator:    widget.validator,
        cursorColor:  widget.primaryColor,
        cursorWidth:  2,
        cursorRadius: const Radius.circular(1),
        cursorOpacityAnimates: true,
        style: const TextStyle(fontSize: 15, color: Colors.black87),
        decoration: InputDecoration(
          labelText: widget.label,
          labelStyle: TextStyle(
            color: _isFocused
                ? widget.primaryColor
                : Colors.grey.shade600,
            fontSize: _isFocused || _hasText ? 13 : 15,
            fontWeight: _isFocused ? FontWeight.w600 : FontWeight.normal,
          ),
          prefixIcon: AnimatedBuilder(
            animation: _scaleAnim,
            builder: (context, _) => Transform.scale(
              scale: _scaleAnim.value,
              child: Icon(
                widget.prefixIcon,
                color: _isFocused
                    ? widget.primaryColor
                    : Colors.grey.shade500,
                size: 22,
              ),
            ),
          ),
          suffixIcon: widget.suffixIcon,
          filled:    true,
          fillColor: Colors.white,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide:   BorderSide(color: Colors.grey.shade300, width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide:   BorderSide(color: widget.primaryColor, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide:   const BorderSide(color: Colors.red, width: 1),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide:   const BorderSide(color: Colors.red, width: 2),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16, vertical: 14),
        ),
      ),
    );
  }
}



