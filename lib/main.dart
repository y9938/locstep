import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_config.dart';
import 'data/image_cache_service.dart';
import 'widgets/navigation_screen.dart';
import 'providers/locale_provider.dart';
import 'providers/text_scale_provider.dart';
import 'providers/theme_provider.dart';
import 'providers/confirm_3d_tour_provider.dart';

// Генерируется автоматически через flutter gen-l10n
import 'l10n/app_localizations.dart';

void main() {
  runApp(const LocstepApp());
}

/// Строит ThemeData с TextTheme, привязанным к [colorScheme].
/// GoogleFonts.nunitoTextTheme() по умолчанию даёт стили с фиксированным цветом (под светлую тему),
/// поэтому без apply() текст в тёмной теме остаётся тёмным. Привязка к onSurface/displayColor это исправляет.
ThemeData _buildTheme(ColorScheme colorScheme) {
  return ThemeData(
    colorScheme: colorScheme,
    useMaterial3: true,
    textTheme: GoogleFonts.nunitoTextTheme().apply(
      bodyColor: colorScheme.onSurface,
      displayColor: colorScheme.onSurface,
    ),
  );
}

class LocstepApp extends StatelessWidget {
  const LocstepApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<ImageCacheService>(create: (_) => ImageCacheService()),
        ChangeNotifierProvider(create: (_) => LocaleProvider()),
        ChangeNotifierProvider(create: (_) => TextScaleProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => Confirm3dTourProvider()),
      ],
      child: Consumer3<LocaleProvider, TextScaleProvider, ThemeProvider>(
        builder: (context, localeProvider, textScaleProvider, themeProvider, child) {
          // Показываем загрузку пока тема инициализируется
          if (themeProvider.isLoading) {
            return MaterialApp(
              debugShowCheckedModeBanner: false,
              home: Scaffold(
                body: Center(
                  child: CircularProgressIndicator(),
                ),
              ),
            );
          }

          return MediaQuery(
            // Применяем масштаб текста ко всему приложению
            data: MediaQuery.of(context).copyWith(
              textScaler: TextScaler.linear(textScaleProvider.textScale),
            ),
            child: MaterialApp(
              title: AppConfig.appName,
              debugShowCheckedModeBanner: false,
              theme: _buildTheme(
                themeProvider.colorScheme(Brightness.light),
              ),
              darkTheme: _buildTheme(
                themeProvider.colorScheme(Brightness.dark),
              ),
              themeMode: themeProvider.themeMode,
              localizationsDelegates: const [
                AppLocalizations.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              supportedLocales: const [
                Locale('en'),
                Locale('ru'),
              ],
              locale: localeProvider.locale,
              home: const NavigationScreen(),
            ),
          );
        },
      ),
    );
  }
}
