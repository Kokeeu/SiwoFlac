import 'dart:ui' show ImageFilter;
import 'package:flutter/material.dart';

/// Show a modal bottom sheet wrapped in a frosted-glass container.
///
/// The sheet's [backgroundColor] is set to transparent so the underlying
/// content can be blurred. The [builder] is wrapped in a [BackdropFilter] +
/// translucent fill + hairline top border to give the iOS 26 Liquid Glass look.
///
/// If [showDragHandle] is true, an iOS-style drag handle is rendered at the
/// top of the sheet.
///
/// Use this everywhere instead of raw [showModalBottomSheet] in this app.
Future<T?> showGlassModalBottomSheet<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  bool isScrollControlled = false,
  bool useRootNavigator = false,
  bool isDismissible = true,
  bool useSafeArea = true,
  bool showDragHandle = true,
  bool enableDrag = true,
  Color? backgroundColor,
  BorderRadius borderRadius =
      const BorderRadius.vertical(top: Radius.circular(24)),
  BoxConstraints? constraints,
  double blur = 45,
  double opacity = 0.45,
}) {
  final colorScheme = Theme.of(context).colorScheme;
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: isScrollControlled,
    useRootNavigator: useRootNavigator,
    isDismissible: isDismissible,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black.withValues(alpha: 0.35),
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
    builder: (context) {
      Widget content = Builder(builder: builder);
      if (showDragHandle) {
        content = Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Center(
              child: Container(
                width: 36,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.35),
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
            const SizedBox(height: 8),
            content,
          ],
        );
      }
      return ClipRRect(
        borderRadius: borderRadius,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: Container(
            decoration: BoxDecoration(
              color: (backgroundColor ?? colorScheme.surfaceContainerHigh)
                  .withValues(alpha: opacity),
              borderRadius: borderRadius,
              border: Border(
                top: BorderSide(
                  color: Colors.white.withValues(alpha: 0.4),
                  width: 1.0,
                ),
              ),
            ),
            child: content,
          ),
        ),
      );
    },
  );
}

/// Show a [Dialog] (or any widget) wrapped in a frosted-glass container.
///
/// A full-screen [BackdropFilter] is rendered behind the dialog's own widget
/// tree, blurring the underlying content. The [builder] can return any
/// widget (e.g. an [AlertDialog] wrapped in a [PopScope]). The dialog's
/// existing surface treatment is kept — the glass just adds the blur +
/// scrim.
///
/// The dialog opens with a spring scale animation (0.92 → 1.0) and a
/// progressive blur (15 → [blur]) to give the iOS 26 "pop" effect.
///
/// If your builder returns a [Dialog] / [AlertDialog] with a solid
/// backgroundColor, set it to a translucent value (see [DialogThemeData]
/// in `app_theme.dart`) for the blur to show through.
Future<T?> showGlassDialog<T>({
  required BuildContext context,
  required Widget Function(BuildContext) builder,
  String? barrierLabel,
  bool barrierDismissible = true,
  bool useRootNavigator = true,
  double blur = 32,
}) {
  return showDialog<T>(
    context: context,
    barrierColor: Colors.black.withValues(alpha: 0.35),
    barrierLabel: barrierLabel,
    barrierDismissible: barrierDismissible,
    useRootNavigator: useRootNavigator,
    builder: (context) {
      return Stack(
        children: [
          Positioned.fill(
            child: TweenAnimationBuilder<double>(
              duration: const Duration(milliseconds: 450),
              curve: Curves.easeOutCubic,
              tween: Tween(begin: 0.0, end: 1.0),
              builder: (context, t, child) {
                return BackdropFilter(
                  filter: ImageFilter.blur(
                    sigmaX: 15 + (blur - 15) * t,
                    sigmaY: 15 + (blur - 15) * t,
                  ),
                  child: const SizedBox.shrink(),
                );
              },
            ),
          ),
          TweenAnimationBuilder<double>(
            duration: const Duration(milliseconds: 480),
            curve: Curves.elasticOut,
            tween: Tween(begin: 0.92, end: 1.0),
            child: builder(context),
            builder: (context, scale, child) {
              return Transform.scale(scale: scale, child: child);
            },
          ),
        ],
      );
    },
  );
}
