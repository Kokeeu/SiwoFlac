import 'dart:ui' show lerpDouble;

import 'package:flutter/material.dart';

/// Prisma-inspired design tokens for SiwöFlac.
///
/// Stores spacing, radii, shadows, semantic palette colors, decorative
/// gradients, and Liquid Glass parameters used by chrome surfaces (AppBar,
/// bottom nav) and content cards. Use [NeroTheme.of] to read tokens from
/// the current theme, or fall back to the static defaults via
/// [NeroTheme.fallback].
@immutable
class NeroTheme extends ThemeExtension<NeroTheme> {
  const NeroTheme({
    required this.spacing4,
    required this.spacing8,
    required this.spacing12,
    required this.spacing16,
    required this.spacing24,
    required this.spacing32,
    required this.spacing40,
    required this.spacing48,
    required this.spacing104,
    required this.radiusMd,
    required this.radiusLg,
    required this.radius2xl,
    required this.radiusSearch,
    required this.shadowSubtle,
    // === Prisma palette ===
    required this.prismTeal,
    required this.deepTeal,
    required this.carbonInk,
    required this.graphite,
    required this.slate,
    required this.steel,
    required this.fog,
    required this.mist,
    required this.bone,
    required this.paper,
    // === Decorative gradient ===
    required this.gradientPageBg,
    // === Liquid Glass parameters ===
    required this.glassBlur,
    required this.glassChrome,
    required this.glassCard,
    required this.glassPill,
    required this.glassInput,
    required this.glassBorderHighlight,
    required this.glassBorderSubtle,
  });

  // === Spacing scale (4px base) ===
  final double spacing4;
  final double spacing8;
  final double spacing12;
  final double spacing16;
  final double spacing24;
  final double spacing32;
  final double spacing40;
  final double spacing48;
  final double spacing104;

  // === Radii ===
  /// 6px — buttons, nav, icons (Prisma `--radius-md`)
  final double radiusMd;
  /// 10px — cards, code blocks (Prisma `--radius-lg`)
  final double radiusLg;
  /// 16px — max radius allowed (Prisma `--radius-2xl`)
  final double radius2xl;
  /// 16px — search bars (matches radius2xl)
  final double radiusSearch;

  // === Shadow ===
  /// Prisma's only shadow: `rgba(0,0,0,0.04) 0 1px 2px`
  final List<BoxShadow> shadowSubtle;

  // === Prisma palette ===
  /// `#14b8a6` — primary actions, active states, brand mark
  final Color prismTeal;
  /// `#0d9488` — hover teal, gradient end, decoration
  final Color deepTeal;
  /// `#1d242f` — primary headings, nav text, logo mark
  final Color carbonInk;
  /// `#111827` — body text, button labels, dense content
  final Color graphite;
  /// `#6b7280` — secondary body, helper copy
  final Color slate;
  /// `#718096` — tertiary text, disabled labels
  final Color steel;
  /// `#9ca3af` — placeholder text, subtle icon fills
  final Color fog;
  /// `#e2e8f0` — hairline borders (the structural separator)
  final Color mist;
  /// `#f3f4f6` — subtle surface lift, input backgrounds
  final Color bone;
  /// `#ffffff` — page canvas, card surface (frosted glass)
  final Color paper;

  // === Decorative gradient ===
  /// Vertical Deep Teal → light teal. Used as page background.
  final LinearGradient gradientPageBg;

  // === Liquid Glass parameters ===
  /// Backdrop blur sigma (28px — iOS 26 Liquid Glass baseline)
  final double glassBlur;
  /// AppBar + nav: `prismTeal @ 30%`
  final Color glassChrome;
  /// Cards: `white @ 18%`
  final Color glassCard;
  /// Pills/badges: `white @ 25%`
  final Color glassPill;
  /// Inputs/search: `white @ 15%`
  final Color glassInput;
  /// Top edge highlight on glass surfaces
  final Color glassBorderHighlight;
  /// Subtle border on glass surfaces
  final Color glassBorderSubtle;

  // === Deprecated tokens (Wiza era) — kept as stubs so external code
  //     referencing them still compiles. Prefer the canonical Prisma
  //     tokens above; new code must not introduce call sites.
  @Deprecated('Use paper')
  Color get canvas => paper;
  @Deprecated('Use graphite')
  Color get charcoal => graphite;
  @Deprecated('Use carbonInk')
  Color get carbon => carbonInk;
  @Deprecated('Use fog')
  Color get ash => fog;
  @Deprecated('Use mist')
  Color get smoke => mist;
  @Deprecated('Use deepTeal (no gradient)')
  Color get gradientHeroWash => deepTeal;
  @Deprecated('Use carbonInk')
  Color get deepIris => carbonInk;
  @Deprecated('Use prismTeal')
  Color get royalAmethyst => prismTeal;
  @Deprecated('Use deepTeal')
  Color get plumVelvet => deepTeal;
  @Deprecated('Use mist')
  Color get mistViolet => mist;
  @Deprecated('Use prismTeal')
  Color get lavenderGlow => prismTeal;
  @Deprecated('Use prismTeal')
  Color get twilightBeam => prismTeal;
  @Deprecated('Use radiusMd')
  double get radiusCards => radiusMd;
  @Deprecated('Use StadiumBorder or radiusMd')
  double get radiusPill => radiusMd;
  @Deprecated('Use radius2xl')
  double get radiusLarge => radius2xl;
  // Deprecated shadow aliases
  @Deprecated('Use shadowSubtle')
  List<BoxShadow> get shadowSm => shadowSubtle;
  @Deprecated('Use shadowSubtle')
  List<BoxShadow> get shadowLg => shadowSubtle;
  @Deprecated('Use shadowSubtle')
  List<BoxShadow> get shadowLgAccent => shadowSubtle;

