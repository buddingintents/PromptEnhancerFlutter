import 'package:flutter/material.dart';
import 'package:prompt_enhancer/shared/widgets/app_button.dart';
import 'package:prompt_enhancer/shared/widgets/app_card.dart';

enum AppStateTone { neutral, error }

class AppStateView extends StatelessWidget {
  const AppStateView({
    super.key,
    required this.title,
    required this.message,
    required this.icon,
    this.actionLabel,
    this.onAction,
    this.contained = true,
    this.tone = AppStateTone.neutral,
    this.loading = false,
  });

  factory AppStateView.loading({
    Key? key,
    String title = 'Loading',
    String message = 'Please wait while we prepare the latest data.',
    bool contained = true,
  }) {
    return AppStateView(
      key: key,
      title: title,
      message: message,
      icon: Icons.hourglass_top_rounded,
      contained: contained,
      loading: true,
    );
  }

  factory AppStateView.error({
    Key? key,
    required String title,
    required String message,
    String? actionLabel,
    VoidCallback? onAction,
    bool contained = true,
  }) {
    return AppStateView(
      key: key,
      title: title,
      message: message,
      icon: Icons.error_outline_rounded,
      actionLabel: actionLabel,
      onAction: onAction,
      contained: contained,
      tone: AppStateTone.error,
    );
  }

  factory AppStateView.empty({
    Key? key,
    required String title,
    required String message,
    String? actionLabel,
    VoidCallback? onAction,
    bool contained = true,
  }) {
    return AppStateView(
      key: key,
      title: title,
      message: message,
      icon: Icons.inbox_outlined,
      actionLabel: actionLabel,
      onAction: onAction,
      contained: contained,
    );
  }

  final String title;
  final String message;
  final IconData icon;
  final String? actionLabel;
  final VoidCallback? onAction;
  final bool contained;
  final AppStateTone tone;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final colors = _StateColors.resolve(colorScheme, tone);

    final content = Container(
      width: double.infinity,
      constraints: BoxConstraints(minHeight: contained ? 220 : 0),
      alignment: contained ? Alignment.center : Alignment.centerLeft,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: contained
            ? CrossAxisAlignment.center
            : CrossAxisAlignment.start,
        children: [
          if (loading)
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: CircularProgressIndicator(color: colors.iconColor),
            )
          else
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: colors.iconBackground,
                borderRadius: BorderRadius.circular(18),
              ),
              alignment: Alignment.center,
              child: Icon(icon, color: colors.iconColor),
            ),
          const SizedBox(height: 16),
          Text(
            title,
            textAlign: contained ? TextAlign.center : TextAlign.left,
            style: theme.textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Text(
              message,
              textAlign: contained ? TextAlign.center : TextAlign.left,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          if (actionLabel != null && onAction != null) ...[
            const SizedBox(height: 16),
            AppButton(
              label: actionLabel!,
              onPressed: onAction,
              variant: AppButtonVariant.tonal,
              icon: Icons.refresh_rounded,
            ),
          ],
        ],
      ),
    );

    if (!contained) {
      return content;
    }

    return AppCard(
      backgroundColor: colors.background,
      borderSide: BorderSide(color: colors.borderColor),
      child: content,
    );
  }
}

class _StateColors {
  const _StateColors({
    required this.background,
    required this.borderColor,
    required this.iconBackground,
    required this.iconColor,
  });

  final Color background;
  final Color borderColor;
  final Color iconBackground;
  final Color iconColor;

  factory _StateColors.resolve(ColorScheme colorScheme, AppStateTone tone) {
    switch (tone) {
      case AppStateTone.neutral:
        return _StateColors(
          background: colorScheme.surface,
          borderColor: colorScheme.outlineVariant,
          iconBackground: colorScheme.primaryContainer,
          iconColor: colorScheme.onPrimaryContainer,
        );
      case AppStateTone.error:
        return _StateColors(
          background: colorScheme.errorContainer,
          borderColor: colorScheme.error.withValues(alpha: 0.25),
          iconBackground: colorScheme.error,
          iconColor: colorScheme.onError,
        );
    }
  }
}
