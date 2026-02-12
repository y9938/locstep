import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../app_constants.dart';
import '../../l10n/app_localizations.dart';
import '../../models/theme_preset.dart';
import '../../models/theme_localization.dart';
import '../../providers/theme_provider.dart';

class PaletteSelector extends StatelessWidget {
  const PaletteSelector({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final themeProvider = context.watch<ThemeProvider>();
    final currentTheme = themeProvider.currentTheme;
    final allThemes = themeProvider.allThemes;

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
                  Icons.palette,
                  color: Theme.of(context).colorScheme.primary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  l10n.appPalette,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            _PaletteDropdown(
              themes: allThemes,
              currentTheme: currentTheme,
              onThemeSelected: (theme) {
                themeProvider.setTheme(theme.id);
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _PaletteDropdown extends StatefulWidget {
  final List<ThemePreset> themes;
  final ThemePreset currentTheme;
  final Function(ThemePreset) onThemeSelected;

  const _PaletteDropdown({
    required this.themes,
    required this.currentTheme,
    required this.onThemeSelected,
  });

  @override
  State<_PaletteDropdown> createState() => _PaletteDropdownState();
}

class _PaletteDropdownState extends State<_PaletteDropdown> {
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;
  bool _isOpen = false;

  void _toggleDropdown() {
    if (_isOpen) {
      _closeDropdown();
    } else {
      _openDropdown();
    }
  }

  void _openDropdown() {
    _overlayEntry = _createOverlayEntry();
    Overlay.of(context).insert(_overlayEntry!);
    setState(() => _isOpen = true);
  }

  void _closeDropdown() {
    _overlayEntry?.remove();
    _overlayEntry = null;
    setState(() => _isOpen = false);
  }

  OverlayEntry _createOverlayEntry() {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final renderBox = context.findRenderObject() as RenderBox;
    final size = renderBox.size;

    return OverlayEntry(
      builder: (context) => GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: _closeDropdown,
        child: Stack(
          children: [
            Positioned.fill(
              child: Container(
                color: theme.colorScheme.scrim.withAlpha(25),
              ),
            ),
            Positioned(
              width: size.width,
              child: CompositedTransformFollower(
                link: _layerLink,
                showWhenUnlinked: false,
                offset: Offset(0, size.height + 4),
                child: SingleChildScrollView(
                  child: Material(
                    elevation: 4,
                    borderRadius: BorderRadius.circular(AppConstants.kCardBorderRadius),
                    child: Container(
                      constraints: const BoxConstraints(maxHeight: 280),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surface,
                        borderRadius: BorderRadius.circular(AppConstants.kCardBorderRadius),
                        border: Border.all(color: theme.colorScheme.outlineVariant),
                      ),
                      child: ListView.builder(
                        shrinkWrap: true,
                        padding: EdgeInsets.zero,
                        itemCount: widget.themes.length,
                        itemBuilder: (context, index) {
                          final themePreset = widget.themes[index];
                          final isSelected = themePreset.id == widget.currentTheme.id;

                          return ListTile(
                            dense: true,
                            leading: _PalettePreview(colors: themePreset),
                            title: Text(getThemeName(themePreset.id, l10n)),
                            subtitle: Text(
                              getThemeDescription(themePreset.id, l10n) ?? '',
                              style: theme.textTheme.bodySmall,
                            ),
                            trailing: isSelected
                                ? Icon(
                                    Icons.check,
                                    color: theme.colorScheme.primary,
                                    size: 20,
                                  )
                                : null,
                            selected: isSelected,
                            selectedTileColor: theme.colorScheme.primaryContainer.withAlpha(77),
                            onTap: () {
                              widget.onThemeSelected(themePreset);
                              _closeDropdown();
                            },
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return CompositedTransformTarget(
      link: _layerLink,
      child: GestureDetector(
        onTap: _toggleDropdown,
        child: Container(
          padding: const EdgeInsets.symmetric(
          horizontal: AppConstants.kCardBorderRadius,
          vertical: 10,
        ),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(AppConstants.kCardBorderRadius),
            border: Border.all(
              color: _isOpen
                  ? theme.colorScheme.primary
                  : theme.colorScheme.outlineVariant,
            ),
          ),
          child: Row(
            children: [
              _PalettePreview(colors: widget.currentTheme),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      getThemeName(widget.currentTheme.id, l10n),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      getThemeDescription(widget.currentTheme.id, l10n) ?? '',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              AnimatedRotation(
                turns: _isOpen ? 0.5 : 0,
                duration: const Duration(milliseconds: 200),
                child: Icon(
                  Icons.keyboard_arrow_down,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _overlayEntry?.remove();
    _overlayEntry = null;
    super.dispose();
  }
}

class _PalettePreview extends StatelessWidget {
  final ThemePreset colors;

  const _PalettePreview({required this.colors});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colors.primary,
            colors.secondary,
            colors.tertiary,
          ],
        ),
        borderRadius: BorderRadius.circular(AppConstants.kScreenPadding),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline,
          width: 1,
        ),
      ),
    );
  }
}
