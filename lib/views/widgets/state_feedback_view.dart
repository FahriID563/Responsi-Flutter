import 'package:flutter/material.dart';

import '../../core/theme/clay_styles.dart';

/// Widget reusable bergaya Claymorphism untuk status loading, data kosong, atau error.
/// Mendukung mode atmosferik (`frosted: true`) maupun mode kanvas pastel.
class StateFeedbackView extends StatelessWidget {
  const StateFeedbackView({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
    this.isError = false,
    this.frosted = false,
  });

  final IconData icon;
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;
  final bool isError;
  final bool frosted;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dark = ClayPalette.isDark(context);
    final accentColor =
        isError ? ClayPalette.coralDeep : ClayPalette.irisAccent;
    final medallionBg = isError
        ? (dark ? const Color(0xFF472C34) : const Color(0xFFFFE2DB))
        : (dark ? const Color(0xFF332D57) : const Color(0xFFE8E2FF));

    final innerContent = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ClayContainer(
          borderRadius: 999,
          elevation: 0.65,
          color: medallionBg,
          shadowColor: accentColor.withValues(alpha: 0.2),
          padding: const EdgeInsets.all(18),
          child: Icon(icon, size: 36, color: accentColor),
        ),
        const SizedBox(height: 18),
        Text(
          title,
          style: theme.textTheme.titleLarge?.copyWith(
            color: frosted ? Colors.white : null,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          message,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: frosted ? Colors.white.withValues(alpha: 0.88) : null,
          ),
          textAlign: TextAlign.center,
        ),
        if (actionLabel != null && onAction != null) ...[
          const SizedBox(height: 22),
          ClayPillButton(
            label: actionLabel!,
            icon: Icons.refresh_rounded,
            onPressed: onAction!,
          ),
        ],
      ],
    );

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: frosted
              ? FrostedClayCard(
                  borderRadius: 30,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 30,
                  ),
                  child: innerContent,
                )
              : ClayContainer(
                  borderRadius: 30,
                  elevation: 1.0,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 30,
                  ),
                  child: innerContent,
                ),
        ),
      ),
    );
  }
}
