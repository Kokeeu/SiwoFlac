import 'dart:ui' show ImageFilter;
import 'package:flutter/material.dart';

/// Base iOS 26 Liquid Glass surface.
///
/// Wraps [child] in a [BackdropFilter] with a strong [ImageFilter.blur], then
/// layers, in order from back to front:
///   1. A translucent fill (dark in dark mode, light in light mode) that can
///      be tinted by [sampleColor] (the color of the content behind the
///      surface, which is what gives iOS 26 its "color-adaptive" look).
///   2. A diagonal [glossyReflection] that simulates a sheen of light across
///      the surface.
///   3. A radial [innerGlow] that adds depth from the center.
///   4. A [specularHighlight] pinned to the top edge (the "wet glass" look).
///   5. A hairline border whose color can also be tinted by [sampleColor].
///   6. A soft [dropShadow] (colored, not pure black) sitting behind the
///      surface to add elevation.
///
/// Use this everywhere instead of rolling a glass surface by hand.
class GlassSurface extends StatefulWidget {
  final Widget child;

  /// Backdrop blur sigma. iOS 26 uses ~40-60 for toolbars; we use 40 by
  /// default and let callers crank it up.
  final double blur;

  /// Fill opacity (0-1). Lower = more transparent (lets the blur dominate).
  final double opacity;

  /// Optional override for the base tint color. If null, picks a sensible
  /// default based on the brightness of [Theme.of(context)].
  final Color? tint;

  /// Color of the content behind the glass. When provided, the tint and
  /// border are mixed with this color, so the glass picks up the wallpaper /
  /// content's hue (the iOS 26 "color sampling" effect).
  final Color? sampleColor;

  /// Strength of the color sampling mix (0 = ignore, 1 = fully replace).
  final double sampleStrength;

  /// Optional border radius override. If null, [child] is clipped to a rect.
  final BorderRadius? borderRadius;

  /// Whether to draw the top-edge specular highlight.
  final bool showSpecular;

  /// Whether to draw the radial inner glow.
  final bool showInnerGlow;

  /// Whether to draw the diagonal glossy reflection.
  final bool showGlossy;

  /// Whether to draw the soft drop shadow behind the surface.
  final bool showShadow;

  /// Hairline border opacity.
  final double borderOpacity;

  const GlassSurface({
    super.key,
    required this.child,
    this.blur = 40,
    this.opacity = 0.45,
    this.tint,
    this.sampleColor,
    this.sampleStrength = 0.25,
    this.borderRadius,
    this.showSpecular = true,
    this.showInnerGlow = true,
    this.showGlossy = true,
    this.showShadow = false,
    this.borderOpacity = 0.35,
  });

  @override
  State<GlassSurface> createState() => _GlassSurfaceState();
}

class _GlassSurfaceState extends State<GlassSurface> {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colorScheme = Theme.of(context).colorScheme;

    // Base tint: dark for dark mode, white for light mode.
    final baseTint = widget.tint ??
        (isDark ? const Color(0xFF1A1A1A) : const Color(0xFFFFFFFF));

    // If a sample color was provided, mix it into the tint to pick up the
    // color of the content behind the glass.
    final sample = widget.sampleColor;
    final effectiveTint = sample != null
        ? Color.lerp(baseTint, sample, widget.sampleStrength.clamp(0, 1))!
        : baseTint;

    // Hairline color: blend tint with a contrasting color.
    final hairlineColor = isDark
        ? Color.lerp(Colors.white, sample ?? colorScheme.primary, 0.25)!
        : Color.lerp(Colors.black, sample ?? colorScheme.primary, 0.15)!;

    // Drop shadow color: tinted with the sample (or primary) so it doesn't
    // look like a generic black shadow.
    final shadowColor = Color.lerp(
      Colors.black,
      sample ?? colorScheme.primary,
      0.4,
    )!
        .withValues(alpha: 0.45);

    Widget content = Container(
      decoration: BoxDecoration(
        color: effectiveTint.withValues(alpha: widget.opacity),
        borderRadius: widget.borderRadius ?? BorderRadius.zero,
        border: Border.all(
          color: hairlineColor.withValues(alpha: widget.borderOpacity),
          width: 1.0,
        ),
      ),
      child: widget.child,
    );

    // Layered overlays in z-order: glossy, inner glow, specular.
    final overlays = <Widget>[];

    if (widget.showGlossy) {
      overlays.add(
        Positioned.fill(
          child: IgnorePointer(
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: widget.borderRadius ?? BorderRadius.zero,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white.withValues(alpha: 0.12),
                    Colors.transparent,
                    Colors.white.withValues(alpha: 0.04),
                    Colors.transparent,
                  ],
                  stops: const [0.0, 0.4, 0.6, 1.0],
                ),
              ),
            ),
          ),
        ),
      );
    }

    if (widget.showInnerGlow) {
      overlays.add(
        Positioned.fill(
          child: IgnorePointer(
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: widget.borderRadius ?? BorderRadius.zero,
                gradient: RadialGradient(
                  center: Alignment.center,
                  radius: 1.1,
                  colors: [
                    Colors.white.withValues(alpha: 0.06),
                    Colors.transparent,
                  ],
                  stops: const [0.0, 1.0],
                ),
              ),
            ),
          ),
        ),
      );
    }

    if (widget.showSpecular) {
      overlays.add(
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: IgnorePointer(
            child: Container(
              height: 40,
              decoration: BoxDecoration(
                borderRadius: widget.borderRadius ?? BorderRadius.zero,
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.white.withValues(alpha: 0.22),
                    Colors.white.withValues(alpha: 0.04),
                    Colors.transparent,
                  ],
                  stops: const [0.0, 0.5, 1.0],
                ),
              ),
            ),
          ),
        ),
      );
    }

    if (overlays.isNotEmpty) {
      content = Stack(children: [content, ...overlays]);
    }

    Widget result = ClipRRect(
      borderRadius: widget.borderRadius ?? BorderRadius.zero,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: widget.blur, sigmaY: widget.blur),
        child: content,
      ),
    );

    if (widget.showShadow) {
      result = DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: widget.borderRadius ?? BorderRadius.zero,
          boxShadow: [
            BoxShadow(
              color: shadowColor,
              blurRadius: 24,
              spreadRadius: -2,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: result,
      );
    }

    return result;
  }
}
