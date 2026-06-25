# SiwöFlac — Agent guide

A practical handbook for AI agents (and humans) working on this codebase.
Read this before touching code. Pair it with `DESIGN.md` for visual rules.

---

## Project at a glance

- **Language**: Dart (Flutter) + Go (native backend via gomobile-style FFI)
- **Targets**: Android (primary), iOS, Desktop (best-effort)
- **State management**: Riverpod (`flutter_riverpod`)
- **Routing**: `go_router` declared in `lib/app.dart`
- **Persistence**: `shared_preferences` for settings, SQLite via
  `sqflite` / `drift` for history, JSON files for library collections
- **Build system**: Gradle (Kotlin DSL) under `android/`

---

## Build commands

```bash
# Debug APK (universal — all ABIs)
flutter build apk --debug

# Debug APK for arm64 only (smaller, faster)
flutter build apk --debug --target-platform android-arm64

# Release APK (universal)
flutter build apk --release

# Install on connected device
flutter install -d emulator-5554

# Hot reload dev session
flutter run -d emulator-5554
```

A convenience wrapper exists at `build-and-install.bat` (debug + arm64).

### Run from scratch

```bash
flutter pub get
cd android && ./gradlew clean && cd ..
flutter build apk --debug
adb install -r build/app/outputs/flutter-apk/app-debug.apk
adb shell pm clear com.kokeeu.neroflac   # optional: wipe app state
```

### Skip onboarding for testing

Edit the app's SharedPreferences file via adb:

```bash
adb shell run-as com.kokeeu.neroflac sh -c 'cat > shared_prefs/FlutterSharedPreferences.xml' << 'EOF'
<?xml version='1.0' encoding='utf-8' standalone='yes' ?>
<map>
    <string name="flutter.app_settings">{"isFirstLaunch":false,"hasCompletedTutorial":true,"locale":"system","historyViewMode":"grid","downloadFallbackExtensionIds":[]}</string>
    <string name="flutter.metadata_provider_priority">[]</string>
    <string name="flutter.provider_priority">[]</string>
</map>
EOF
```

---

## Testing

```bash
flutter test                       # all tests
flutter test test/models_and_utils_test.dart
flutter test test/extension_resolution_test.dart
```

Tests live in `test/`. The two existing files cover model serialization and
extension resolution. Goal after Phase 3: keep both green and add coverage
for any new public widget.

---

## Repository layout

```
siwoflac/
├── DESIGN.md                       # visual language reference
├── AGENTS.md                       # this file
├── CHANGES.md                      # chronological change log (per-version)
├── android/                        # Android Gradle project
│   └── app/src/main/AndroidManifest.xml
├── go_backend/                     # Go native code compiled to libgojni.so
├── assets/
│   ├── fonts/                      # Mona Sans / Inter / JetBrains Mono
│   ├── icon/                       # icon.png, icon_foreground.png, icon_monochrome.png
│   └── images/                     # *.deprecated files kept for rollback
├── lib/
│   ├── main.dart                   # entry point + SystemUiOverlayStyle
│   ├── app.dart                    # SiwoFlacApp + GoRouter + MaterialApp.builder (gradient)
│   ├── theme/
│   │   ├── nero_theme_extension.dart   # Prisma palette + glass tokens + gradient
│   │   ├── app_theme.dart              # only light() factory — dark() removed
│   │   └── dynamic_color_wrapper.dart  # no-op stub
│   ├── widgets/
│   │   ├── liquid_glass_surface.dart   # 4-variant glass widget
│   │   ├── settings_group.dart         # uses LiquidGlassSurface(card)
│   │   ├── empty_state.dart           # Xianyun icon in glass pill
│   │   ├── error_state.dart
│   │   ├── show_helpers.dart          # showNeroDialog / showNeroSheet stubs
│   │   ├── animation_utils.dart       # BouncingIcon, SlidingIcon, SpinIcon, SwingIcon
│   │   ├── collapsing_header.dart      # shared SliverAppBar wrapper — bg MUST be transparent
│   │   └── nero/                      # legacy stubs (NeroButton, NeroTag, …) — avoid
│   ├── screens/
│   │   ├── main_shell.dart            # gradient + glass bottom nav (variant: pill)
│   │   ├── home_tab.dart              # brand icon inline with title
│   │   ├── repo_tab.dart
│   │   ├── queue_tab.dart             # Library tab internals
│   │   ├── search_screen.dart
│   │   └── settings/                  # Appearance, About, App, Donate*, …
│   ├── providers/                    # Riverpod notifiers
│   ├── models/
│   └── services/                     # platform bridge, download, share intent, …
├── test/
└── releases/                        # APKs after build (not in git)
```

