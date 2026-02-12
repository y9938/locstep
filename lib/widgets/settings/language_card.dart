import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../app_constants.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/locale_provider.dart';

class LanguageCard extends StatefulWidget {
  const LanguageCard({super.key});

  @override
  State<LanguageCard> createState() => _LanguageCardState();
}

class _LanguageCardState extends State<LanguageCard> {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Consumer<LocaleProvider>(
      builder: (context, localeProvider, child) {
        final currentLang = localeProvider.currentLanguage;

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
                      Icons.language,
                      color: theme.colorScheme.primary,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      l10n.appLanguage,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                _LanguageDropdown(
                  selectedLanguage: currentLang,
                  onLanguageSelected: (language) {
                    localeProvider.setLocale(language.locale);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _LanguageDropdown extends StatefulWidget {
  final LanguageInfo selectedLanguage;
  final void Function(LanguageInfo) onLanguageSelected;

  const _LanguageDropdown({
    required this.selectedLanguage,
    required this.onLanguageSelected,
  });

  @override
  State<_LanguageDropdown> createState() => _LanguageDropdownState();
}

class _LanguageDropdownState extends State<_LanguageDropdown> {
  final TextEditingController _searchController = TextEditingController();
  bool _isExpanded = false;
  List<LanguageInfo> _filteredLanguages = [];

  @override
  void initState() {
    super.initState();
    _filteredLanguages = LocaleProvider.supportedLanguages;
    _searchController.addListener(_filterLanguages);
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterLanguages);
    _searchController.dispose();
    super.dispose();
  }

  void _filterLanguages() {
    final query = _searchController.text.trim().toLowerCase();
    if (query.isEmpty) {
      setState(() {
        _filteredLanguages = LocaleProvider.supportedLanguages;
      });
    } else {
      setState(() {
        _filteredLanguages = LocaleProvider.supportedLanguages
            .where((lang) => lang.matchesSearch(query))
            .toList();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: () {
            setState(() {
              _isExpanded = !_isExpanded;
              if (_isExpanded) {
                _filteredLanguages = LocaleProvider.supportedLanguages;
              }
            });
          },
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppConstants.kCardBorderRadius,
              vertical: 10,
            ),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(AppConstants.kCardBorderRadius),
              border: Border.all(
                color: _isExpanded
                    ? theme.colorScheme.primary
                    : theme.colorScheme.outlineVariant,
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        widget.selectedLanguage.name,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        widget.selectedLanguage.code.toUpperCase(),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                AnimatedRotation(
                  turns: _isExpanded ? 0.5 : 0,
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
        if (_isExpanded) ...[
          const SizedBox(height: 8),
          TextField(
            controller: _searchController,
            textInputAction: TextInputAction.none,
            decoration: InputDecoration(
              hintText: l10n.searchLanguage,
              prefixIcon: const Icon(Icons.search, size: 20),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, size: 18),
                      onPressed: () {
                        _searchController.clear();
                      },
                    )
                  : null,
              isDense: true,
              contentPadding: AppConstants.kInputContentPadding,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppConstants.kCardBorderRadius),
              ),
            ),
          ),
          const SizedBox(height: AppConstants.kSpacingUnit),
          ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 200),
            child: _filteredLanguages.isEmpty
                ? Padding(
                    padding: const EdgeInsets.all(AppConstants.kCardPadding),
                    child: Text(
                      l10n.noLanguagesFound,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    physics: const ClampingScrollPhysics(),
                    padding: EdgeInsets.zero,
                    itemCount: _filteredLanguages.length,
                    itemBuilder: (context, index) {
                      final lang = _filteredLanguages[index];
                      final isSelected =
                          lang.code == widget.selectedLanguage.code;

                      return ListTile(
                        dense: true,
                        visualDensity: VisualDensity.compact,
                        title: Text(lang.name),
                        subtitle: Text(lang.code.toUpperCase()),
                        trailing: isSelected
                            ? Icon(
                                Icons.check,
                                color: theme.colorScheme.primary,
                                size: 20,
                              )
                            : null,
                        selected: isSelected,
                        selectedTileColor: theme.colorScheme.primaryContainer
                            .withAlpha(77),
                        onTap: () {
                          widget.onLanguageSelected(lang);
                          setState(() {
                            _isExpanded = false;
                          });
                          _searchController.clear();
                        },
                      );
                    },
                  ),
          ),
        ],
      ],
    );
  }
}
