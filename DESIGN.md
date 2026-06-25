# SiwöFlac — Design System

This document captures the **Prisma + Liquid Glass** design language that
ships in v4.7.0+. It is the source of truth for visuals; code changes that
break these contracts need to be justified.

---

## Brand

| Attribute | Value |
|-----------|-------|
| App name | **SiwöFlac** |
| Package id (Dart, lowercase) | `siwoflac` |
| Android package / app id | `com.kokeeu.neroflac` *(historical — do not rename without re-signing)* |
| OAuth scheme | `spotiflac://` |
| File extension | `.spotiflac-ext` |
| Go backend User-Agent | `SpotiFLAC-Mobile` |
| Launcher / splash / in-app brand mark | **Xianyun bird icon** — `assets/icon/icon.png` |
| Display strings | Use diacritic `SiwöFlac` in user-visible copy |
| Dart identifier rules | Class names ASCII (`SiwoFlacApp`) — Dart identifiers don't accept `ö` |

---

## Color palette (Prisma)

All tokens live in `lib/theme/nero_theme_extension.dart`. Access them via
`NeroTheme.of(context).<token>`.

### Action / brand

| Token | Hex | Use |
|-------|-----|-----|
| `prismTeal` | `#14B8A6` | Primary action color, accent fills, focus rings |
| `deepTeal` | `#0D9488` | Gradient top stop, hero washes, pressed states |

### Text

| Token | Hex | Use |
|-------|-----|-----|
| `carbonInk` (alias `carbon`) | `#1D242F` | Headings, primary text on light surfaces |
| `graphite` | `#111827` | Body text, dense copy |
| `slate` | `#6B7280` | Secondary text, captions |
| `steel` | `#718096` | Tertiary text, hints |
| `fog` | `#9CA3AF` | Placeholder text |

### Surfaces & borders

| Token | Hex | Use |
|-------|-----|-----|
| `mist` | `#E2E8F0` | 1px borders, dividers |
| `bone` | `#F3F4F6` | Tinted surfaces (rare) |
| `paper` | `#FFFFFF` | Canvas / surface behind glass |

### Glass tints (rgba over gradient)

| Token | Value | Use |
|-------|-------|-----|
| `glassChrome` | `prismTeal @ 30%` | AppBar, bottom nav (legacy; nav now uses `glassPill`) |
| `glassCard` | `white @ 18%` | Settings cards, search results |
| `glassPill` | `white @ 25%` | Pills, filter chips, action buttons, bottom nav |
| `glassInput` | `white @ 15%` | Search bars, text fields |
| `glassBorderHighlight` | `white @ 40%` | Top hairline 0.5px (iOS-style glint) |
| `glassBorderSubtle` | `white @ 20%` | Body border 0.5px |

### Page gradient (background)

```dart
LinearGradient(
  begin: Alignment.topCenter,
  end: Alignment.bottomCenter,
  colors: [
    Color(0xFF0D9488),  // Deep Teal (top)
    Color(0xFFFFFFFF),  // pure white (bottom)
  ],
  stops: [0.0, 1.0],
)
```

Applied **globally** via `MaterialApp.builder` (`lib/app.dart`) so every
route — main shell, sub-pages, dialogs — inherits it. The `main_shell.dart`
also wraps the local Scaffold in a duplicate `DecoratedBox` for redundancy
during transitions; that duplicate is intentional and not a leak.

---

## Spacing scale (base 4)

```
4 · 8 · 12 · 16 · 24 · 32 · 40 · 48 · 104
```

Use `EdgeInsets.all(16)`, `SizedBox(height: 24)`, etc. Do not invent ad-hoc
values; if a new spacing feels necessary, justify it in code comments.

---

## Radius scale

| Token | Value | Use |
|-------|-------|-----|
| `radiusMd` | `6` | Small controls |
| `radiusLg` | `10` | Cards, default glass |
| `radius2xl` | `16` | Hero cards, sheet handles |
| `radiusSearch` | `16` | Search bars |
| ~~`radiusPill`~~ | ~~`1440`~~ | **Deprecated** — use `StadiumBorder` or 20px |

---

## Shadow

A single token — do not introduce more:

```dart
static const shadowSubtle = <BoxShadow>[
  BoxShadow(color: Color(0x0A000000), blurRadius: 2, offset: Offset(0, 1)),
];
```

---

## Typography

| Font | Role | Source |
|------|------|--------|
| Mona Sans VF | Display | `assets/fonts/MonaSans-VariableFont_wght.ttf` |
| Mona Sans Mono VF | Code | `assets/fonts/MonaSansMono-Variable.ttf` |
| Inter | Body | `assets/fonts/Inter-Variable.ttf` |
| JetBrains Mono | Mono | `assets/fonts/JetBrainsMono-Variable.ttf` |
| Plus Jakarta Sans | AppBar titles | `assets/fonts/PlusJakartaSans-VariableFont_wght.ttf` |

Define a `TextTheme` via `AppTheme.light()` (`lib/theme/app_theme.dart`).
Do **not** hard-code `fontSize` outside that file.

---

## Liquid Glass