---

## Theme & design tokens

All tokens live in `lib/theme/nero_theme_extension.dart`. Never hard-code
hex values; pull from `NeroTheme.of(context).<token>`.

Deprecated Wiza-era aliases still resolve but should not be used in new code:

| Old name | Use this instead |
|----------|------------------|
| `nero.deepIris` | `nero.carbonInk` |
| `nero.royalAmethyst` | `nero.prismTeal` |
| `nero.lavenderGlow` | `nero.prismTeal` |
| `nero.twilightBeam` | `nero.prismTeal` |
| `nero.canvas` | `nero.paper` |
| `nero.carbon` | `nero.carbonInk` (alias still works) |
| `nero.mistViolet` | `nero.prismTeal` |
| `nero.gradientHeroWash` | `nero.gradientPageBg` |
| `nero.radiusPill` (1440) | `StadiumBorder` or 20px |

When Phase 3 migration is in flight, you'll see `// TODO(phase3)` markers
next to these. Don't add new call sites.

---

## Glass surfaces — usage rules

1. **Wrap, don't paint.** For any opaque background over the gradient,
   replace the `Container(color: …)` with `LiquidGlassSurface(variant: …)`.
2. **Sectioned lists** use `_buildVirtualizedResultSection`-style code in
   `home_tab.dart`. The variant is `card`. Per-item `borderRadius` is
   top-only for the first row, bottom-only for the last.
3. **Chips and buttons** use `variant: pill` with the `onTap` parameter.
4. **Search bars** use `variant: input` (15% white) — currently the
   `TextField` in `home_tab.dart` uses raw `fillColor: nero.paper` which is
   intentional opaque for legibility; only convert to glass if contrast
   reviews say so.
5. **Bottom nav** uses `variant: pill` (white) in `main_shell.dart`.
6. The user-visible bottom-nav selected indicator comes from the inner
   `NavigationBar`'s default M3 indicator. Don't override unless contrast is
   insufficient.

---

## Critical "do not introduce" pitfalls

These have bitten this codebase before. Do not regress them.

### Material 3 / Flutter API breakage

- `CardTheme` was renamed to `CardThemeData` in Flutter 3.44+.
- `PageTransitionsTheme` with custom builders causes issues — leave it as
  `const PageTransitionsTheme()`.
- `showDialog`'s `useRootNavigator` parameter is gone — remove it from all
  callers (and from the `show_helpers.dart` stub).
- `showBottomSheet`'s `showDragHandle` parameter is gone — remove from
  theme + dialogs.
- `SliverAppBar`'s `pinned / floating / snap / stretch / forceElevated`
  flags are deprecated — omit them.
- `FontWeight.w650` does not exist — use `FontWeight.w700` or `w600`.

### Background opacity

- Any `Scaffold(backgroundColor: …)` or `SliverAppBar(backgroundColor: …)`
  painted with **opaque** color hides the gradient. The current pattern is
  `backgroundColor: Colors.transparent` so the page gradient bleeds through.
- `CollapsingHeader` and similar shared SliverAppBar wrappers MUST keep
  `backgroundColor: Colors.transparent`.

### Theme system

