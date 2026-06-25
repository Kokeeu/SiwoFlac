import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:neroflac/theme/nero_theme_extension.dart';

/// iOS 26 Liquid Glass — frosted blur surface that lets the page gradient
/// bleed through. Used for chrome (AppBar, bottom nav), cards, pills, and
/// inputs. Each [variant] tunes the tint opacity and blur to match its
/// context.
enum GlassVariant {
  /// AppBar + bottom nav. Prism Teal @30% tint, strong blur.
  chrome,

  /// Cards. White @18% tint, subtle so content stays readable.
  card,

  /// Pills, badges, version tags. White @25% tint.
  pill,

  /// Search bars, text fields. White @15% tint, hairline border.
  input,
}

/// Translucent frosted-glass surface inspired by iOS 26 Liquid Glass.
/// Wraps [child] in a [BackdropFilter] with the variant-tuned blur and tint.
class LiquidGlassSurface extends StatelessWidget {
  final Widget child;
  final GlassVariant variant;
  final BorderRadius? borderRadius;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? height;
  final double? width;
  final VoidCallback? onTap;

  /// Optional explicit tint override. If null, uses the variant default.
  final Color? tint;

  /// Optional explicit blur override.
  final double? blur;

  const LiquidGlassSurface({
    super.key,
    required this.child,
    this.variant = GlassVariant.card,
    this.borderRadius,
    this.padding,
    this.margin,
    this.height,
    this.width,
    this.onTap,
    this.tint,
    this.blur,
  });

  @override
  Widget build(BuildContext context) {
    final nero = NeroTheme.of(context);
    final radius = borderRadius ??
        BorderRadius.all(
          Radius.circular(
            variant == GlassVariant.chrome ? nero.radiusMd : nero.radiusLg,
          ),
        );

    final Color tintColor = tint ??
        switch (variant) {
          GlassVariant.chrome => nero.glassChrome,
          GlassVariant.card => nero.glassCard,
          GlassVariant.pill => nero.glassPill,
          GlassVariant.input => nero.glassInput,
        };

    final double blurSigma = blur ?? nero.glassBlur;

    final Container container = Container(
      height: height,
      width: width,
      padding: padding,
      decoration: BoxDecoration(
        color: tintColor,
        borderRadius: radius,
        border: Border.all(
          color: nero.glassBorderSubtle,
          width: 0.5,
        ),
      ),
      child: child,
    );

    final Widget blurred = ClipRRect(
      borderRadius: radius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
        child: container,
      ),
    );

    Widget result = Stack(
      children: [
        // Hairline highlight on the top edge — catches light like real glass.
        Positioned.fill(
          child: IgnorePointer(
            child: ClipRRect(
              borderRadius: radius,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: radius,
                  border: Border(
                    top: BorderSide(
                      color: nero.glassBorderHighlight,
                      width: 0.5,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        blurred,
      ],
    );

    if (margin != null) {
      result = Padding(padding: margin!, child: result);
    }

    if (onTap != null) {
      result = GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: result,
      );
    }

    return result;
  }
}