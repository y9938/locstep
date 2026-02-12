import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../app_constants.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/confirm_3d_tour_provider.dart';

class Confirm3dTourCard extends StatelessWidget {
  const Confirm3dTourCard({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final confirmProvider = context.watch<Confirm3dTourProvider>();

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppConstants.kCardBorderRadius,
          vertical: 10,
        ),
        child: Row(
          children: [
            Icon(
              Icons.open_in_browser,
              color: theme.colorScheme.primary,
              size: 20,
            ),
            const SizedBox(width: AppConstants.kSpacingUnit),
            Expanded(
              child: Text(
                l10n.confirmBefore3dTour,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Switch(
              value: confirmProvider.askBeforeOpening,
              onChanged: (value) =>
                  confirmProvider.setAskBeforeOpening(value),
            ),
          ],
        ),
      ),
    );
  }
}
