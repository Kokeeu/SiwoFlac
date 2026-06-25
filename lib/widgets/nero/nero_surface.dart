import 'package:flutter/material.dart';
import 'package:neroflac/widgets/liquid_glass_surface.dart';

enum NeroSurfaceElevation { none, sm, lg, accent }

/// Stub: original Wiza glass surface. Now wraps content in
/// [LiquidGlassSurface] with the card variant. Phase 3 subagents will
/// migrate individual screens.
class NeroSurface extends StatelessWidget {
  final Widget? child;
  final NeroSurfaceElevation elevation;
  final EdgeInsetsGeometry padding;
  final Color? color;
  final VoidCallback? onTap;
  final BorderRadius? borderRadius;

  // === Legacy GlassSurface parameters (ignored in Wiza) ===
  final double blur;
  final double opacity;
  final Color? tint;
  final Color? sampleColor;
  final double sampleStrength;
  final bool showSpecular;
  final bool showInnerGlow;
  final bool showGlossy;
  final bool showShadow;
  final double borderOpacity;

  const NeroSurface({
    super.key,
    this.child,
    this.elevation = NeroSurfaceElevation.none,
    this.padding = const EdgeInsets.all(16),
    this.color,
    this.onTap,
    this.borderRadius,
    this.blur = 40,
    this.opacity = 0.45,
    this.tint,
    this.sampleColor,
    this.sampleStrength = 0.25,
    this.showSpecular = true,
    this.showInnerGlow = true,
    this.showGlossy = true,
    this.showShadow = false,
    this.borderOpacity = 0.35,
  });

  @override
  Widget build(BuildContext context) {
    return LiquidGlassSurface(
      variant: GlassVariant.card,
      borderRadius: borderRadius,
      padding: padding,
      tint: tint,
      child: child ?? const SizedBox.shrink(),
    );
  }
}