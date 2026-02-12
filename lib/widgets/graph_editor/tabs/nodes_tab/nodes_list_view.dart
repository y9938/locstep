import 'package:flutter/material.dart';
import '../../../../app_constants.dart';
import '../../../../utils/open_3d_tour_helper.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../models/graph.dart';
import '../../../../models/node.dart';
import '../../../common/cached_node_image.dart';
import '../../../common/fullscreen_image_dialog.dart';

/// Список узлов графа с возможностью редактирования и удаления
class NodesListView extends StatefulWidget {
  final BuildingGraph graph;
  final Function(Node node) onEdit;
  final Function(String nodeId) onDelete;
  final TextEditingController? searchController;
  final String? searchQuery;
  final ValueChanged<String>? onSearchChanged;

  const NodesListView({
    super.key,
    required this.graph,
    required this.onEdit,
    required this.onDelete,
    this.searchController,
    this.searchQuery,
    this.onSearchChanged,
  });

  @override
  State<NodesListView> createState() => _NodesListViewState();
}

class _NodesListViewState extends State<NodesListView> {
  late final TextEditingController _searchController;
  String _localSearchQuery = '';

  @override
  void initState() {
    super.initState();
    // Используем переданный контроллер или создаем локальный
    _searchController = widget.searchController ?? TextEditingController();
    // Инициализируем локальное состояние, если не используется управляемое
    if (widget.searchQuery == null) {
      _localSearchQuery = '';
    } else {
      // Синхронизируем текст контроллера с переданным query
      _searchController.text = widget.searchQuery!;
    }
  }

  @override
  void dispose() {
    // Освобождаем только локальный контроллер
    if (widget.searchController == null) {
      _searchController.dispose();
    }
    super.dispose();
  }

  String get _currentSearchQuery {
    return widget.searchQuery ?? _localSearchQuery;
  }

  List<Node> get _filteredNodes {
    final allNodes = widget.graph.allNodes;
    final query = _currentSearchQuery;
    final list = query.isEmpty
        ? allNodes
        : allNodes.where((node) => node.matches(query)).toList();
    
    // Сортировка по алфавиту по названию узла
    final sorted = list.toList();
    sorted.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    return sorted;
  }

