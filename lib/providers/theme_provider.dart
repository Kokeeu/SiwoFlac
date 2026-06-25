import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:neroflac/models/theme_settings.dart';

final themeProvider = NotifierProvider<ThemeNotifier, ThemeSettings>(() {
  return ThemeNotifier();
});

/// Stale preference keys cleaned up after the Prisma redesign. The redesign
/// dropped dark mode and dynamic color, so any leftover values are removed
/// on the first launch after the upgrade.
const _legacyKeys = <String>[
  'theme_mode', // ThemeMode.light is now the only option
];

/// Wiza-era seed colors that should migrate to the new Prisma default
/// (Prism Teal) so legacy installs don't keep a purple `Brand color`.
const _wizaSeedColors = <int>{
  0xFF7C3AED, // original Wiza default (violeta)
  0xFF805AD5,
  0xFF553C9A,
  0xFF3E0079, // royalAmethyst
  0xFFB99AFF, // lavenderGlow
  0xFFCF8AFF, // twilightBeam
  0xFF1DB954, // pre-Wiza Spotify green
};

class ThemeNotifier extends Notifier<ThemeSettings> {
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  @override
  ThemeSettings build() {
    _loadFromStorage();
    return const ThemeSettings();
  }

  Future<void> _loadFromStorage() async {
    try {
      final prefs = await _prefs;

      // Clean stale preferences from the pre-Prisma rebrand.
      for (final k in _legacyKeys) {
        if (prefs.containsKey(k)) {
          await prefs.remove(k);
        }
      }

      final stored = prefs.getInt(kSeedColorKey);
      final seedColor = (stored != null && _wizaSeedColors.contains(stored))
          ? kDefaultSeedColor
          : (stored ?? kDefaultSeedColor);

      state = ThemeSettings(seedColorValue: seedColor);
    } catch (e) {
      debugPrint('Error loading theme settings: $e');
    }
  }

  Future<void> _saveToStorage() async {
    try {
      final prefs = await _prefs;
      await prefs.setInt(kSeedColorKey, state.seedColorValue);
    } catch (e) {
      debugPrint('Error saving theme settings: $e');
    }
  }

  Future<void> setSeedColor(Color color) async {
    state = state.copyWith(seedColorValue: color.toARGB32());
    await _saveToStorage();
  }

  Future<void> setSeedColorValue(int colorValue) async {
    state = state.copyWith(seedColorValue: colorValue);
    await _saveToStorage();
  }
}