  /// Returns the Prisma palette tokens (light only — no dark mode).
  factory NeroTheme.forBrightness(Brightness brightness) {
    const prismTeal = Color(0xFF14B8A6);
    const deepTeal = Color(0xFF0D9488);
    const carbonInk = Color(0xFF1D242F);
    const graphite = Color(0xFF111827);
    const slate = Color(0xFF6B7280);
    const steel = Color(0xFF718096);
    const fog = Color(0xFF9CA3AF);
    const mist = Color(0xFFE2E8F0);
    const bone = Color(0xFFF3F4F6);
    const paper = Color(0xFFFFFFFF);

    return NeroTheme(
      spacing4: 4,
      spacing8: 8,
      spacing12: 12,
      spacing16: 16,
      spacing24: 24,
      spacing32: 32,
      spacing40: 40,
      spacing48: 48,
      spacing104: 104,
      radiusMd: 6,
      radiusLg: 10,
      radius2xl: 16,
      radiusSearch: 16,
      shadowSubtle: const [
        BoxShadow(
          color: Color(0x0A000000),
          blurRadius: 2,
          offset: Offset(0, 1),
        ),
      ],
      prismTeal: prismTeal,
      deepTeal: deepTeal,
      carbonInk: carbonInk,
      graphite: graphite,
      slate: slate,
      steel: steel,
      fog: fog,
      mist: mist,
      bone: bone,
      paper: paper,
      gradientPageBg: const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xFF0D9488),
          Color(0xFFFFFFFF),
        ],
        stops: [0.0, 1.0],
      ),
      glassBlur: 36.0,
      glassChrome: prismTeal.withValues(alpha: 0.30),
      glassCard: const Color(0x2EFFFFFF),
      glassPill: const Color(0x40FFFFFF),
      glassInput: const Color(0x26FFFFFF),
      glassBorderHighlight: const Color(0x66FFFFFF),
      glassBorderSubtle: const Color(0x33FFFFFF),
    );
  }

  static const NeroTheme fallback = NeroTheme(
    spacing4: 4,
    spacing8: 8,
    spacing12: 12,
    spacing16: 16,
    spacing24: 24,
    spacing32: 32,
    spacing40: 40,
    spacing48: 48,
    spacing104: 104,
    radiusMd: 6,
    radiusLg: 10,
    radius2xl: 16,
    radiusSearch: 16,
    shadowSubtle: [
      BoxShadow(color: Color(0x0A000000), blurRadius: 2, offset: Offset(0, 1)),
    ],
    prismTeal: Color(0xFF14B8A6),
    deepTeal: Color(0xFF0D9488),
    carbonInk: Color(0xFF1D242F),
    graphite: Color(0xFF111827),
    slate: Color(0xFF6B7280),
    steel: Color(0xFF718096),
    fog: Color(0xFF9CA3AF),
    mist: Color(0xFFE2E8F0),
    bone: Color(0xFFF3F4F6),
    paper: Color(0xFFFFFFFF),
    gradientPageBg: LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [Color(0xFF0D9488), Color(0xFF6BD4C5)],
    ),
    glassBlur: 28.0,
    glassChrome: Color(0x4D14B8A6),
    glassCard: Color(0x2EFFFFFF),
    glassPill: Color(0x40FFFFFF),
    glassInput: Color(0x26FFFFFF),
    glassBorderHighlight: Color(0x66FFFFFF),
    glassBorderSubtle: Color(0x33FFFFFF),
  );

  /// Reads the [NeroTheme] from the closest [Theme]. Falls back to
  /// [NeroTheme.fallback] if no extension is registered.
  static NeroTheme of(BuildContext context) {
    return Theme.of(context).extension<NeroTheme>() ?? fallback;
  }

  @override
  NeroTheme copyWith({
    double? spacing4,
    double? spacing8,
    double? spacing12,
    double? spacing16,
    double? spacing24,
    double? spacing32,
    double? spacing40,
    double? spacing48,
    double? spacing104,
    double? radiusMd,
    double? radiusLg,
    double? radius2xl,
    double? radiusSearch,
    List<BoxShadow>? shadowSubtle,
    Color? prismTeal,
    Color? deepTeal,
    Color? carbonInk,
    Color? graphite,
    Color? slate,
    Color? steel,
    Color? fog,
    Color? mist,
    Color? bone,
    Color? paper,
    LinearGradient? gradientPageBg,
    double? glassBlur,
    Color? glassChrome,
    Color? glassCard,
    Color? glassPill,
    Color? glassInput,
    Color? glassBorderHighlight,
    Color? glassBorderSubtle,
  }) {
    return NeroTheme(
      spacing4: spacing4 ?? this.spacing4,
      spacing8: spacing8 ?? this.spacing8,
      spacing12: spacing12 ?? this.spacing12,
      spacing16: spacing16 ?? this.spacing16,
      spacing24: spacing24 ?? this.spacing24,
      spacing32: spacing32 ?? this.spacing32,
      spacing40: spacing40 ?? this.spacing40,
      spacing48: spacing48 ?? this.spacing48,
      spacing104: spacing104 ?? this.spacing104,
      radiusMd: radiusMd ?? this.radiusMd,
      radiusLg: radiusLg ?? this.radiusLg,
      radius2xl: radius2xl ?? this.radius2xl,
      radiusSearch: radiusSearch ?? this.radiusSearch,
      shadowSubtle: shadowSubtle ?? this.shadowSubtle,
      prismTeal: prismTeal ?? this.prismTeal,
      deepTeal: deepTeal ?? this.deepTeal,
      carbonInk: carbonInk ?? this.carbonInk,
      graphite: graphite ?? this.graphite,
      slate: slate ?? this.slate,
      steel: steel ?? this.steel,
      fog: fog ?? this.fog,
      mist: mist ?? this.mist,
      bone: bone ?? this.bone,
      paper: paper ?? this.paper,
      gradientPageBg: gradientPageBg ?? this.gradientPageBg,
      glassBlur: glassBlur ?? this.glassBlur,
      glassChrome: glassChrome ?? this.glassChrome,
      glassCard: glassCard ?? this.glassCard,
      glassPill: glassPill ?? this.glassPill,
      glassInput: glassInput ?? this.glassInput,
      glassBorderHighlight:
          glassBorderHighlight ?? this.glassBorderHighlight,
      glassBorderSubtle: glassBorderSubtle ?? this.glassBorderSubtle,
    );
  }

  @override
  NeroTheme lerp(ThemeExtension<NeroTheme>? other, double t) {
    if (other is! NeroTheme) return this;
    return NeroTheme(
      spacing4: lerpDouble(spacing4, other.spacing4, t)!,
      spacing8: lerpDouble(spacing8, other.spacing8, t)!,
      spacing12: lerpDouble(spacing12, other.spacing12, t)!,
      spacing16: lerpDouble(spacing16, other.spacing16, t)!,
      spacing24: lerpDouble(spacing24, other.spacing24, t)!,
      spacing32: lerpDouble(spacing32, other.spacing32, t)!,
      spacing40: lerpDouble(spacing40, other.spacing40, t)!,
      spacing48: lerpDouble(spacing48, other.spacing48, t)!,
      spacing104: lerpDouble(spacing104, other.spacing104, t)!,
      radiusMd: lerpDouble(radiusMd, other.radiusMd, t)!,
      radiusLg: lerpDouble(radiusLg, other.radiusLg, t)!,
      radius2xl: lerpDouble(radius2xl, other.radius2xl, t)!,
      radiusSearch: lerpDouble(radiusSearch, other.radiusSearch, t)!,
      shadowSubtle: BoxShadow.lerpList(shadowSubtle, other.shadowSubtle, t)!,
      prismTeal: Color.lerp(prismTeal, other.prismTeal, t)!,
      deepTeal: Color.lerp(deepTeal, other.deepTeal, t)!,
      carbonInk: Color.lerp(carbonInk, other.carbonInk, t)!,
      graphite: Color.lerp(graphite, other.graphite, t)!,
      slate: Color.lerp(slate, other.slate, t)!,
      steel: Color.lerp(steel, other.steel, t)!,
      fog: Color.lerp(fog, other.fog, t)!,
      mist: Color.lerp(mist, other.mist, t)!,
      bone: Color.lerp(bone, other.bone, t)!,
      paper: Color.lerp(paper, other.paper, t)!,
      gradientPageBg:
          LinearGradient.lerp(gradientPageBg, other.gradientPageBg, t)!,
      glassBlur: lerpDouble(glassBlur, other.glassBlur, t)!,
      glassChrome: Color.lerp(glassChrome, other.glassChrome, t)!,
      glassCard: Color.lerp(glassCard, other.glassCard, t)!,
      glassPill: Color.lerp(glassPill, other.glassPill, t)!,
      glassInput: Color.lerp(glassInput, other.glassInput, t)!,
      glassBorderHighlight:
          Color.lerp(glassBorderHighlight, other.glassBorderHighlight, t)!,
      glassBorderSubtle:
          Color.lerp(glassBorderSubtle, other.glassBorderSubtle, t)!,
    );
  }
}