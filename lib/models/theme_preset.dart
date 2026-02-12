import 'package:flutter/material.dart';

/// Пресет темы — встроенная или пользовательская.
///
/// **Хранение встроенных тем:** в .dart (как сейчас), не в JSON.
/// • Типобезопасность, рефакторинг, нет парсинга при старте.
/// • JSON имел бы смысл при редактировании тем без пересборки или при загрузке из сети;
///   для 3 фиксированных пресетов выигрыша нет, только лишний код и риски ошибок формата.
@immutable
class ThemePreset {
  final String id;
  final String name;
  final String? description;
  final bool isBuiltIn;
  
  // Основные цвета
  final Color primary;
  final Color onPrimary;
  final Color primaryContainer;
  final Color onPrimaryContainer;
  
  // Вторичные цвета
  final Color secondary;
  final Color onSecondary;
  final Color secondaryContainer;
  final Color onSecondaryContainer;
  
  // Третичные цвета
  final Color tertiary;
  final Color onTertiary;
  final Color tertiaryContainer;
  final Color onTertiaryContainer;
  
  // Цвета ошибок
  final Color error;
  final Color onError;
  final Color errorContainer;
  final Color onErrorContainer;
  
  // Поверхности
  final Color surface;
  final Color onSurface;
  final Color surfaceContainerHighest;
  final Color onSurfaceVariant;
  
  // Обводка и тени
  final Color outline;
  final Color outlineVariant;
  final Color shadow;
  final Color scrim;
  
  // Инверсные цвета
  final Color inverseSurface;
  final Color onInverseSurface;
  final Color inversePrimary;
  final Color surfaceTint;

  /// Тёмная палитра. Обязательна; для встроенных тем — ручная подборка.
  /// При десериализации кастомной темы подставляется [defaultDarkColorScheme].
  final ColorScheme darkColorScheme;

  const ThemePreset({
    required this.id,
    required this.name,
    this.description,
    this.isBuiltIn = false,
    required this.primary,
    required this.onPrimary,
    required this.primaryContainer,
    required this.onPrimaryContainer,
    required this.secondary,
    required this.onSecondary,
    required this.secondaryContainer,
    required this.onSecondaryContainer,
    required this.tertiary,
    required this.onTertiary,
    required this.tertiaryContainer,
    required this.onTertiaryContainer,
    required this.error,
    required this.onError,
    required this.errorContainer,
    required this.onErrorContainer,
    required this.surface,
    required this.onSurface,
    required this.surfaceContainerHighest,
    required this.onSurfaceVariant,
    required this.outline,
    required this.outlineVariant,
    required this.shadow,
    required this.scrim,
    required this.inverseSurface,
    required this.onInverseSurface,
    required this.inversePrimary,
    required this.surfaceTint,
    required this.darkColorScheme,
  });

  // ----- Тёмные палитры для встроенных тем -----

  static ColorScheme get _darkOceanBlue => const ColorScheme(
        brightness: Brightness.dark,
        primary: Color(0xFF9FCBFC),
        onPrimary: Color(0xFF003258),
        primaryContainer: Color(0xFF00497D),
        onPrimaryContainer: Color(0xFFD2E4FF),
        secondary: Color(0xFFBBC7DB),
        onSecondary: Color(0xFF1C2532),
        secondaryContainer: Color(0xFF3B4858),
        onSecondaryContainer: Color(0xFFD7E3F7),
        tertiary: Color(0xFF7BDAF6),
        onTertiary: Color(0xFF003544),
        tertiaryContainer: Color(0xFF004D61),
        onTertiaryContainer: Color(0xFFB6EAFF),
        error: Color(0xFFFFB4AB),
        onError: Color(0xFF690005),
        errorContainer: Color(0xFF93000A),
        onErrorContainer: Color(0xFFFFDAD6),
        surface: Color(0xFF0F1218),
        onSurface: Color(0xFFE8EAEF),
        surfaceDim: Color(0xFF0F1218),
        surfaceBright: Color(0xFF363A42),
        surfaceContainerLowest: Color(0xFF0A0D11),
        surfaceContainerLow: Color(0xFF171A20),
        surfaceContainer: Color(0xFF1B1E25),
        surfaceContainerHigh: Color(0xFF262A31),
        surfaceContainerHighest: Color(0xFF31353C),
        onSurfaceVariant: Color(0xFFD0D4DC),
        outline: Color(0xFF9A9EA7),
        outlineVariant: Color(0xFF4A4E56),
        shadow: Color(0xFF000000),
        scrim: Color(0xFF000000),
        inverseSurface: Color(0xFFE8EAEF),
        onInverseSurface: Color(0xFF2E3138),
        inversePrimary: Color(0xFF36618E),
        surfaceTint: Color(0xFF9FCBFC),
      );