  void _clearSearch() {
    _searchController.clear();
    if (widget.onSearchChanged != null) {
      widget.onSearchChanged!('');
    } else {
      setState(() {
        _localSearchQuery = '';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final nodes = _filteredNodes;

    if (widget.graph.allNodes.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.kScreenPaddingWide),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.account_tree_outlined, size: 64, color: Theme.of(context).colorScheme.outline),
              const SizedBox(height: AppConstants.kScreenPadding),
              Text(
                l10n.noNodes,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: [
        // Поле поиска
        Padding(
          padding: const EdgeInsets.all(AppConstants.kSpacingUnit),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: l10n.searchNodes,
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _currentSearchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: _clearSearch,
                    )
                  : null,
              filled: true,
              fillColor: Theme.of(context).colorScheme.surfaceContainerLow,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppConstants.kCardBorderRadius),
                borderSide: BorderSide.none,
              ),
              contentPadding: AppConstants.kInputContentPadding,
            ),
            onChanged: (value) {
              if (widget.onSearchChanged != null) {
                widget.onSearchChanged!(value);
              } else {
                setState(() {
                  _localSearchQuery = value;
                });
              }
            },
          ),
        ),
        // Список узлов
        Expanded(
          child: nodes.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(AppConstants.kScreenPaddingWide),
                    child: Text(
                      '${l10n.nodeNotFound}: "$_currentSearchQuery"',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(AppConstants.kSpacingUnit),
                  itemCount: nodes.length,
                  itemBuilder: (context, index) {
                    final node = nodes[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: AppConstants.kListMarginBottom),
                      child: ListTile(
                        title: Text(node.name),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (node.aliases.isNotEmpty)
                              Text(
                                node.aliases.join(', '),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                                ),
                              ),
                            if (node.neighbors.isNotEmpty ||
                                node.aliases.isNotEmpty ||
                                node.tour3dUrls.isNotEmpty ||
                                node.imageUrls.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(top: AppConstants.kSpacingTiny),
                                child: Wrap(
                                  spacing: AppConstants.kSpacingUnit,
                                  children: [
                                    if (node.neighbors.isNotEmpty)
                                      _InfoBadge(
                                        icon: Icons.link,
                                        label: '${node.neighbors.length}',
                                      ),
                                    if (node.aliases.isNotEmpty)
                                      _InfoBadge(
                                        icon: Icons.label,
                                        label: '${node.aliases.length}',
                                      ),
                                    if (node.imageUrls.isNotEmpty)
                                      _InfoBadge(
                                        icon: Icons.photo_library,
                                        label: '${node.imageUrls.length}',
                                      ),
                                    if (node.tour3dUrls.isNotEmpty)
                                      _InfoBadge(
                                        icon: Icons.threed_rotation,
                                        label: '${node.tour3dUrls.length}',
                                        iconSize: 16,
                                      ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (node.tour3dUrls.isNotEmpty || node.imageUrls.isNotEmpty)
                              IconButton(
                                icon: const Icon(Icons.visibility, size: 20),
                                onPressed: () => _showNodePreview(context, node),
                                tooltip: l10n.nodePreview,
                              ),
                            IconButton(
                              icon: const Icon(Icons.edit, size: 20),
                              onPressed: () => widget.onEdit(node),
                              tooltip: l10n.edit,
                            ),
                            IconButton(
                              icon: Icon(Icons.delete, color: Theme.of(context).colorScheme.error, size: 20),
                              onPressed: () => _showDeleteConfirmation(context, node),
                              tooltip: l10n.delete,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  void _showNodePreview(BuildContext context, Node node) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    showModalBottomSheet(
      context: context,
      builder: (context) => SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.kCardPadding),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
            Text(
              node.name,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            if (node.imageUrls.isNotEmpty) ...[
              const SizedBox(height: AppConstants.kSpacingUnit),
              Text(
                l10n.imageUrlsLabel,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: AppConstants.kSpacingTiny),
              SizedBox(
                height: 120,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: node.imageUrls.length,
                  separatorBuilder: (context, index) => const SizedBox(width: AppConstants.kSpacingUnit),
                  itemBuilder: (context, index) {
                    final url = node.imageUrls[index];
                    return GestureDetector(
                      onTap: () => FullscreenImageDialog.show(
                          context,
                          imageUrl: url,
                          showImageUrl: true,
                          maxWidthFactor: 0.9,
                          maxHeightFactor: 0.85,
                        ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(AppConstants.kCardBorderRadius),
                        child: SizedBox(
                          width: 120,
                          height: 120,
                          child: CachedNodeImage(
                            url: url,
                            width: 120,
                            height: 120,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => Container(
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
                    );
                  },
                ),
              ),
            ],
            if (node.tour3dUrls.isNotEmpty) ...[
              if (node.imageUrls.isNotEmpty)
                const SizedBox(height: AppConstants.kSpacingUnit),
              ...node.tour3dUrls.map((url) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: AppConstants.kSpacingUnit),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SelectableText(
                        url,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                          fontFamily: 'monospace',
                        ),
                      ),
                      const SizedBox(height: AppConstants.kSpacingTiny),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () => open3DTourWithConfirmation(context, url),
                          icon: const Icon(Icons.open_in_browser, size: 20),
                          label: Text(l10n.open3dTour),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ],
          ),
        ),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, Node node) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.delete),
        content: Text('${l10n.deleteNodeConfirm} "${node.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              widget.onDelete(node.id);
            },
            child: Text(l10n.delete, style: TextStyle(color: Theme.of(context).colorScheme.error)),
          ),
        ],
      ),
    );
  }
}

/// Информационный бейдж для метаданных
class _InfoBadge extends StatelessWidget {
  final IconData icon;
  final String label;
  final double? iconSize;

  const _InfoBadge({
    required this.icon,
    required this.label,
    this.iconSize,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon,
            size: iconSize ?? 14,
            color: Theme.of(context).colorScheme.onSurfaceVariant),
        const SizedBox(width: 2),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