- `app_theme.dart` exports **only `light()`**. Do not reintroduce `dark()`.
- `theme_mode` SharedPreferences key is cleaned on launch via
  `_legacyKeys` in `theme_provider.dart`. If you add another legacy key,
  append it there.
- The `seedColor` migration in `theme_provider.dart` maps Wiza-era purple
  values to `kDefaultSeedColor = 0xFF14B8A6`. Add new entries to
  `_wizaSeedColors` if you spot a leftover purple.

### Go backend native crash

`libgojni.so` may crash with SIGILL on `x86_64` emulators when built with
`--target-platform android-arm64`. Use `flutter run` (auto-detects host
arch) or build a universal APK. Don't waste time debugging the Go code
unless a release build also crashes.

---

## Common tasks

### Add a new screen

1. Create `lib/screens/<feature>/<screen_name>.dart` with a `ConsumerWidget`
   or `ConsumerStatefulWidget`.
2. Wrap the body in a Sliver-based `CustomScrollView` if it's a primary
   route, or a plain `Scaffold` if it's a sub-page.
3. Use `LiquidGlassSurface(variant: card)` for any list sections.
4. Add a route in `lib/app.dart` (GoRouter).
5. Add locale strings in `lib/l10n/arb/app_en.arb` (and `app_es.arb` if
   you want to localize immediately).
6. Run `flutter test`.

### Add a glass card to a list

Use `_buildVirtualizedResultSection` pattern from `home_tab.dart`. Don't
reimplement the radius math — copy the builder.

### Change the gradient

`lib/theme/nero_theme_extension.dart` line ~186. Update both the light
and dark `lerp` halves if you keep the lerp helper, or just one if you
only ship light.

### Bump version

1. `pubspec.yaml` — bump `version:` (e.g., `4.7.0+136` → `4.7.1+137`).
2. `android/app/build.gradle.kts` — bump `versionCode` / `versionName`.
3. `lib/l10n/arb/app_en.arb` — update any visible version strings
   (e.g., `appVersion`).
4. `CHANGES.md` — add a new section at the top documenting the changes.
5. Tag the release: `git tag v<version>` and `git push --tags`.
6. Build release APKs (arm64 + universal).
7. `gh release create v<version> --target main` with the APKs attached.

---

## Debugging tips

- **Search bar in home_tab.dart doesn't focus via adb** — the `_SearchProviderDropdown`
  prefixIcon intercepts taps on the left third. Tap on `x=540, y=425`
  *should* work after the keyboard hides; if not, real touch works
  but `adb shell input tap` is unreliable here.
- **Settings → Appearance `Light/Dark/System` chips are gone** — the
  `_ThemeModeSelector` was deleted in Phase 0.17 because the app is
  light-only. Don't reintroduce it.
- **Donate section is gone** — `settingsDonate`/`settingsDonateSubtitle`
  l10n strings remain for now but the SettingsItem and `DonatePage`
  import were removed in v4.7.0. Clean up the strings and `donate_page.dart`
  next pass.

---

## When stuck

1. **Re-read DESIGN.md** — the contract is usually already written.
2. **Grep for `colorScheme.surface` and `Colors.white`** — these often
   hide the gradient and should be `Colors.transparent` over the new
   glass surface.
3. **Check `lib/widgets/liquid_glass_surface.dart`** — the glass widget
   is the canonical way to do frosted surfaces. Re-implementing is
   usually wrong.
4. **Look at `home_tab.dart` line ~3140 (`_buildVirtualizedResultSection`)** —
   the canonical pattern for glass sections with proper per-item radius.
5. **Run `flutter analyze`** before committing.

---

## Git & release workflow

- Default branch: `main`
- Force-push is acceptable **only** when rewriting history to remove
  generated artifacts (e.g., accidentally committed `.hprof`).
- Always run `git pull --rebase` before pushing if you see
  `non-fast-forward`.
- Releases use `gh release create` with the APKs attached. Don't forget
  to delete the old release before recreating with new APKs (tag
  collisions).