  static ColorScheme get _darkForestGreen => const ColorScheme(
        brightness: Brightness.dark,
        primary: Color(0xFF9FD9A4),
        onPrimary: Color(0xFF00390B),
        primaryContainer: Color(0xFF005318),
        onPrimaryContainer: Color(0xFFBBF5C0),
        secondary: Color(0xFFBBCBB2),
        onSecondary: Color(0xFF1E2A1C),
        secondaryContainer: Color(0xFF3C4B37),
        onSecondaryContainer: Color(0xFFD7E8CD),
        tertiary: Color(0xFFA0CFD4),
        onTertiary: Color(0xFF00363B),
        tertiaryContainer: Color(0xFF1F4D52),
        onTertiaryContainer: Color(0xFFBCEBF0),
        error: Color(0xFFFFB4AB),
        onError: Color(0xFF690005),
        errorContainer: Color(0xFF93000A),
        onErrorContainer: Color(0xFFFFDAD6),
        surface: Color(0xFF0E130E),
        onSurface: Color(0xFFE6EBE5),
        surfaceDim: Color(0xFF0E130E),
        surfaceBright: Color(0xFF343B34),
        surfaceContainerLowest: Color(0xFF090E09),
        surfaceContainerLow: Color(0xFF161C16),
        surfaceContainer: Color(0xFF1B211B),
        surfaceContainerHigh: Color(0xFF262C26),
        surfaceContainerHighest: Color(0xFF313831),
        onSurfaceVariant: Color(0xFFCFD5CC),
        outline: Color(0xFF99A098),
        outlineVariant: Color(0xFF454D43),
        shadow: Color(0xFF000000),
        scrim: Color(0xFF000000),
        inverseSurface: Color(0xFFE6EBE5),
        onInverseSurface: Color(0xFF2D332C),
        inversePrimary: Color(0xFF2E7D32),
        surfaceTint: Color(0xFF9FD9A4),
      );

  static ColorScheme get _darkSunsetOrange => const ColorScheme(
        brightness: Brightness.dark,
        primary: Color(0xFFFFB599),
        onPrimary: Color(0xFF5C1900),
        primaryContainer: Color(0xFF832800),
        onPrimaryContainer: Color(0xFFFFDBCD),
        secondary: Color(0xFFE8BDB0),
        onSecondary: Color(0xFF382218),
        secondaryContainer: Color(0xFF5D4035),
        onSecondaryContainer: Color(0xFFFFDBCD),
        tertiary: Color(0xFFDBC78E),
        onTertiary: Color(0xFF3A3300),
        tertiaryContainer: Color(0xFF524A00),
        onTertiaryContainer: Color(0xFFF8E08C),
        error: Color(0xFFFFB4AB),
        onError: Color(0xFF690005),
        errorContainer: Color(0xFF93000A),
        onErrorContainer: Color(0xFFFFDAD6),
        surface: Color(0xFF15100E),
        onSurface: Color(0xFFEDE4E0),
        surfaceDim: Color(0xFF15100E),
        surfaceBright: Color(0xFF38312E),
        surfaceContainerLowest: Color(0xFF0F0B0A),
        surfaceContainerLow: Color(0xFF1E1917),
        surfaceContainer: Color(0xFF231E1C),
        surfaceContainerHigh: Color(0xFF2E2826),
        surfaceContainerHighest: Color(0xFF3A3331),
        onSurfaceVariant: Color(0xFFDDCAC2),
        outline: Color(0xFFA8968E),
        outlineVariant: Color(0xFF4F423C),
        shadow: Color(0xFF000000),
        scrim: Color(0xFF000000),
        inverseSurface: Color(0xFFEDE4E0),
        onInverseSurface: Color(0xFF3A332F),
        inversePrimary: Color(0xFFE65100),
        surfaceTint: Color(0xFFFFB599),
      );

