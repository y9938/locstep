import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../app_constants.dart';
import '../l10n/app_localizations.dart';
import '../providers/confirm_3d_tour_provider.dart';

Future<void> open3DTourWithConfirmation(BuildContext context, String url) async {
  final l10n = AppLocalizations.of(context)!;
  final confirmProvider = context.read<Confirm3dTourProvider>();

  if (confirmProvider.askBeforeOpening) {
    final open = await showDialog<bool>(
      context: context,
      builder: (context) {
        final theme = Theme.of(context);
        return AlertDialog(
          title: Text(l10n.confirm3dTourDialogTitle),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.confirm3dTourDialogMessage,
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: AppConstants.kSpacingUnit),
              SelectableText(
                url,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.primary,
                  fontFamily: 'monospace',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(l10n.cancel),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(l10n.open3dTour),
            ),
          ],
        );
      },
    );
    if (open != true || !context.mounted) return;
  }

  await _launch3dTourUrl(context, url, l10n);
}

Future<void> _launch3dTourUrl(
  BuildContext context,
  String url,
  AppLocalizations l10n,
) async {
  try {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${l10n.open3dTour}: ${l10n.nodeNotFound}')),
        );
      }
    }
  } catch (_) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${l10n.open3dTour}: ${l10n.nodeNotFound}')),
      );
    }
  }
}
