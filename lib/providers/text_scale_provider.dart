import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Провайдер для управления масштабом текста в приложении
class TextScaleProvider extends ChangeNotifier {
  static const String _textScaleKey = 'app_text_scale';
  
  // Минимальный и максимальный масштаб
  static const double _minScale = 0.8;
  static const double _maxScale = 1.4;
  // Шаг изменения масштаба
  static const double _step = 0.1;
  
  double _textScale = 1.0;
  
  double get textScale => _textScale;
  
  TextScaleProvider() {
    _loadTextScale();
  }
  
  /// Загружает сохранённый масштаб из SharedPreferences
  Future<void> _loadTextScale() async {
    final prefs = await SharedPreferences.getInstance();
    final savedScale = prefs.getDouble(_textScaleKey);
    if (savedScale != null && savedScale >= _minScale && savedScale <= _maxScale) {
      _textScale = savedScale;
      notifyListeners();
    }
  }
  
  /// Устанавливает конкретный масштаб
  Future<void> setTextScale(double scale) async {
    // Ограничиваем масштаб допустимыми значениями
    final clampedScale = scale.clamp(_minScale, _maxScale);
    if (_textScale == clampedScale) return;
    
    _textScale = clampedScale;
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_textScaleKey, clampedScale);
    
    notifyListeners();
  }
  
  /// Увеличивает масштаб текста
  Future<void> increaseScale() async {
    await setTextScale(_textScale + _step);
  }
  
  /// Уменьшает масштаб текста
  Future<void> decreaseScale() async {
    await setTextScale(_textScale - _step);
  }
  
  /// Сбрасывает масштаб к значению по умолчанию
  Future<void> resetScale() async {
    await setTextScale(1.0);
  }
  
  /// Проверяет, можно ли увеличить масштаб
  bool get canIncrease => _textScale < _maxScale;
  
  /// Проверяет, можно ли уменьшить масштаб
  bool get canDecrease => _textScale > _minScale;
  
  /// Проверяет, находится ли масштаб в значении по умолчанию
  bool get isDefault => _textScale == 1.0;
}
