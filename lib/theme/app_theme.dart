import 'package:flutter/material.dart';
import 'package:neroflac/theme/nero_theme_extension.dart';

/// Prisma-inspired light theme for SiwöFlac.
///
/// Dark mode is intentionally not supported — the entire design is
/// calibrated for the Prisma light aesthetic with Liquid Glass chrome
/// over a Deep Teal gradient page background.
class AppTheme {
  static const Color defaultSeedColor = Color(0xFF14B8A6); // Prism Teal

  static const String _displayFontFamily = 'Mona Sans';
  static const String _bodyFontFamily = 'Inter';
  static const String _monoFontFamily = 'JetBrains Mono';

  /// The single theme used across the app. Light only.
  static ThemeData light() {
    final scheme = ColorScheme.fromSeed(
      seedColor: defaultSeedColor,
      brightness: Brightness.light,
    ).copyWith(
      primary: NeroTheme.fallback.prismTeal,
      onPrimary: NeroTheme.fallback.paper,
      secondary: NeroTheme.fallback.deepTeal,
      onSecondary: NeroTheme.fallback.paper,
      surface: NeroTheme.fallback.paper,
      onSurface: NeroTheme.fallback.graphite,
      error: const Color(0xFFDC2626),
      onError: NeroTheme.fallback.paper,
    );
    final nero = NeroTheme.forBrightness(Brightness.light);
    return _build(scheme, nero);
  }