  /// Встроенная тема Ocean Blue (текущая)
  static ThemePreset get oceanBlue => ThemePreset(
    id: 'ocean_blue',
    name: 'Ocean Blue',
    description: 'Classic blue theme',
    isBuiltIn: true,
    primary: const Color(0xFF36618E),
    onPrimary: const Color(0xFFFFFFFF),
    primaryContainer: const Color(0xFFD1E4FF),
    onPrimaryContainer: const Color(0xFF001D36),
    secondary: const Color(0xFF535F70),
    onSecondary: const Color(0xFFFFFFFF),
    secondaryContainer: const Color(0xFFD7E3F7),
    onSecondaryContainer: const Color(0xFF101C2B),
    tertiary: const Color(0xFF00609C),
    onTertiary: const Color(0xFFFFFFFF),
    tertiaryContainer: const Color(0xFFD1E4FF),
    onTertiaryContainer: const Color(0xFF001D36),
    error: const Color(0xFFBA1A1A),
    onError: const Color(0xFFFFFFFF),
    errorContainer: const Color(0xFFFFDAD6),
    onErrorContainer: const Color(0xFF410002),
    surface: const Color(0xFFF2F3FA),
    onSurface: const Color(0xFF191C20),
    surfaceContainerHighest: const Color(0xFFE1E2E8),
    onSurfaceVariant: const Color(0xFF43474E),
    outline: const Color(0xFF73777F),
    outlineVariant: const Color(0xFFC3C6CF),
    shadow: const Color(0xFF000000),
    scrim: const Color(0xFF000000),
    inverseSurface: const Color(0xFF2E3135),
    onInverseSurface: const Color(0xFFEFF0F7),
    inversePrimary: const Color(0xFFA0CAFD),
    surfaceTint: const Color(0xFF36618E),
    darkColorScheme: _darkOceanBlue,
  );

  /// Встроенная тема Forest Green
  static ThemePreset get forestGreen => ThemePreset(
    id: 'forest_green',
    name: 'Forest Green',
    description: 'Natural green theme',
    isBuiltIn: true,
    primary: const Color(0xFF2E7D32),
    onPrimary: const Color(0xFFFFFFFF),
    primaryContainer: const Color(0xFFB9F6CA),
    onPrimaryContainer: const Color(0xFF002106),
    secondary: const Color(0xFF53634E),
    onSecondary: const Color(0xFFFFFFFF),
    secondaryContainer: const Color(0xFFD7E8CD),
    onSecondaryContainer: const Color(0xFF121F0E),
    tertiary: const Color(0xFF38656A),
    onTertiary: const Color(0xFFFFFFFF),
    tertiaryContainer: const Color(0xFFBCEBEF),
    onTertiaryContainer: const Color(0xFF002023),
    error: const Color(0xFFBA1A1A),
    onError: const Color(0xFFFFFFFF),
    errorContainer: const Color(0xFFFFDAD6),
    onErrorContainer: const Color(0xFF410002),
    surface: const Color(0xFFF5FAF4),
    onSurface: const Color(0xFF171D17),
    surfaceContainerHighest: const Color(0xFFE0E5DE),
    onSurfaceVariant: const Color(0xFF42493F),
    outline: const Color(0xFF72796F),
    outlineVariant: const Color(0xFFC2C9BC),
    shadow: const Color(0xFF000000),
    scrim: const Color(0xFF000000),
    inverseSurface: const Color(0xFF2C322B),
    onInverseSurface: const Color(0xFFEDF2EB),
    inversePrimary: const Color(0xFF9BD4A0),
    surfaceTint: const Color(0xFF2E7D32),
    darkColorScheme: _darkForestGreen,
  );

  /// Встроенная тема Sunset Orange
  static ThemePreset get sunsetOrange => ThemePreset(
    id: 'sunset_orange',
    name: 'Sunset Orange',
    description: 'Warm orange theme',
    isBuiltIn: true,
    primary: const Color(0xFFE65100),
    onPrimary: const Color(0xFFFFFFFF),
    primaryContainer: const Color(0xFFFFDBCD),
    onPrimaryContainer: const Color(0xFF360F00),
    secondary: const Color(0xFF77574A),
    onSecondary: const Color(0xFFFFFFFF),
    secondaryContainer: const Color(0xFFFFDBCD),
    onSecondaryContainer: const Color(0xFF2C160C),
    tertiary: const Color(0xFF675F30),
    onTertiary: const Color(0xFFFFFFFF),
    tertiaryContainer: const Color(0xFFEFE3A8),
    onTertiaryContainer: const Color(0xFF201C00),
    error: const Color(0xFFBA1A1A),
    onError: const Color(0xFFFFFFFF),
    errorContainer: const Color(0xFFFFDAD6),
    onErrorContainer: const Color(0xFF410002),
    surface: const Color(0xFFFFF8F6),
    onSurface: const Color(0xFF231A16),
    surfaceContainerHighest: const Color(0xFFECE0DC),
    onSurfaceVariant: const Color(0xFF53443E),
    outline: const Color(0xFF85736C),
    outlineVariant: const Color(0xFFD7C2B9),
    shadow: const Color(0xFF000000),
    scrim: const Color(0xFF000000),
    inverseSurface: const Color(0xFF392E2A),
    onInverseSurface: const Color(0xFFFFEDE8),
    inversePrimary: const Color(0xFFFFB599),
    surfaceTint: const Color(0xFFE65100),
    darkColorScheme: _darkSunsetOrange,
  );

