import 'package:flutter/material.dart';
import 'package:neroflac/widgets/glass/glass.dart';

/// Wraps a Material 3 [AppBar] with a frosted glass background.
///
/// The [child] AppBar is rendered with a transparent background and surface
/// tint so the underlying content can be blurred. Use instead of [AppBar] in
/// your screen; pass the same parameters to [AppBar] as you would normally.
class GlassAppBar extends StatelessWidget implements PreferredSizeWidget {
  final AppBar child;
  final double blur;
  final double opacity;
  final Color? tint;

  const GlassAppBar({
    super.key,
    required this.child,
    this.blur = 42,
    this.opacity = 0.42,
    this.tint,
  });

  @override
  Size get preferredSize => child.preferredSize;

  @override
  Widget build(BuildContext context) {
    // Force the underlying AppBar to be transparent so the blur shows through.
    final transparentApp = AppBar(
      backgroundColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      scrolledUnderElevation: 0,
      elevation: child.elevation,
      shadowColor: child.shadowColor,
      shape: child.shape,
      automaticallyImplyLeading: child.automaticallyImplyLeading,
      centerTitle: child.centerTitle,
      titleSpacing: child.titleSpacing,
      toolbarOpacity: child.toolbarOpacity,
      bottomOpacity: child.bottomOpacity,
      toolbarHeight: child.toolbarHeight,
      leadingWidth: child.leadingWidth,
      primary: child.primary,
      excludeHeaderSemantics: child.excludeHeaderSemantics,
      titleTextStyle: child.titleTextStyle,
      systemOverlayStyle: child.systemOverlayStyle,
      title: child.title,
      leading: child.leading,
      actions: child.actions,
      flexibleSpace: child.flexibleSpace,
      bottom: child.bottom,
    );

    return GlassSurface(
      blur: blur,
      opacity: opacity,
      tint: tint,
      showShadow: true,
      child: transparentApp,
    );
  }
}
