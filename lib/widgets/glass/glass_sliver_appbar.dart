import 'package:flutter/material.dart';
import 'package:neroflac/widgets/glass/glass.dart';

/// Wraps a Material 3 [SliverAppBar] with a frosted glass background.
///
/// Works with both the standard SliverAppBar and the flexible/expanded variants
/// by injecting the blur into the [flexibleSpace] of the wrapped bar. The blur
/// collapses naturally with the bar's scroll position.
class GlassSliverAppBar extends StatelessWidget {
  final SliverAppBar child;
  final double blur;
  final double opacity;
  final Color? tint;

  const GlassSliverAppBar({
    super.key,
    required this.child,
    this.blur = 42,
    this.opacity = 0.42,
    this.tint,
  });

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      pinned: child.pinned,
      snap: child.snap,
      floating: child.floating,
      elevation: child.elevation,
      forceElevated: child.forceElevated,
      backgroundColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      shadowColor: child.shadowColor,
      automaticallyImplyLeading: child.automaticallyImplyLeading,
      centerTitle: child.centerTitle,
      titleSpacing: child.titleSpacing,
      toolbarHeight: child.toolbarHeight,
      leadingWidth: child.leadingWidth,
      stretch: child.stretch,
      stretchTriggerOffset: child.stretchTriggerOffset,
      onStretchTrigger: child.onStretchTrigger,
      excludeHeaderSemantics: child.excludeHeaderSemantics,
      primary: child.primary,
      titleTextStyle: child.titleTextStyle,
      systemOverlayStyle: child.systemOverlayStyle,
      title: child.title,
      leading: child.leading,
      actions: child.actions,
      flexibleSpace: child.flexibleSpace == null
          ? _defaultFlexibleSpace(context)
          : Stack(
              fit: StackFit.passthrough,
              children: [
                Positioned.fill(child: _defaultFlexibleSpace(context)),
                child.flexibleSpace!,
              ],
            ),
      bottom: child.bottom,
      iconTheme: child.iconTheme,
      actionsIconTheme: child.actionsIconTheme,
    );
  }

  Widget _defaultFlexibleSpace(BuildContext context) {
    return GlassSurface(
      blur: blur,
      opacity: opacity,
      tint: tint,
      showShadow: true,
      child: const SizedBox.shrink(),
    );
  }
}
