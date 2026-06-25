import 'package:flutter/material.dart';

const String kSeedColorKey = 'seed_color';

/// Default SiwöFlac brand seed — Prism Teal (`#14b8a6`).
/// Used by [ColorScheme.fromSeed] to derive the light palette.
const int kColorPrismTeal = 0xFF14B8A6;
const int kDefaultSeedColor = kColorPrismTeal;

/// Theme configuration for SiwöFlac.
///
/// The redesign to Prisma's aesthetic dropped dark mode, AMOLED variants,
/// and dynamic color (Material You). Only a brand seed remains, and the
/// light theme is the only theme used.
class ThemeSettings {
  final int seedColorValue;

  const ThemeSettings({
    this.seedColorValue = kDefaultSeedColor,
  });

  Color get seedColor => Color(seedColorValue);

  ThemeSettings copyWith({
    int? seedColorValue,
  }) {
    return ThemeSettings(
      seedColorValue: seedColorValue ?? this.seedColorValue,
    );
  }

  Map<String, dynamic> toJson() => {
        kSeedColorKey: seedColorValue,
      };

  factory ThemeSettings.fromJson(Map<String, dynamic> json) {
    return ThemeSettings(
      seedColorValue: json[kSeedColorKey] as int? ?? kDefaultSeedColor,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ThemeSettings &&
        other.seedColorValue == seedColorValue;
  }

  @override
  int get hashCode => seedColorValue.hashCode;
}