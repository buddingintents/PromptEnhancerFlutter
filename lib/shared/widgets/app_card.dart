import 'package:flutter/material.dart';

class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    this.title,
    this.subtitle,
    this.leading,
    this.trailing,
    this.child,
    this.onTap,
    this.padding = const EdgeInsets.all(20),
    this.backgroundColor,
    this.gradient,
    this.borderSide,
    this.borderRadius = 28,
  });

  final String? title;
  final String? subtitle;
  final Widget? leading;
  final Widget? trailing;
  final Widget? child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry padding;
  final Color? backgroundColor;
  final Gradient? gradient;
  final BorderSide? borderSide;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(borderRadius),
      side: borderSide ?? BorderSide.none,
    );
    final hasHeader =
        title != null ||
        subtitle != null ||
        leading != null ||
        trailing != null;
    final bodyChildren = <Widget>[
      if (hasHeader)
        _CardHeader(
          title: title,
          subtitle: subtitle,
          leading: leading,
          trailing: trailing,
        ),
      if (hasHeader) const SizedBox(height: 16),
    ];

    if (child != null) {
      bodyChildren.add(child!);
    }

    final body = Padding(
      padding: padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: bodyChildren,
      ),
    );

    final content = gradient == null && onTap == null
        ? body
        : Ink(
            decoration: BoxDecoration(
              color: gradient == null ? backgroundColor : null,
              gradient: gradient,
              borderRadius: BorderRadius.circular(borderRadius),
            ),
            child: onTap == null
                ? body
                : InkWell(
                    onTap: onTap,
                    borderRadius: BorderRadius.circular(borderRadius),
                    child: body,
                  ),
          );

    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 0,
      color: gradient == null ? backgroundColor : Colors.transparent,
      shape: shape,
      surfaceTintColor: theme.colorScheme.surfaceTint,
      child: content,
    );
  }
}

class _CardHeader extends StatelessWidget {
  const _CardHeader({this.title, this.subtitle, this.leading, this.trailing});

  final String? title;
  final String? subtitle;
  final Widget? leading;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (leading != null) ...[leading!, const SizedBox(width: 12)],
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (title != null)
                Text(title!, style: theme.textTheme.titleLarge),
              if (subtitle != null) ...[
                if (title != null) const SizedBox(height: 6),
                Text(subtitle!, style: theme.textTheme.bodyMedium),
              ],
            ],
          ),
        ),
        if (trailing != null) ...[const SizedBox(width: 12), trailing!],
      ],
    );
  }
}
