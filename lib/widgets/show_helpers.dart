import 'package:neroflac/widgets/show_helpers.dart';
import 'package:flutter/material.dart';

/// Stub: thin wrapper around [showDialog] for Prisma redesign. Original
/// `showNeroDialog` was removed; Phase 3 will migrate call sites to use
/// `showDialog` directly with the new theme.
Future<T?> showNeroDialog<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  bool barrierDismissible = true,
  String? barrierLabel,
  bool useSafeArea = true,
  RouteSettings? routeSettings,
}) {
  return showDialog<T>(
    context: context,
    barrierDismissible: barrierDismissible,
    barrierLabel: barrierLabel,
    useSafeArea: useSafeArea,
    routeSettings: routeSettings,
    builder: builder,
  );
}

/// Stub: thin wrapper around [showModalBottomSheet] for Prisma redesign.
/// Original `showNeroSheet` removed; Phase 3 will migrate call sites.
Future<T?> showNeroSheet<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  bool isScrollControlled = false,
  bool useSafeArea = false,
  bool isDismissible = true,
  bool enableDrag = true,
  RouteSettings? routeSettings,
  Color? backgroundColor,
  BoxConstraints? constraints,
}) {
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: isScrollControlled,
    useSafeArea: useSafeArea,
    isDismissible: isDismissible,
    enableDrag: enableDrag,
    routeSettings: routeSettings,
    backgroundColor: backgroundColor,
    constraints: constraints,
    builder: builder,
  );
}