import 'package:flutter/material.dart';
import 'package:neroflac/theme/nero_theme_extension.dart';
import 'package:neroflac/widgets/liquid_glass_surface.dart';

/// Shared empty-state primitive. Prisma-style Xianyun icon tile + label.
class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? action;

  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    final nero = NeroTheme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            LiquidGlassSurface(
              variant: GlassVariant.pill,
              width: 96,
              height: 96,
              padding: EdgeInsets.zero,
              borderRadius: BorderRadius.circular(48),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(48),
                child: Image.asset(
                  'assets/icon/icon.png',
                  width: 96,
                  height: 96,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: nero.carbonInk,
                    fontWeight: FontWeight.w500,
                  ),
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 8),
              Text(
                subtitle!,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: nero.slate,
                    ),
              ),
            ],
            if (action != null) ...[
              const SizedBox(height: 16),
              action!,
            ],
          ],
        ),
      ),
    );
  }
}