import 'package:flutter/material.dart';

class AppTextField extends StatelessWidget {
  const AppTextField({
    super.key,
    this.controller,
    this.onChanged,
    required this.label,
    this.hintText,
    this.maxLength,
    this.minLines,
    this.maxLines = 1,
    this.obscureText = false,
    this.autofocus = false,
    this.enabled = true,
    this.suffixIcon,
    this.prefixIcon,
    this.keyboardType,
    this.textCapitalization = TextCapitalization.none,
  });

  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final String label;
  final String? hintText;
  final int? maxLength;
  final int? minLines;
  final int maxLines;
  final bool obscureText;
  final bool autofocus;
  final bool enabled;
  final Widget? suffixIcon;
  final IconData? prefixIcon;
  final TextInputType? keyboardType;
  final TextCapitalization textCapitalization;

  @override
  Widget build(BuildContext context) {
    final isMultiline = (minLines ?? 1) > 1 || maxLines > 1;

    return TextField(
      controller: controller,
      onChanged: onChanged,
      maxLength: maxLength,
      minLines: minLines,
      maxLines: maxLines,
      obscureText: obscureText,
      autofocus: autofocus,
      enabled: enabled,
      keyboardType: keyboardType,
      textCapitalization: textCapitalization,
      decoration: InputDecoration(
        labelText: label,
        hintText: hintText,
        alignLabelWithHint: isMultiline,
        prefixIcon: prefixIcon == null ? null : Icon(prefixIcon),
        suffixIcon: suffixIcon,
      ),
    );
  }
}
