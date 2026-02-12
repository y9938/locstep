import 'package:flutter/material.dart';

import '../../app_constants.dart';
import 'cached_node_image.dart';

/// Fullscreen image dialog (zoomable). [showImageUrl]: show URL as selectable text below (e.g. node editor).
class FullscreenImageDialog {
  FullscreenImageDialog._();

  static void show(
    BuildContext context, {
    required String imageUrl,
    bool showImageUrl = false,
    double maxWidthFactor = 1.0,
    double maxHeightFactor = 0.9,
  }) {
    final theme = Theme.of(context);

    showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black54,
      builder: (dialogContext) {
        final size = MediaQuery.sizeOf(dialogContext);
        final maxW = size.width * maxWidthFactor;
        final maxH = size.height * maxHeightFactor;

        return Stack(
          alignment: Alignment.center,
          children: [
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => Navigator.of(dialogContext).pop(),
              child: Container(color: Colors.black54),
            ),
            GestureDetector(
              onTap: () {},
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxHeight: size.height * 0.9),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        InteractiveViewer(
                          minScale: 0.5,
                          maxScale: 4.0,
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              maxWidth: maxW,
                              maxHeight: maxH,
                            ),
                            child: CachedNodeImage(
                              url: imageUrl,
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) =>
                                  Container(
                                color: theme.colorScheme.surfaceContainerLow,
                                padding: const EdgeInsets.all(
                                  AppConstants.kCardPadding,
                                ),
                                child: Icon(
                                  Icons.broken_image_outlined,
                                  size: 48,
                                  color: theme.colorScheme.outline,
                                ),
                              ),
                            ),
                          ),
                        ),
                        if (showImageUrl) ...[
                          const SizedBox(height: AppConstants.kSpacingUnit),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppConstants.kCardPadding,
                            ),
                            child: SelectableText(
                              imageUrl,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurface,
                                fontFamily: 'monospace',
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
