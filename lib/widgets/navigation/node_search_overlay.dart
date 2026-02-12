import 'package:flutter/material.dart';

import '../../app_constants.dart';
import '../../l10n/app_localizations.dart';
import '../../models/node.dart';
import '../common/cached_node_image.dart';

/// Search bar at bottom with expandable results list. State owned by parent.
class NodeSearchOverlay extends StatelessWidget {
  const NodeSearchOverlay({
    super.key,
    required this.searchController,
    required this.searchFocusNode,
    required this.isSearchExpanded,
    required this.searchResults,
    required this.onCollapse,
    required this.onExpand,
    required this.onNodeTap,
  });

  final TextEditingController searchController;
  final FocusNode searchFocusNode;
  final bool isSearchExpanded;
  final List<Node> searchResults;
  final VoidCallback onCollapse;
  final VoidCallback onExpand;
  final void Function(Node node) onNodeTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (isSearchExpanded && searchResults.isNotEmpty)
              GestureDetector(
                onTap: () {},
                behavior: HitTestBehavior.opaque,
                onVerticalDragEnd: (details) {
                  if (details.velocity.pixelsPerSecond.dy > 300) {
                    onCollapse();
                  }
                },
                child: Container(
                  constraints: const BoxConstraints(maxHeight: 300),
                  margin: EdgeInsets.symmetric(
                    horizontal: AppConstants.kScreenPadding,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(AppConstants.kCardBorderRadius),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 8,
                        offset: const Offset(0, -2),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      GestureDetector(
                        onVerticalDragEnd: (details) {
                          if (details.velocity.pixelsPerSecond.dy > 300) {
                            onCollapse();
                          }
                        },
                        child: Container(
                          width: 40,
                          height: 4,
                          margin: const EdgeInsets.symmetric(
                            vertical: AppConstants.kSpacingUnit,
                          ),
                          decoration: BoxDecoration(
                            color: Theme.of(context)
                                .colorScheme
                                .outline
                                .withValues(alpha: 0.3),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      Flexible(
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: searchResults.length,
                          itemBuilder: (context, index) {
                            final node = searchResults[index];
                            return ListTile(
                              leading: node.imageUrls.isNotEmpty
                                  ? ClipRRect(
                                      borderRadius: BorderRadius.circular(4),
                                      child: SizedBox(
                                        width: 40,
                                        height: 40,
                                        child: CachedNodeImage(
                                          url: node.imageUrls.first,
                                          width: 40,
                                          height: 40,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    )
                                  : Icon(
                                      Icons.location_on,
                                      color:
                                          Theme.of(context).colorScheme.primary,
                                    ),
                              title: Text(node.name),
                              onTap: () {
                                FocusScope.of(context).unfocus();
                                searchFocusNode.unfocus();
                                WidgetsBinding.instance.addPostFrameCallback(
                                  (_) => onNodeTap(node),
                                );
                              },
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            Container(
              margin: const EdgeInsets.all(AppConstants.kScreenPadding),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius:
                    BorderRadius.circular(AppConstants.kCardBorderRadius),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: searchController,
                      focusNode: searchFocusNode,
                      decoration: InputDecoration(
                        hintText: l10n.searchNodes,
                        border: InputBorder.none,
                        contentPadding: AppConstants.kInputContentPadding,
                        prefixIcon: Icon(
                          Icons.search,
                          color:
                              Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                      onTap: onExpand,
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      isSearchExpanded
                          ? Icons.expand_more
                          : Icons.expand_less,
                    ),
                    onPressed: () {
                      if (isSearchExpanded) {
                        onCollapse();
                      } else {
                        onExpand();
                      }
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
