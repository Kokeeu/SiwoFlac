// Stub: NeroShow removed in Prisma redesign. Provides no-op replacements for
// animation utilities that Phase 3 subagents will replace with proper
// implementations or remove.
library;

import 'package:flutter/material.dart';

/// No-op replacement. Phase 3 will replace call sites with proper widgets.
class NeroShow extends StatelessWidget {
  final Widget child;
  final Duration delay;
  final Duration duration;
  final Offset offset;
  final Curve curve;
  final bool enabled;

  const NeroShow({
    super.key,
    required this.child,
    this.delay = Duration.zero,
    this.duration = const Duration(milliseconds: 200),
    this.offset = Offset.zero,
    this.curve = Curves.easeOut,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) => child;
}

/// No-op replacement. Phase 3 will replace with proper FadeIn.
class NeroFadeIn extends StatelessWidget {
  final Widget child;
  final Duration delay;
  final Duration duration;
  final bool enabled;

  const NeroFadeIn({
    super.key,
    required this.child,
    this.delay = Duration.zero,
    this.duration = const Duration(milliseconds: 200),
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) => child;
}

/// No-op replacement.
class NeroScaleIn extends StatelessWidget {
  final Widget child;
  final Duration delay;
  final Duration duration;
  final bool enabled;

  const NeroScaleIn({
    super.key,
    required this.child,
    this.delay = Duration.zero,
    this.duration = const Duration(milliseconds: 200),
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) => child;
}