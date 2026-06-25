import 'package:flutter/material.dart';
import 'package:neroflac/theme/nero_theme_extension.dart';
import 'package:neroflac/widgets/liquid_glass_surface.dart';

enum NeroTagVariant { accent, neutral }

/// Prisma-style tag — 6px radius, hairline border, glass pill variant.
class NeroTag extends StatelessWidget {
  final String label;
  final NeroTagVariant variant;
  final IconData? icon;
  final VoidCallback? onTap;

  const NeroTag({
    super.key,
    required this.label,
    this.variant = NeroTagVariant.accent,
    this.icon,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final nero = NeroTheme.of(context);

    final Color foreground = switch (variant) {
      NeroTagVariant.accent => nero.prismTeal,
      NeroTagVariant.neutral => nero.slate,
    };

    final Widget child = LiquidGlassSurface(
      variant: GlassVariant.pill,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      borderRadius: BorderRadius.circular(nero.radiusMd),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 12, color: foreground),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: TextStyle(
              fontFamily: 'Inter',
              fontWeight: FontWeight.w500,
              fontSize: 12,
              color: foreground,
              letterSpacing: 0.32,
            ),
          ),
        ],
      ),
    );

    if (onTap == null) return child;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(nero.radiusMd),
        child: child,
      ),
    );
  }
}