  /// Список всех встроенных тем
  static List<ThemePreset> get builtInThemes => [
    oceanBlue,
    forestGreen,
    sunsetOrange,
  ];

  /// Создать ColorScheme из пресета для заданной яркости.
  /// Тёмная тема всегда берётся из [darkColorScheme]
  ColorScheme toColorScheme([Brightness brightness = Brightness.light]) {
    if (brightness == Brightness.dark) {
      return darkColorScheme;
    }
    return ColorScheme(
    brightness: Brightness.light,
    primary: primary,
    onPrimary: onPrimary,
    primaryContainer: primaryContainer,
    onPrimaryContainer: onPrimaryContainer,
    secondary: secondary,
    onSecondary: onSecondary,
    secondaryContainer: secondaryContainer,
    onSecondaryContainer: onSecondaryContainer,
    tertiary: tertiary,
    onTertiary: onTertiary,
    tertiaryContainer: tertiaryContainer,
    onTertiaryContainer: onTertiaryContainer,
    error: error,
    onError: onError,
    errorContainer: errorContainer,
    onErrorContainer: onErrorContainer,
    surface: surface,
    onSurface: onSurface,
    surfaceContainerHighest: surfaceContainerHighest,
    onSurfaceVariant: onSurfaceVariant,
    outline: outline,
    outlineVariant: outlineVariant,
    shadow: shadow,
    scrim: scrim,
    inverseSurface: inverseSurface,
    onInverseSurface: onInverseSurface,
    inversePrimary: inversePrimary,
    surfaceTint: surfaceTint,
  );
  }

  /// Копировать с изменениями
  ThemePreset copyWith({
    String? id,
    String? name,
    String? description,
    bool? isBuiltIn,
    Color? primary,
    Color? onPrimary,
    Color? primaryContainer,
    Color? onPrimaryContainer,
    Color? secondary,
    Color? onSecondary,
    Color? secondaryContainer,
    Color? onSecondaryContainer,
    Color? tertiary,
    Color? onTertiary,
    Color? tertiaryContainer,
    Color? onTertiaryContainer,
    Color? error,
    Color? onError,
    Color? errorContainer,
    Color? onErrorContainer,
    Color? surface,
    Color? onSurface,
    Color? surfaceContainerHighest,
    Color? onSurfaceVariant,
    Color? outline,
    Color? outlineVariant,
    Color? shadow,
    Color? scrim,
    Color? inverseSurface,
    Color? onInverseSurface,
    Color? inversePrimary,
    Color? surfaceTint,
    ColorScheme? darkColorScheme,
  }) {
    return ThemePreset(
      darkColorScheme: darkColorScheme ?? this.darkColorScheme,
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      isBuiltIn: isBuiltIn ?? this.isBuiltIn,
      primary: primary ?? this.primary,
      onPrimary: onPrimary ?? this.onPrimary,
      primaryContainer: primaryContainer ?? this.primaryContainer,
      onPrimaryContainer: onPrimaryContainer ?? this.onPrimaryContainer,
      secondary: secondary ?? this.secondary,
      onSecondary: onSecondary ?? this.onSecondary,
      secondaryContainer: secondaryContainer ?? this.secondaryContainer,
      onSecondaryContainer: onSecondaryContainer ?? this.onSecondaryContainer,
      tertiary: tertiary ?? this.tertiary,
      onTertiary: onTertiary ?? this.onTertiary,
      tertiaryContainer: tertiaryContainer ?? this.tertiaryContainer,
      onTertiaryContainer: onTertiaryContainer ?? this.onTertiaryContainer,
      error: error ?? this.error,
      onError: onError ?? this.onError,
      errorContainer: errorContainer ?? this.errorContainer,
      onErrorContainer: onErrorContainer ?? this.onErrorContainer,
      surface: surface ?? this.surface,
      onSurface: onSurface ?? this.onSurface,
      surfaceContainerHighest: surfaceContainerHighest ?? this.surfaceContainerHighest,
      onSurfaceVariant: onSurfaceVariant ?? this.onSurfaceVariant,
      outline: outline ?? this.outline,
      outlineVariant: outlineVariant ?? this.outlineVariant,
      shadow: shadow ?? this.shadow,
      scrim: scrim ?? this.scrim,
      inverseSurface: inverseSurface ?? this.inverseSurface,
      onInverseSurface: onInverseSurface ?? this.onInverseSurface,
      inversePrimary: inversePrimary ?? this.inversePrimary,
      surfaceTint: surfaceTint ?? this.surfaceTint,
    );
  }