  static ThemeData _build(ColorScheme scheme, NeroTheme nero) {
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      pageTransitionsTheme: _pageTransitionsTheme,
      scaffoldBackgroundColor: Colors.transparent,
      canvasColor: nero.paper,
      dialogTheme: _dialogTheme(scheme, nero),
      extensions: <ThemeExtension<dynamic>>[nero],
      textTheme: _textTheme(scheme, nero),
      primaryTextTheme: _textTheme(scheme, nero),
      appBarTheme: _appBarTheme(scheme, nero),
      cardTheme: _cardTheme(scheme, nero),
      elevatedButtonTheme: _elevatedButtonTheme(scheme, nero),
      filledButtonTheme: _filledButtonTheme(scheme, nero),
      outlinedButtonTheme: _outlinedButtonTheme(scheme, nero),
      textButtonTheme: _textButtonTheme(scheme, nero),
      floatingActionButtonTheme: _fabTheme(scheme, nero),
      inputDecorationTheme: _inputDecorationTheme(scheme, nero),
      listTileTheme: _listTileTheme(scheme, nero),
      bottomSheetTheme: _bottomSheetTheme(scheme, nero),
      navigationBarTheme: _navigationBarTheme(scheme, nero),
      snackBarTheme: _snackBarTheme(scheme, nero),
      progressIndicatorTheme: _progressIndicatorTheme(scheme, nero),
      switchTheme: _switchTheme(scheme, nero),
      chipTheme: _chipTheme(scheme, nero),
      dividerTheme: _dividerTheme(scheme, nero),
      iconTheme: IconThemeData(color: nero.carbonInk),
      primaryIconTheme: IconThemeData(color: scheme.onPrimary),
      fontFamily: _bodyFontFamily,
    );
  }

  static final PageTransitionsTheme _pageTransitionsTheme =
      const PageTransitionsTheme();

  // === Typography (Prisma scale) ===
  static TextTheme _textTheme(ColorScheme scheme, NeroTheme nero) {
    final body = TextStyle(
      fontFamily: _bodyFontFamily,
      fontSize: 16,
      fontWeight: FontWeight.w400,
      height: 1.5,
      letterSpacing: 0.48,
      color: nero.graphite,
    );
    return TextTheme(
      displayLarge: TextStyle(
        fontFamily: _displayFontFamily,
        fontSize: 64,
        fontWeight: FontWeight.w900,
        height: 1.13,
        letterSpacing: 6.4,
        color: nero.carbonInk,
      ),
      displayMedium: TextStyle(
        fontFamily: _displayFontFamily,
        fontSize: 40,
        fontWeight: FontWeight.w900,
        height: 1.2,
        letterSpacing: 4,
        color: nero.carbonInk,
      ),
      displaySmall: TextStyle(
        fontFamily: _displayFontFamily,
        fontSize: 36,
        fontWeight: FontWeight.w900,
        height: 1.13,
        letterSpacing: 3.6,
        color: nero.carbonInk,
      ),
      headlineLarge: TextStyle(
        fontFamily: _displayFontFamily,
        fontSize: 30,
        fontWeight: FontWeight.w700,
        height: 1.2,
        letterSpacing: 3,
        color: nero.carbonInk,
      ),
      headlineMedium: TextStyle(
        fontFamily: _displayFontFamily,
        fontSize: 24,
        fontWeight: FontWeight.w700,
        height: 1.33,
        letterSpacing: 0.72,
        color: nero.carbonInk,
      ),
      headlineSmall: TextStyle(
        fontFamily: _displayFontFamily,
        fontSize: 22,
        fontWeight: FontWeight.w700,
        height: 1.33,
        letterSpacing: 0.44,
        color: nero.carbonInk,
      ),
      titleLarge: TextStyle(
        fontFamily: _displayFontFamily,
        fontSize: 22,
        fontWeight: FontWeight.w700,
        height: 1.33,
        letterSpacing: 0.44,
        color: nero.carbonInk,
      ),
      titleMedium: TextStyle(
        fontFamily: _bodyFontFamily,
        fontSize: 18,
        fontWeight: FontWeight.w600,
        height: 1.39,
        letterSpacing: 0.36,
        color: nero.carbonInk,
      ),
      titleSmall: TextStyle(
        fontFamily: _bodyFontFamily,
        fontSize: 14,
        fontWeight: FontWeight.w600,
        height: 1.43,
        letterSpacing: 0.32,
        color: nero.carbonInk,
      ),
      bodyLarge: body.copyWith(fontSize: 18),
      bodyMedium: body,
      bodySmall: TextStyle(
        fontFamily: _bodyFontFamily,
        fontSize: 14,
        fontWeight: FontWeight.w400,
        height: 1.43,
        letterSpacing: 0.32,
        color: nero.slate,
      ),
      labelLarge: TextStyle(
        fontFamily: _bodyFontFamily,
        fontSize: 16,
        fontWeight: FontWeight.w500,
        height: 1.5,
        letterSpacing: 0.48,
        color: nero.carbonInk,
      ),
      labelMedium: TextStyle(
        fontFamily: _bodyFontFamily,
        fontSize: 14,
        fontWeight: FontWeight.w500,
        height: 1.43,
        letterSpacing: 0.32,
        color: nero.carbonInk,
      ),
      labelSmall: TextStyle(
        fontFamily: _bodyFontFamily,
        fontSize: 11,
        fontWeight: FontWeight.w500,
        height: 1.45,
        letterSpacing: 0.33,
        color: nero.slate,
      ),
    );
  }

  // === App Bar — chrome glass handled by LiquidGlassSurface directly ===
  static AppBarTheme _appBarTheme(ColorScheme scheme, NeroTheme nero) =>
      AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        iconTheme: IconThemeData(color: nero.carbonInk),
        titleTextStyle: TextStyle(
          fontFamily: _displayFontFamily,
          fontWeight: FontWeight.w700,
          fontSize: 18,
          color: nero.carbonInk,
          letterSpacing: 0.4,
        ),
      );

  // === Cards — translucent glass surface, applied by caller via LiquidGlassSurface ===
  static CardThemeData _cardTheme(ColorScheme scheme, NeroTheme nero) =>
      CardThemeData(
        elevation: 0,
        margin: EdgeInsets.zero,
        color: nero.glassCard,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(nero.radiusLg),
        ),
      );

  // === Buttons ===
  static ElevatedButtonThemeData _elevatedButtonTheme(
          ColorScheme scheme, NeroTheme nero) =>
      ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: nero.prismTeal,
          foregroundColor: nero.paper,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(nero.radiusMd),
          ),
          textStyle: const TextStyle(
            fontFamily: _bodyFontFamily,
            fontSize: 14,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.32,
          ),
        ),
      );

  static FilledButtonThemeData _filledButtonTheme(
          ColorScheme scheme, NeroTheme nero) =>
      FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: nero.prismTeal,
          foregroundColor: nero.paper,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(nero.radiusMd),
          ),
          textStyle: const TextStyle(
            fontFamily: _bodyFontFamily,
            fontSize: 14,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.32,
          ),
        ),
      );

  static OutlinedButtonThemeData _outlinedButtonTheme(
          ColorScheme scheme, NeroTheme nero) =>
      OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: nero.carbonInk,
          side: BorderSide(color: nero.mist, width: 1),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(nero.radiusMd),
          ),
          textStyle: const TextStyle(
            fontFamily: _bodyFontFamily,
            fontSize: 14,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.32,
          ),
        ),
      );

  static TextButtonThemeData _textButtonTheme(
          ColorScheme scheme, NeroTheme nero) =>
      TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: nero.prismTeal,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(nero.radiusMd),
          ),
          textStyle: const TextStyle(
            fontFamily: _bodyFontFamily,
            fontSize: 14,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.32,
          ),
        ),
      );

  // === FAB ===
  static FloatingActionButtonThemeData _fabTheme(
          ColorScheme scheme, NeroTheme nero) =>
      FloatingActionButtonThemeData(
        backgroundColor: nero.prismTeal,
        foregroundColor: nero.paper,
        elevation: 0,
        focusElevation: 0,
        hoverElevation: 0,
        highlightElevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(nero.radiusLg),
        ),
      );

  // === Inputs — subtle hairline border, paper fill ===
  static InputDecorationTheme _inputDecorationTheme(
          ColorScheme scheme, NeroTheme nero) =>
      InputDecorationTheme(
        filled: true,
        fillColor: nero.bone,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        hintStyle: TextStyle(
          color: nero.fog,
          fontFamily: _bodyFontFamily,
          fontSize: 14,
          fontWeight: FontWeight.w400,
        ),
        labelStyle: TextStyle(
          color: nero.slate,
          fontFamily: _bodyFontFamily,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(nero.radiusMd),
          borderSide: BorderSide(color: nero.mist, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(nero.radiusMd),
          borderSide: BorderSide(color: nero.mist, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(nero.radiusMd),
          borderSide: BorderSide(color: nero.prismTeal, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(nero.radiusMd),
          borderSide: const BorderSide(color: Color(0xFFDC2626), width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(nero.radiusMd),
          borderSide: const BorderSide(color: Color(0xFFDC2626), width: 2),
        ),
      );

  // === List tile ===
  static ListTileThemeData _listTileTheme(
          ColorScheme scheme, NeroTheme nero) =>
      ListTileThemeData(
        iconColor: nero.carbonInk,
        textColor: nero.graphite,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
      );

  // === Bottom sheet ===
  static BottomSheetThemeData _bottomSheetTheme(
          ColorScheme scheme, NeroTheme nero) =>
      BottomSheetThemeData(
        elevation: 0,
        modalElevation: 0,
        
        dragHandleColor: nero.fog,
        backgroundColor: nero.paper,
        surfaceTintColor: Colors.transparent,
        modalBackgroundColor: nero.paper,
        modalBarrierColor: Colors.black.withValues(alpha: 0.4),
        shape: RoundedRectangleBorder(
          borderRadius:
              BorderRadius.vertical(top: Radius.circular(nero.radius2xl)),
        ),
      );

  // === NavigationBar — handled via LiquidGlassSurface in main_shell ===
  static NavigationBarThemeData _navigationBarTheme(
          ColorScheme scheme, NeroTheme nero) =>
      NavigationBarThemeData(
        elevation: 0,
        height: 72,
        backgroundColor: Colors.transparent,
        indicatorColor: nero.glassPill,
        surfaceTintColor: Colors.transparent,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return IconThemeData(color: nero.deepTeal, size: 24);
          }
          return IconThemeData(color: nero.slate, size: 24);
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return TextStyle(
              fontFamily: _bodyFontFamily,
              fontWeight: FontWeight.w600,
              fontSize: 12,
              height: 1.0,
              color: nero.carbonInk,
            );
          }
          return TextStyle(
            fontFamily: _bodyFontFamily,
            fontWeight: FontWeight.w500,
            fontSize: 12,
            height: 1.0,
            color: nero.slate,
          );
        }),
      );

  // === SnackBar ===
  static SnackBarThemeData _snackBarTheme(
          ColorScheme scheme, NeroTheme nero) =>
      SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(nero.radiusMd),
        ),
        backgroundColor: nero.carbonInk,
        contentTextStyle: TextStyle(
          fontFamily: _bodyFontFamily,
          fontWeight: FontWeight.w500,
          fontSize: 14,
          color: nero.paper,
        ),
        actionTextColor: nero.prismTeal,
      );

  // === Progress ===
  static ProgressIndicatorThemeData _progressIndicatorTheme(
          ColorScheme scheme, NeroTheme nero) =>
      ProgressIndicatorThemeData(
        color: nero.prismTeal,
        linearTrackColor: nero.mist,
        circularTrackColor: nero.mist,
      );

  // === Switch ===
  static SwitchThemeData _switchTheme(ColorScheme scheme, NeroTheme nero) =>
      SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return nero.paper;
          return nero.fog;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return nero.prismTeal;
          return nero.mist;
        }),
        trackOutlineColor:
            WidgetStateProperty.all(Colors.transparent),
      );

  // === Chip ===
  static ChipThemeData _chipTheme(ColorScheme scheme, NeroTheme nero) =>
      ChipThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(nero.radiusMd),
          side: BorderSide.none,
        ),
        backgroundColor: nero.bone,
        selectedColor: nero.prismTeal,
        labelStyle: TextStyle(
          fontFamily: _bodyFontFamily,
          fontWeight: FontWeight.w500,
          fontSize: 12,
          color: nero.carbonInk,
        ),
        secondaryLabelStyle: TextStyle(
          fontFamily: _bodyFontFamily,
          fontWeight: FontWeight.w500,
          fontSize: 12,
          color: nero.paper,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        side: BorderSide.none,
      );

  // === Divider ===
  static DividerThemeData _dividerTheme(ColorScheme scheme, NeroTheme nero) =>
      DividerThemeData(
        color: nero.mist,
        thickness: 1,
        space: 1,
      );

  // === Dialog ===
  static DialogThemeData _dialogTheme(ColorScheme scheme, NeroTheme nero) =>
      DialogThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(nero.radiusLg),
        ),
        backgroundColor: nero.paper,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: TextStyle(
          fontFamily: _displayFontFamily,
          fontWeight: FontWeight.w700,
          fontSize: 20,
          color: nero.carbonInk,
        ),
        contentTextStyle: TextStyle(
          fontFamily: _bodyFontFamily,
          fontWeight: FontWeight.w400,
          fontSize: 14,
          color: nero.graphite,
          height: 1.43,
        ),
      );
}