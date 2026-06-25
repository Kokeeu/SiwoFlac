import 'package:flutter/material.dart';
import 'package:neroflac/theme/nero_theme_extension.dart';
import 'package:neroflac/widgets/liquid_glass_surface.dart';

/// Stub: original Wiza glass appbar. Now wraps content in
/// LiquidGlassSurface chrome variant. Phase 3 subagents will refine
/// per-screen styling.
class NeroAppBar extends StatelessWidget implements PreferredSizeWidget {
  final Widget child;
  final double expandedHeight;
  final double collapsedHeight;
  final Widget? flexibleSpace;
  final Widget? leading;
  final List<Widget>? actions;
  final Widget? title;
  final bool pinned;
  final bool floating;

  const NeroAppBar({
    super.key,
    this.child = const SizedBox.shrink(),
    this.expandedHeight = 140,
    this.collapsedHeight = kToolbarHeight,
    this.flexibleSpace,
    this.leading,
    this.actions,
    this.title,
    this.pinned = true,
    this.floating = false,
  });

  @override
  Size get preferredSize => Size.fromHeight(
        flexibleSpace != null ? expandedHeight : collapsedHeight,
      );

  @override
  Widget build(BuildContext context) {
    if (child is SliverAppBar) return child;
    final nero = NeroTheme.of(context);
    return LiquidGlassSurface(
      variant: GlassVariant.chrome,
      height: expandedHeight,
      borderRadius: BorderRadius.zero,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        leading: leading,
        title: title,
        actions: actions,
        flexibleSpace: flexibleSpace,
      ),
    );
  }
}

/// Pass-through wrapper for SliverAppBar — the gradient page bg flows
/// behind it via Scaffold(extendBodyBehindAppBar: true). The SliverAppBar's
/// own backgroundColor: Colors.transparent keeps the gradient visible.
///
/// A true BackdropFilter over a sliver is expensive (requires capturing
/// the gradient under the sliver). Phase 3 subagents may opt for an
/// animated tint inside `flexibleSpace` if a richer glass look is needed.
class NeroSliverAppBar extends StatelessWidget {
  final Widget child;

  const NeroSliverAppBar({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) => child;
}