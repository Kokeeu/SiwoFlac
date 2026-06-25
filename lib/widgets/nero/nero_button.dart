import 'package:flutter/material.dart';
import 'package:neroflac/theme/nero_theme_extension.dart';

enum NeroButtonVariant { filled, ghost }

/// Prisma-style button.
///
/// - [NeroButtonVariant.filled]: Prism Teal background, white text. Use for
///   the primary CTA on a screen.
/// - [NeroButtonVariant.ghost]: Paper background, hairline mist border,
///   carbon ink text. Use paired beside a filled button.
class NeroButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final NeroButtonVariant variant;
  final IconData? icon;
  final bool expand;

  const NeroButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = NeroButtonVariant.filled,
    this.icon,
    this.expand = false,
  });

  @override
  Widget build(BuildContext context) {
    final nero = NeroTheme.of(context);
    final BorderRadius radius = BorderRadius.circular(nero.radiusMd);

    Color background;
    Color foreground;
    BorderSide border;

    switch (variant) {
      case NeroButtonVariant.filled:
        background = nero.prismTeal;
        foreground = nero.paper;
        border = BorderSide.none;
        break;
      case NeroButtonVariant.ghost:
        background = nero.paper;
        foreground = nero.carbonInk;
        border = BorderSide(color: nero.mist, width: 1);
        break;
    }

    final content = Row(
      mainAxisSize: expand ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (icon != null) ...[
          Icon(icon, size: 16, color: foreground),
          const SizedBox(width: 8),
        ],
        Text(
          label,
          style: TextStyle(
            fontFamily: 'Inter',
            fontWeight: FontWeight.w600,
            fontSize: 14,
            color: foreground,
            letterSpacing: 0.32,
          ),
        ),
      ],
    );

    return Material(
      color: background,
      shape: RoundedRectangleBorder(
        borderRadius: radius,
        side: border,
      ),
      child: InkWell(
        onTap: onPressed,
        borderRadius: radius,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: content,
        ),
      ),
    );
  }
}