  /// Экспорт в JSON
  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'description': description,
    'isBuiltIn': isBuiltIn,
    'colors': {
      'primary': primary.toARGB32(),
      'onPrimary': onPrimary.toARGB32(),
      'primaryContainer': primaryContainer.toARGB32(),
      'onPrimaryContainer': onPrimaryContainer.toARGB32(),
      'secondary': secondary.toARGB32(),
      'onSecondary': onSecondary.toARGB32(),
      'secondaryContainer': secondaryContainer.toARGB32(),
      'onSecondaryContainer': onSecondaryContainer.toARGB32(),
      'tertiary': tertiary.toARGB32(),
      'onTertiary': onTertiary.toARGB32(),
      'tertiaryContainer': tertiaryContainer.toARGB32(),
      'onTertiaryContainer': onTertiaryContainer.toARGB32(),
      'error': error.toARGB32(),
      'onError': onError.toARGB32(),
      'errorContainer': errorContainer.toARGB32(),
      'onErrorContainer': onErrorContainer.toARGB32(),
      'surface': surface.toARGB32(),
      'onSurface': onSurface.toARGB32(),
      'surfaceContainerHighest': surfaceContainerHighest.toARGB32(),
      'onSurfaceVariant': onSurfaceVariant.toARGB32(),
      'outline': outline.toARGB32(),
      'outlineVariant': outlineVariant.toARGB32(),
      'shadow': shadow.toARGB32(),
      'scrim': scrim.toARGB32(),
      'inverseSurface': inverseSurface.toARGB32(),
      'onInverseSurface': onInverseSurface.toARGB32(),
      'inversePrimary': inversePrimary.toARGB32(),
      'surfaceTint': surfaceTint.toARGB32(),
    },
  };

  /// Дефолтная тёмная палитра для тем, загруженных из JSON (без своей тёмной схемы).
  static ColorScheme get defaultDarkColorScheme => _darkOceanBlue;

  /// Импорт из JSON (кастомные темы; тёмная палитра подставляется [defaultDarkColorScheme]).
  factory ThemePreset.fromJson(Map<String, dynamic> json) {
    final colors = json['colors'] as Map<String, dynamic>;
    return ThemePreset(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      isBuiltIn: json['isBuiltIn'] as bool? ?? false,
      primary: Color(colors['primary'] as int),
      onPrimary: Color(colors['onPrimary'] as int),
      primaryContainer: Color(colors['primaryContainer'] as int),
      onPrimaryContainer: Color(colors['onPrimaryContainer'] as int),
      secondary: Color(colors['secondary'] as int),
      onSecondary: Color(colors['onSecondary'] as int),
      secondaryContainer: Color(colors['secondaryContainer'] as int),
      onSecondaryContainer: Color(colors['onSecondaryContainer'] as int),
      tertiary: Color(colors['tertiary'] as int),
      onTertiary: Color(colors['onTertiary'] as int),
      tertiaryContainer: Color(colors['tertiaryContainer'] as int),
      onTertiaryContainer: Color(colors['onTertiaryContainer'] as int),
      error: Color(colors['error'] as int),
      onError: Color(colors['onError'] as int),
      errorContainer: Color(colors['errorContainer'] as int),
      onErrorContainer: Color(colors['onErrorContainer'] as int),
      surface: Color(colors['surface'] as int),
      onSurface: Color(colors['onSurface'] as int),
      surfaceContainerHighest: Color(colors['surfaceContainerHighest'] as int),
      onSurfaceVariant: Color(colors['onSurfaceVariant'] as int),
      outline: Color(colors['outline'] as int),
      outlineVariant: Color(colors['outlineVariant'] as int),
      shadow: Color(colors['shadow'] as int),
      scrim: Color(colors['scrim'] as int),
      inverseSurface: Color(colors['inverseSurface'] as int),
      onInverseSurface: Color(colors['onInverseSurface'] as int),
      inversePrimary: Color(colors['inversePrimary'] as int),
      surfaceTint: Color(colors['surfaceTint'] as int),
      darkColorScheme: defaultDarkColorScheme,
    );
  }
}
