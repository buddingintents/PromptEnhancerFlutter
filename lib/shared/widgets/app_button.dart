import 'package:flutter/material.dart';

enum AppButtonVariant { filled, tonal, outlined, text }

class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.variant = AppButtonVariant.filled,
    this.loading = false,
    this.expanded = false,
    this.isDestructive = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final AppButtonVariant variant;
  final bool loading;
  final bool expanded;
  final bool isDestructive;

  @override
  Widget build(BuildContext context) {
    final child = _ButtonContent(label: label, icon: icon, loading: loading);
    final resolvedOnPressed = loading ? null : onPressed;
    final style = _resolveStyle(context);

    Widget button;
    switch (variant) {
      case AppButtonVariant.filled:
        button = FilledButton(
          onPressed: resolvedOnPressed,
          style: style,
          child: child,
        );
      case AppButtonVariant.tonal:
        button = FilledButton.tonal(
          onPressed: resolvedOnPressed,
          style: style,
          child: child,
        );
      case AppButtonVariant.outlined:
        button = OutlinedButton(
          onPressed: resolvedOnPressed,
          style: style,
          child: child,
        );
      case AppButtonVariant.text:
        button = TextButton(
          onPressed: resolvedOnPressed,
          style: style,
          child: child,
        );
    }

    if (expanded) {
      return SizedBox(width: double.infinity, child: button);
    }

    return button;
  }

  ButtonStyle? _resolveStyle(BuildContext context) {
    if (!isDestructive) {
      return null;
    }

    final colorScheme = Theme.of(context).colorScheme;
    switch (variant) {
      case AppButtonVariant.filled:
        return FilledButton.styleFrom(
          backgroundColor: colorScheme.error,
          foregroundColor: colorScheme.onError,
        );
      case AppButtonVariant.tonal:
        return FilledButton.styleFrom(
          backgroundColor: colorScheme.errorContainer,
          foregroundColor: colorScheme.onErrorContainer,
        );
      case AppButtonVariant.outlined:
        return OutlinedButton.styleFrom(
          foregroundColor: colorScheme.error,
          side: BorderSide(color: colorScheme.error.withValues(alpha: 0.5)),
        );
      case AppButtonVariant.text:
        return TextButton.styleFrom(foregroundColor: colorScheme.error);
    }
  }
}

class _ButtonContent extends StatelessWidget {
  const _ButtonContent({required this.label, required this.loading, this.icon});

  final String label;
  final IconData? icon;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    final text = Text(label);
    final spinner = SizedBox(
      width: 18,
      height: 18,
      child: CircularProgressIndicator(
        strokeWidth: 2,
        color: DefaultTextStyle.of(context).style.color,
      ),
    );

    if (loading && icon == null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [spinner, const SizedBox(width: 10), text],
      );
    }

    if (loading) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [spinner, const SizedBox(width: 10), text],
      );
    }

    if (icon == null) {
      return text;
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [Icon(icon, size: 18), const SizedBox(width: 8), text],
    );
  }
}
