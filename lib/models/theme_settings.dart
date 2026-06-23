import 'package:flutter/material.dart';

const String kThemeModeKey = 'theme_mode';
const String kUseDynamicColorKey = 'use_dynamic_color';
const String kSeedColorKey = 'seed_color';
const String kUseAmoledKey = 'use_amoled';

// === Dope Security color tokens (subset) ===
// Vivid violet (#AF50FF) on near-black canvas (#090909).
const int kColorVoid = 0xFF090909;
const int kColorBoneWhite = 0xFFF7F9FA;
const int kColorAsh = 0xFFF0F0F0;
const int kColorSlate = 0xFF6B6B6B;
const int kColorGraphite = 0xFF454545;
const int kColorSmoke = 0xFF828384;
const int kColorIron = 0xFF333333;
const int kColorCinder = 0xFF423738;
const int kColorIris = 0xFFAF50FF;
const int kColorPlum = 0xFF7F56D9;
const int kColorAubergine = 0xFF271635;
const int kColorStormGray = 0xFF475467;
const int kColorLavenderWash = 0xFFE1BDFF;
const int kColorOrchidRadial = 0xFF6C4BD6;
const int kColorAmethystBand = 0xFF4823B4;

/// Default NeroFlac brand color — Dope Security's Iris (vivid violet).
const int kDefaultSeedColor = kColorIris;

class ThemeSettings {
  final ThemeMode themeMode;
  final bool useDynamicColor;
  final int seedColorValue;
  final bool useAmoled;

  const ThemeSettings({
    this.themeMode = ThemeMode.dark,
    this.useDynamicColor = true,
    this.seedColorValue = kDefaultSeedColor,
    this.useAmoled = false,
  });

  Color get seedColor => Color(seedColorValue);

  ThemeSettings copyWith({
    ThemeMode? themeMode,
    bool? useDynamicColor,
    int? seedColorValue,
    bool? useAmoled,
  }) {
    return ThemeSettings(
      themeMode: themeMode ?? this.themeMode,
      useDynamicColor: useDynamicColor ?? this.useDynamicColor,
      seedColorValue: seedColorValue ?? this.seedColorValue,
      useAmoled: useAmoled ?? this.useAmoled,
    );
  }

  Map<String, dynamic> toJson() => {
    kThemeModeKey: themeMode.name,
    kUseDynamicColorKey: useDynamicColor,
    kSeedColorKey: seedColorValue,
    kUseAmoledKey: useAmoled,
  };

  factory ThemeSettings.fromJson(Map<String, dynamic> json) {
    return ThemeSettings(
      themeMode: themeModeFromString(json[kThemeModeKey] as String?),
      useDynamicColor: json[kUseDynamicColorKey] as bool? ?? true,
      seedColorValue: json[kSeedColorKey] as int? ?? kDefaultSeedColor,
      useAmoled: json[kUseAmoledKey] as bool? ?? false,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ThemeSettings &&
        other.themeMode == themeMode &&
        other.useDynamicColor == useDynamicColor &&
        other.seedColorValue == seedColorValue &&
        other.useAmoled == useAmoled;
  }

  @override
  int get hashCode =>
      themeMode.hashCode ^
      useDynamicColor.hashCode ^
      seedColorValue.hashCode ^
      useAmoled.hashCode;
}

ThemeMode themeModeFromString(String? value) {
  if (value == null) return ThemeMode.dark;
  return ThemeMode.values.firstWhere(
    (e) => e.name == value,
    orElse: () => ThemeMode.dark,
  );
}
