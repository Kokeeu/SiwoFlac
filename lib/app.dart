import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:neroflac/constants/app_info.dart';
import 'package:neroflac/screens/main_shell.dart';
import 'package:neroflac/screens/setup_screen.dart';
import 'package:neroflac/screens/tutorial_screen.dart';
import 'package:neroflac/providers/settings_provider.dart';
import 'package:neroflac/theme/dynamic_color_wrapper.dart';
import 'package:neroflac/theme/app_theme.dart';
import 'package:neroflac/theme/nero_theme_extension.dart';
import 'package:neroflac/l10n/app_localizations.dart';

final _routerProvider = Provider<GoRouter>((ref) {
  final isFirstLaunch = ref.watch(
    settingsProvider.select((s) => s.isFirstLaunch),
  );
  final hasCompletedTutorial = ref.watch(
    settingsProvider.select((s) => s.hasCompletedTutorial),
  );

  String initialLocation;
  if (isFirstLaunch) {
    initialLocation = '/setup';
  } else if (!hasCompletedTutorial) {
    initialLocation = '/tutorial';
  } else {
    initialLocation = '/';
  }

  return GoRouter(
    initialLocation: initialLocation,
    routes: [
      GoRoute(path: '/', builder: (context, state) => const MainShell()),
      GoRoute(path: '/setup', builder: (context, state) => const SetupScreen()),
      GoRoute(
        path: '/tutorial',
        builder: (context, state) => const TutorialScreen(),
      ),
    ],
    // Safety net: if a deep link URL (e.g. Spotify/Deezer) somehow reaches
    // GoRouter, redirect to home instead of showing "Page Not Found".
    errorBuilder: (context, state) => const MainShell(),
  );
});

Locale _fallbackLocale(Iterable<Locale> supportedLocales) {
  for (final supportedLocale in supportedLocales) {
    if (supportedLocale.languageCode == 'en') {
      return supportedLocale;
    }
  }
  return supportedLocales.first;
}

Locale _resolveSupportedLocale(
  Locale? requestedLocale,
  Iterable<Locale> supportedLocales,
) {
  if (requestedLocale == null) {
    return _fallbackLocale(supportedLocales);
  }

  for (final supportedLocale in supportedLocales) {
    if (supportedLocale.languageCode == requestedLocale.languageCode &&
        supportedLocale.countryCode == requestedLocale.countryCode) {
      return supportedLocale;
    }
  }

  for (final supportedLocale in supportedLocales) {
    if (supportedLocale.languageCode == requestedLocale.languageCode) {
      return supportedLocale;
    }
  }

  return _fallbackLocale(supportedLocales);
}

class SiwoFlacApp extends ConsumerWidget {
  final bool disableOverscrollEffects;

  const SiwoFlacApp({super.key, this.disableOverscrollEffects = false});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(_routerProvider);
    final localeString = ref.watch(settingsProvider.select((s) => s.locale));
    final scrollBehavior = disableOverscrollEffects
        ? const MaterialScrollBehavior().copyWith(overscroll: false)
        : null;

    Locale? locale;
    if (localeString != 'system' && localeString.isNotEmpty) {
      if (localeString.contains('_')) {
        final parts = localeString.split('_');
        if (parts.length == 2) {
          locale = Locale(parts[0], parts[1]);
        } else {
          locale = Locale(parts[0]);
        }
      } else {
        locale = Locale(localeString);
      }
    }

    return MaterialApp.router(
      title: AppInfo.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      scrollBehavior: scrollBehavior,
      themeAnimationDuration: const Duration(milliseconds: 300),
      themeAnimationCurve: Curves.easeInOut,
      builder: (context, child) {
        final mediaQuery = MediaQuery.of(context);
        final nero = Theme.of(context).extension<NeroTheme>();
        return MediaQuery(
          data: mediaQuery.copyWith(displayFeatures: const []),
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: nero?.gradientPageBg,
            ),
            child: child ?? const SizedBox.shrink(),
          ),
        );
      },
      routerConfig: router,
      locale: locale,
      localeResolutionCallback: (deviceLocale, supportedLocales) {
        return _resolveSupportedLocale(
          locale ?? deviceLocale,
          supportedLocales,
        );
      },
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
    );
  }
}
