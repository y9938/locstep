import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../app_constants.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/text_scale_provider.dart';

class TextScaleCard extends StatelessWidget {
  const TextScaleCard({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppConstants.kCardBorderRadius,
          vertical: 10,
        ),
        child: Consumer<TextScaleProvider>(
          builder: (context, textScaleProvider, child) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.text_fields,
                      color: theme.colorScheme.primary,
                      size: 20,
                    ),
                    const SizedBox(width: AppConstants.kSpacingUnit),
                    Text(
                      l10n.textScale,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    IconButton.filledTonal(
                      onPressed: textScaleProvider.canDecrease
                          ? () => textScaleProvider.decreaseScale()
                          : null,
                      icon: const Icon(Icons.remove, size: 18),
                      tooltip: l10n.decreaseTextScale,
                      style: IconButton.styleFrom(
                        minimumSize: const Size(36, 36),
                        padding: EdgeInsets.zero,
                      ),
                    ),
                    const SizedBox(width: AppConstants.kSpacingUnit),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: AppConstants.kSpacingUnit),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(AppConstants.kCardBorderRadius),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Aa',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(width: AppConstants.kSpacingUnit),
                            Text(
                              '${(textScaleProvider.textScale * 100).round()}%',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: AppConstants.kSpacingUnit),
                    IconButton.filledTonal(
                      onPressed: textScaleProvider.canIncrease
                          ? () => textScaleProvider.increaseScale()
                          : null,
                      icon: const Icon(Icons.add, size: 18),
                      tooltip: l10n.increaseTextScale,
                      style: IconButton.styleFrom(
                        minimumSize: const Size(36, 36),
                        padding: EdgeInsets.zero,
                      ),
                    ),
                  ],
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton.icon(
                    onPressed: textScaleProvider.isDefault
                        ? null
                        : () => textScaleProvider.resetScale(),
                    icon: const Icon(Icons.refresh, size: 16),
                    label: Text(l10n.reset),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: AppConstants.kSpacingUnit),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
