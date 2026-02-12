import '../l10n/app_localizations.dart';

/// Получить локализованное название темы по ID
String getThemeName(String themeId, AppLocalizations l10n) {
  switch (themeId) {
    case 'ocean_blue':
      return l10n.paletteOceanBlue;
    case 'forest_green':
      return l10n.paletteForestGreen;
    case 'sunset_orange':
      return l10n.paletteSunsetOrange;
    default:
      return themeId; // Fallback на ID если перевод не найден
  }
}

/// Получить локализованное описание темы по ID
String? getThemeDescription(String themeId, AppLocalizations l10n) {
  switch (themeId) {
    case 'ocean_blue':
      return l10n.paletteOceanBlueDesc;
    case 'forest_green':
      return l10n.paletteForestGreenDesc;
    case 'sunset_orange':
      return l10n.paletteSunsetOrangeDesc;
    default:
      return null;
  }
}
