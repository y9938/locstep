import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../app_constants.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/theme_provider.dart';

class ThemeModeSelector extends StatelessWidget {
  const ThemeModeSelector({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final themeProvider = context.watch<ThemeProvider>();
    final theme = Theme.of(context);

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppConstants.kCardBorderRadius,
          vertical: 10,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.brightness_6,
                  color: theme.colorScheme.primary,
                  size: 20,
                ),
                const SizedBox(width: AppConstants.kSpacingUnit),
                Text(
                  l10n.themeMode,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            LayoutBuilder(
              builder: (context, constraints) {
                return SegmentedButton<ThemeMode>(
                  segments: [
                    ButtonSegment<ThemeMode>(
                      value: ThemeMode.system,
                      icon: const Icon(Icons.brightness_auto, size: 18),
                      label: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(l10n.themeModeSystem),
                      ),
                    ),
                    ButtonSegment<ThemeMode>(
                      value: ThemeMode.light,
                      icon: const Icon(Icons.light_mode, size: 18),
                      label: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(l10n.themeModeLight),
                      ),
                    ),
                    ButtonSegment<ThemeMode>(
                      value: ThemeMode.dark,
                      icon: const Icon(Icons.dark_mode, size: 18),
                      label: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(l10n.themeModeDark),
                      ),
                    ),
                  ],
                  selected: {themeProvider.themeMode},
                  onSelectionChanged: (Set<ThemeMode> selected) {
                    themeProvider.setThemeMode(selected.first);
                  },
                  style: ButtonStyle(
                    visualDensity: VisualDensity.compact,
                    padding: WidgetStateProperty.all(
                      const EdgeInsets.symmetric(
                        horizontal: AppConstants.kSpacingUnit,
                        vertical: AppConstants.kSpacingUnit,
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
