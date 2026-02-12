import 'package:flutter/material.dart';

import '../../app_constants.dart';
import '../../engine/instruction_builder.dart';
import '../../l10n/app_localizations.dart';
import '../common/cached_node_image.dart';
import '../common/fullscreen_image_dialog.dart';

/// Route instructions: list of cards on narrow screens, grid when isLargeScreen and instructions.length > 2.
class RouteInstructionsView extends StatelessWidget {
  const RouteInstructionsView({
    super.key,
    required this.instructions,
    required this.isLargeScreen,
    required this.onOpen3DTour,
  });

  final List<Instruction> instructions;
  final bool isLargeScreen;
  final void Function(String url) onOpen3DTour;

  @override
  Widget build(BuildContext context) {
    if (isLargeScreen && instructions.length > 2) {
      return _buildGrid(context);
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: instructions
          .asMap()
          .entries
          .map((e) => _buildCard(context, e.key, e.value))
          .toList(),
    );
  }

  Widget _buildCard(BuildContext context, int index, Instruction inst) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final node = inst.targetNode;
    final hasImages = node?.imageUrls.isNotEmpty ?? false;
    final has3DTours = node?.tour3dUrls.isNotEmpty ?? false;

    return Container(
      margin: const EdgeInsets.only(bottom: AppConstants.kCardBorderRadius),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: theme.colorScheme.outline.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.only(bottom: AppConstants.kCardBorderRadius),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              inst.text,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
            if (hasImages) ...[
              const SizedBox(height: AppConstants.kSpacingUnit),
              SizedBox(
                height: 104,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: node!.imageUrls.map((url) {
                    return Padding(
                      padding: const EdgeInsets.only(
                        right: AppConstants.kSpacingUnit,
                      ),
                      child: GestureDetector(
                        onTap: () => FullscreenImageDialog.show(
                          context,
                          imageUrl: url,
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: SizedBox(
                            width: 152,
                            height: 104,
                            child: CachedNodeImage(
                              url: url,
                              width: 152,
                              height: 104,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  Container(
                                color: theme.colorScheme.surfaceContainerLow,
                                child: Icon(
                                  Icons.broken_image_outlined,
                                  size: 32,
                                  color: theme.colorScheme.outline,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
            if (has3DTours) ...[
              const SizedBox(height: AppConstants.kSpacingUnit),
              SizedBox(
                height: 40,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: node!.tour3dUrls.map((url) {
                    return Padding(
                      padding: const EdgeInsets.only(
                        right: AppConstants.kSpacingUnit,
                      ),
                      child: Material(
                        color: theme.colorScheme.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(8),
                        child: InkWell(
                          onTap: () => onOpen3DTour(url),
                          borderRadius: BorderRadius.circular(8),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.threed_rotation,
                                  size: 20,
                                  color: theme.colorScheme.primary,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  l10n.open3dTour,
                                  style: theme.textTheme.labelMedium?.copyWith(
                                    color: theme.colorScheme.primary,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildGrid(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth > 900 ? 3 : 2;

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            childAspectRatio: 2.2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: instructions.length,
          itemBuilder: (context, index) {
            final theme = Theme.of(context);
            final inst = instructions[index];
            final node = inst.targetNode;
            final hasImages = node?.imageUrls.isNotEmpty ?? false;
            final has3DTours = node?.tour3dUrls.isNotEmpty ?? false;

            return Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: theme.colorScheme.outline.withValues(alpha: 0.2),
                  width: 1,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Padding(
                padding: const EdgeInsets.all(AppConstants.kCardBorderRadius),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      inst.text,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (hasImages) ...[
                      const SizedBox(height: AppConstants.kSpacingUnit),
                      SizedBox(
                        height: 72,
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          children: node!.imageUrls.map((url) {
                            return Padding(
                              padding: const EdgeInsets.only(
                                right: AppConstants.kSpacingTiny,
                              ),
                              child: GestureDetector(
                                onTap: () => FullscreenImageDialog.show(
                                  context,
                                  imageUrl: url,
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(4),
                                  child: SizedBox(
                                    width: 80,
                                    height: 72,
                                    child: CachedNodeImage(
                                      url: url,
                                      width: 80,
                                      height: 72,
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) =>
                                              Container(
                                        color: theme
                                            .colorScheme.surfaceContainerLow,
                                        child: Icon(
                                          Icons.broken_image_outlined,
                                          size: 24,
                                          color: theme.colorScheme.outline,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                    if (has3DTours) ...[
                      SizedBox(
                        height: hasImages
                            ? AppConstants.kSpacingTiny
                            : AppConstants.kSpacingUnit,
                      ),
                      SizedBox(
                        height: 36,
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          children: node!.tour3dUrls.map((url) {
                            return Padding(
                              padding: const EdgeInsets.only(
                                right: AppConstants.kSpacingTiny,
                              ),
                              child: Material(
                                color: theme.colorScheme.surfaceContainerLow,
                                borderRadius: BorderRadius.circular(6),
                                child: InkWell(
                                  onTap: () => onOpen3DTour(url),
                                  borderRadius: BorderRadius.circular(6),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 6,
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.threed_rotation,
                                          size: 18,
                                          color: theme.colorScheme.primary,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          '3D',
                                          style: theme
                                              .textTheme.labelSmall
                                              ?.copyWith(
                                                color: theme
                                                    .colorScheme.primary,
                                                fontWeight: FontWeight.w500,
                                              ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
