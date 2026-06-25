import 'package:flutter/material.dart';
import 'package:neroflac/l10n/l10n.dart';
import 'package:neroflac/theme/nero_theme_extension.dart';
import 'package:neroflac/widgets/liquid_glass_surface.dart';

/// Shared error-state primitive with optional retry action. Prisma-style
/// Xianyun icon tile + label.
class ErrorStateView extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;

  const ErrorStateView({
    super.key,
    required this.message,
    this.onRetry,
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
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: nero.slate,
                  ),
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 16),
              FilledButton(
                onPressed: onRetry,
                style: FilledButton.styleFrom(
                  backgroundColor: nero.prismTeal,
                  foregroundColor: nero.paper,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(nero.radiusMd),
                  ),
                ),
                child: Text(context.l10n.retry),
              ),
            ],
          ],
        ),
      ),
    );
  }
}