Implemented in `lib/widgets/liquid_glass_surface.dart`.

```dart
LiquidGlassSurface(
  variant: GlassVariant.card,           // chrome | card | pill | input
  tint: null,                           // optional override (defaults to variant)
  blur: null,                           // optional override (defaults to nero.glassBlur = 36)
  borderRadius: BorderRadius.circular(10),
  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
  margin: EdgeInsets.symmetric(horizontal: 16),
  height: 80,
  width: null,
  onTap: () {},
  child: ...,
)
```

Each variant:
1. Wraps content in a `BackdropFilter` with `ImageFilter.blur(36, 36)` (configurable).
2. Paints the variant tint over the blurred backdrop.
3. Adds a 0.5px body border (`glassBorderSubtle`).
4. Adds a 0.5px top hairline highlight (`glassBorderHighlight`).
5. Clips to the supplied `borderRadius` (or default per variant).

### When to use which variant

| Variant | Use case |
|---------|----------|
| `chrome` | AppBar backgrounds, accent pills (Prism Teal tint) |
| `card` | Settings cards, search results, list sections |
| `pill` | Chips, filter chips, action buttons, **bottom nav** (white) |
| `input` | Search bars, text fields (subtle, 15% white) |

---

## Status bar & nav bar

Configured globally in `lib/main.dart`:

```dart
SystemChrome.setSystemUIOverlayStyle(
  const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
    statusBarBrightness: Brightness.light,
    systemNavigationBarColor: Colors.transparent,
    systemNavigationBarIconBrightness: Brightness.dark,
  ),
);
```

`Scaffold` instances use `extendBodyBehindAppBar: true` and `extendBody: true`
on main shell so the gradient bleeds edge-to-edge.

---

## SliverAppBar pattern (Home tab example)

```dart
SliverAppBar(
  expandedHeight: 140 + topPadding,
  collapsedHeight: kToolbarHeight,
  pinned: true,
  backgroundColor: Colors.transparent,    // critical: let gradient show
  surfaceTintColor: Colors.transparent,    // M3 elevation tint disabled
  foregroundColor: nero.carbonInk,
  iconTheme: IconThemeData(color: nero.carbonInk),
  automaticallyImplyLeading: false,
  flexibleSpace: LayoutBuilder(builder: (context, constraints) {
    final expandRatio = ...;
    return Stack(children: [
      FlexibleSpaceBar(
        titlePadding: EdgeInsets.only(left: 24, bottom: 16),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Opacity(
              opacity: (expandRatio * 1.2).clamp(0, 1),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: Image.asset('assets/icon/icon.png', width: 56, height: 56),
              ),
            ),
            const SizedBox(width: 12),
            Flexible(child: Text(...)),
          ],
        ),
      ),
    ]);
  }),
);
```

The pill is rendered **inside the title Row** so it shares a baseline with the
text. It fades out as the AppBar collapses.

---

## Component recipes

### Glass card for list sections

```dart
LiquidGlassSurface(
  variant: GlassVariant.card,
  borderRadius: BorderRadius.vertical(
    top: isFirst ? const Radius.circular(20) : Radius.zero,
    bottom: isLast ? const Radius.circular(20) : Radius.zero,
  ),
  margin: EdgeInsets.symmetric(horizontal: 16),
  child: Material(
    color: Colors.transparent,
    child: itemBuilder(index, !isLast),
  ),
)
```

Use `StaggeredListItem(index: index, child: ...)` for fade-in animation.

### Filter / action chip

```dart
LiquidGlassSurface(
  variant: GlassVariant.pill,
  borderRadius: BorderRadius.circular(20),
  onTap: onTap,
  child: Padding(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    child: Row(mainAxisSize: MainAxisSize.min, children: [
      IconTheme(data: IconThemeData(color: nero.prismTeal, size: 18), child: icon),
      const SizedBox(width: 6),
      Text(label, style: TextStyle(color: nero.prismTeal, fontWeight: FontWeight.w600, fontSize: 13)),
    ]),
  ),
)
```

For **selected** chips, override the tint:
`tint: nero.prismTeal.withValues(alpha: 0.85), text/icon: Colors.white`.

### Bottom nav (in main_shell)

```dart
bottomNavigationBar: LiquidGlassSurface(
  variant: GlassVariant.pill,           // white tint — calm look
  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
  padding: EdgeInsets.only(top: 8, bottom: 8),
  height: 80,
  child: NavigationBar(elevation: 0, height: 64, ...),
)
```

---

## What NOT to do

- Do **not** introduce dark mode. Spec is light-only.
- Do **not** use `dynamic_color` / Material You.
- Do **not** paint opaque `colorScheme.surface` over the gradient in
  Scaffold / AppBar / Container backgrounds.
- Do **not** use `ColorScheme.fromSeed` in feature code — derive from
  `NeroTheme.of(context)` so palette tokens stay consistent.
- Do **not** hard-code hex values in widgets — pull from `NeroTheme`.
- Do **not** add new `BoxShadow` definitions beyond `shadowSubtle`.
- Do **not** use `radiusPill = 1440` — it has been deprecated.