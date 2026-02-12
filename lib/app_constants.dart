import 'package:flutter/material.dart';

/// Константы стиля приложения
///
/// Используются для единообразия отступов, брейкпоинтов и радиусов.
class AppConstants {
  AppConstants._();

  /// Ширина экрана (dp), выше которой считается «широкий» layout (Material 3).
  static const double kLargeScreenBreakpoint = 600;

  /// Максимальная ширина диалога на больших экранах.
  static const double kDialogMaxWidth = 560;

  /// Padding экрана и основной контентной области.
  static const double kScreenPadding = 16;

  /// Padding широкого экрана по горизонтали.
  static const double kScreenPaddingWide = 24;

  /// Внутренний padding карточки (Card).
  static const double kCardPadding = 16;

  /// BorderRadius карточек и кнопок.
  static const double kCardBorderRadius = 12;

  /// Margin между карточками/блоками по вертикали.
  static const double kListMarginBottom = 8;

  /// Мелкий отступ (между элементами в списке, вокруг полей).
  static const double kSpacingUnit = 8;

  /// Минимальный отступ (секции, чипы).
  static const double kSpacingTiny = 4;

  /// ContentPadding для полей ввода (TextField, Dropdown и т.п.): 12 вертикаль, 16 горизонталь.
  static const EdgeInsets kInputContentPadding =
      EdgeInsets.symmetric(horizontal: 16, vertical: 12);
}
