import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Информация о поддерживаемом языке
@immutable
class LanguageInfo {
  final String code;
  final String name;
  
  const LanguageInfo({
    required this.code,
    required this.name,
  });
  
  Locale get locale => Locale(code);
  
  /// Проверяет, совпадает ли язык с заданной локалью
  bool matches(Locale locale) => code == locale.languageCode;
  
  /// Поиск по коду или имени (case-insensitive)
  bool matchesSearch(String query) {
    final lowerQuery = query.toLowerCase();
    return code.toLowerCase().contains(lowerQuery) || 
           name.toLowerCase().contains(lowerQuery);
  }
}

/// Провайдер для управления языком приложения
class LocaleProvider extends ChangeNotifier {
  static const String _localeKey = 'app_locale';
  static const String _isFirstRunKey = 'is_first_run';
  
  /// Список всех поддерживаемых языков
  /// Добавляй новые языки здесь!
  static const List<LanguageInfo> supportedLanguages = [
    LanguageInfo(code: 'ru', name: 'Русский'),
    LanguageInfo(code: 'en', name: 'English'),
  ];
  
  /// Язык по умолчанию
  static const Locale _defaultLocale = Locale('en');
  
  Locale _locale = _defaultLocale;
  bool _isLoading = true;
  
  Locale get locale => _locale;
  bool get isLoading => _isLoading;
  
  /// Текущий код языка (ru/en)
  String get languageCode => _locale.languageCode;
  
  /// Информация о текущем языке
  LanguageInfo get currentLanguage {
    return supportedLanguages.firstWhere(
      (lang) => lang.code == _locale.languageCode,
      orElse: () => supportedLanguages.first,
    );
  }
  
  LocaleProvider() {
    _initLocale();
  }
  
  /// Инициализация локали
  Future<void> _initLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final savedLocale = prefs.getString(_localeKey);
    final isFirstRun = prefs.getBool(_isFirstRunKey) ?? true;
    
    if (savedLocale != null) {
      // Используем сохранённый язык
      _setLocaleIfSupported(savedLocale);
    } else if (isFirstRun) {
      // Первый запуск - определяем язык устройства
      await _detectDeviceLocale();
      await prefs.setBool(_isFirstRunKey, false);
    }
    
    _isLoading = false;
    notifyListeners();
  }
  
  /// Определяет язык устройства и устанавливает его, если поддерживается
  Future<void> _detectDeviceLocale() async {
    // Получаем локаль устройства из WidgetsBinding
    final platformLocale = WidgetsBinding.instance.platformDispatcher.locale;
    final deviceLangCode = platformLocale.languageCode.toLowerCase();
    
    // Ищем поддерживаемый язык
    final supportedLang = supportedLanguages.firstWhere(
      (lang) => lang.code.toLowerCase() == deviceLangCode,
      orElse: () => supportedLanguages.firstWhere(
        (lang) => lang.code == _defaultLocale.languageCode,
        orElse: () => supportedLanguages.first,
      ),
    );
    
    _locale = supportedLang.locale;
    
    // Сохраняем выбор
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_localeKey, _locale.languageCode);
  }
  
  /// Устанавливает локаль если она поддерживается
  void _setLocaleIfSupported(String langCode) {
    final isSupported = supportedLanguages.any((lang) => lang.code == langCode);
    if (isSupported) {
      _locale = Locale(langCode);
    }
  }
  
  /// Устанавливает конкретную локаль
  Future<void> setLocale(Locale locale) async {
    if (_locale == locale) return;
    
    _locale = locale;
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_localeKey, locale.languageCode);
    
    notifyListeners();
  }
  
  /// Переключает между ru и en
  Future<void> toggleLocale() async {
    final newLocale = _locale.languageCode == 'ru' 
        ? const Locale('en') 
        : const Locale('ru');
    await setLocale(newLocale);
  }
}
