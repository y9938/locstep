import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/theme_preset.dart';

/// Провайдер для управления темами приложения
class ThemeProvider extends ChangeNotifier {
  static const String _activeThemeIdKey = 'active_theme_id';
  static const String _customThemesKey = 'custom_themes';
  static const String _themeModeKey = 'theme_mode';

  ThemePreset _currentTheme;
  ThemeMode _themeMode;
  final List<ThemePreset> _customThemes = [];
  bool _isLoading = true;

  ThemeProvider()
      : _currentTheme = ThemePreset.oceanBlue,
        _themeMode = ThemeMode.system {
    _loadTheme();
  }

  // Getters
  ThemePreset get currentTheme => _currentTheme;
  ThemeMode get themeMode => _themeMode;

  /// Цветовая схема для заданной яркости (светлая/тёмная)
  ColorScheme colorScheme(Brightness brightness) =>
      _currentTheme.toColorScheme(brightness);

  bool get isLoading => _isLoading;
  
  /// Все доступные темы (встроенные + пользовательские)
  List<ThemePreset> get allThemes => [
    ...ThemePreset.builtInThemes,
    ..._customThemes,
  ];

  /// Только пользовательские темы
  List<ThemePreset> get customThemes => List.unmodifiable(_customThemes);

  /// Загрузка сохранённой темы
  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();

    // Режим светлая/тёмная: по умолчанию «как в системе» (при первом запуске)
    final modeStr = prefs.getString(_themeModeKey);
    if (modeStr != null) {
      switch (modeStr) {
        case 'light':
          _themeMode = ThemeMode.light;
          break;
        case 'dark':
          _themeMode = ThemeMode.dark;
          break;
        default:
          _themeMode = ThemeMode.system;
      }
    }

    // Загружаем ID активной темы
    final activeThemeId =
        prefs.getString(_activeThemeIdKey) ?? ThemePreset.oceanBlue.id;

    // Загружаем пользовательские темы
    final customThemesJson = prefs.getStringList(_customThemesKey) ?? [];
    for (final themeJson in customThemesJson) {
      try {
        final theme = _parseThemeFromJson(themeJson);
        if (theme != null) {
          _customThemes.add(theme);
        }
      } catch (e) {
        // Игнорируем corrupted данные
      }
    }

    _currentTheme = _findThemeById(activeThemeId) ?? ThemePreset.oceanBlue;

    _isLoading = false;
    notifyListeners();
  }

  /// Установить режим темы (светлая / тёмная / как в системе)
  Future<void> setThemeMode(ThemeMode mode) async {
    if (_themeMode == mode) return;
    _themeMode = mode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _themeModeKey,
      mode == ThemeMode.light
          ? 'light'
          : mode == ThemeMode.dark
              ? 'dark'
              : 'system',
    );
    notifyListeners();
  }

  /// Установить тему по ID
  Future<void> setTheme(String themeId) async {
    final theme = _findThemeById(themeId);
    if (theme == null || theme.id == _currentTheme.id) return;
    
    _currentTheme = theme;
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_activeThemeIdKey, themeId);
    
    notifyListeners();
  }

  /// Добавить пользовательскую тему
  Future<void> addCustomTheme(ThemePreset theme) async {
    if (theme.isBuiltIn) return; // Нельзя добавить встроенную тему
    
    // Проверяем, нет ли уже темы с таким ID
    if (_findThemeById(theme.id) != null) {
      // Если тема существует, обновляем её
      final index = _customThemes.indexWhere((t) => t.id == theme.id);
      if (index != -1) {
        _customThemes[index] = theme;
      }
    } else {
      _customThemes.add(theme);
    }
    
    await _saveCustomThemes();
    notifyListeners();
  }

  /// Удалить пользовательскую тему
  Future<void> deleteCustomTheme(String themeId) async {
    _customThemes.removeWhere((t) => t.id == themeId);
    
    // Если удаляем активную тему, переключаемся на дефолтную
    if (_currentTheme.id == themeId) {
      _currentTheme = ThemePreset.oceanBlue;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_activeThemeIdKey, _currentTheme.id);
    }
    
    await _saveCustomThemes();
    notifyListeners();
  }

  /// Создать копию существующей темы для редактирования
  ThemePreset duplicateTheme(ThemePreset source, {required String newId, required String newName}) {
    return source.copyWith(
      id: newId,
      name: newName,
      isBuiltIn: false,
      description: 'Custom theme based on ${source.name}',
    );
  }

  /// Сохранить пользовательские темы
  Future<void> _saveCustomThemes() async {
    final prefs = await SharedPreferences.getInstance();
    final themesJson = _customThemes.map((t) => _themeToJsonString(t)).toList();
    await prefs.setStringList(_customThemesKey, themesJson);
  }

  /// Найти тему по ID
  ThemePreset? _findThemeById(String id) {
    // Сначала ищем в пользовательских
    final custom = _customThemes.where((t) => t.id == id).firstOrNull;
    if (custom != null) return custom;
    
    // Потом в встроенных
    final builtIn = ThemePreset.builtInThemes.where((t) => t.id == id).firstOrNull;
    return builtIn;
  }

  /// Простой парсинг JSON
  ThemePreset? _parseThemeFromJson(String json) {
    try {
      // Упрощённый парсинг без dart:convert для базовых типов
      final map = <String, dynamic>{};
      
      // Извлекаем основные поля
      final idMatch = RegExp(r'"id":\s*"([^"]+)"').firstMatch(json);
      final nameMatch = RegExp(r'"name":\s*"([^"]+)"').firstMatch(json);
      
      if (idMatch == null || nameMatch == null) return null;
      
      map['id'] = idMatch.group(1);
      map['name'] = nameMatch.group(1);
      
      final descMatch = RegExp(r'"description":\s*"([^"]*)"').firstMatch(json);
      map['description'] = descMatch?.group(1);
      map['isBuiltIn'] = false;
      
      // Извлекаем цвета
      final colors = <String, int>{};
      final colorMatches = RegExp(r'"(\w+)":\s*(\d+)').allMatches(json);
      for (final match in colorMatches) {
        colors[match.group(1)!] = int.parse(match.group(2)!);
      }
      map['colors'] = colors;
      
      return ThemePreset.fromJson(map);
    } catch (e) {
      return null;
    }
  }

  /// Простая сериализация в JSON
  String _themeToJsonString(ThemePreset theme) {
    final json = theme.toJson();
    final buffer = StringBuffer();
    buffer.write('{');
    buffer.write('"id":"${json['id']}",');
    buffer.write('"name":"${json['name']}",');
    buffer.write('"description":"${json['description'] ?? ''}",');
    buffer.write('"isBuiltIn":false,');
    buffer.write('"colors":{');
    
    final colors = json['colors'] as Map<String, dynamic>;
    final colorEntries = colors.entries.toList();
    for (var i = 0; i < colorEntries.length; i++) {
      final entry = colorEntries[i];
      buffer.write('"${entry.key}":${entry.value}');
      if (i < colorEntries.length - 1) buffer.write(',');
    }
    buffer.write('}}');
    return buffer.toString();
  }
}
