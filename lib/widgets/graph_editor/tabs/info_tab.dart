import 'package:flutter/material.dart';
import '../../../data/image_cache_service.dart';
import '../../../l10n/app_localizations.dart';
import '../../../models/graph.dart';
import '../../../app_constants.dart';

// Переэкспортируем CacheStats для удобства
export '../../../data/image_cache_service.dart' show CacheStats;

/// Tab showing graph information and actions
class InfoTab extends StatelessWidget {
  final BuildingGraph graph;
  final VoidCallback onCreateNew;
  final VoidCallback onRename;
  final VoidCallback onClone;
  final VoidCallback onExport;
  final VoidCallback onImport;
  final VoidCallback onDelete;
  final VoidCallback onDownloadImages;
  final VoidCallback onClearImageCache;
  final Function(int) onSwitchTab;
  final CacheStats? cacheStats;

  const InfoTab({
    super.key,
    required this.graph,
    required this.onCreateNew,
    required this.onRename,
    required this.onClone,
    required this.onExport,
    required this.onImport,
    required this.onDelete,
    required this.onDownloadImages,
    required this.onClearImageCache,
    required this.onSwitchTab,
    this.cacheStats,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > AppConstants.kLargeScreenBreakpoint;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(AppConstants.kScreenPadding),
          child: isWide
              // На широких экранах размещаем карточки в ряд
              ? Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 2,
                      child: _buildInfoCard(context, l10n),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      flex: 3,
                      child: Column(
                        children: [
                          _buildActionsCard(context, l10n),
                          const SizedBox(height: 16),
                          _buildCacheCard(context, l10n),
                        ],
                      ),
                    ),
                  ],
                )
              // На узких экранах карточки в колонку
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildInfoCard(context, l10n),
                    const SizedBox(height: 16),
                    _buildActionsCard(context, l10n),
                    const SizedBox(height: 16),
                    _buildCacheCard(context, l10n),
                  ],
                ),
        );
      },
    );
  }
  
  /// Карточка с информацией о графе
  Widget _buildInfoCard(BuildContext context, AppLocalizations l10n) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.kCardPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.graphInfo,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppConstants.kScreenPadding),
            _InfoRow(label: l10n.graphId, value: graph.id),
            _InfoRow(label: l10n.graphName, value: graph.name),
            _InfoRow(label: l10n.createdAt, value: _formatDate(graph.createdAt)),
            _InfoRow(label: l10n.modifiedAt, value: _formatDate(graph.modifiedAt)),
            const Divider(height: 24),
            _InfoRow(label: l10n.nodeCount, value: '${graph.nodeCount}'),
            _InfoRow(label: l10n.connectionCount, value: '${graph.connectionCount}'),
            const Divider(height: 24),
            _InfoRow(
              label: l10n.imageUrlsLabel,
              value: '${graph.imageUrlsCount} ${l10n.totalLabel} / ${graph.uniqueImageUrlsCount} ${l10n.uniqueLabel}',
            ),
            if (cacheStats != null && graph.uniqueImageUrlsCount > 0)
              _InfoRow(
                label: l10n.cachedLabel,
                value: '${cacheStats!.cached} ${l10n.ofLabel} ${cacheStats!.total}',
              ),
            _InfoRow(
              label: l10n.tour3dCountLabel,
              value: '${graph.tour3dUrlsCount} ${l10n.totalLabel} / ${graph.uniqueTour3dUrlsCount} ${l10n.uniqueLabel}',
            ),
          ],
        ),
      ),
    );
  }
  
  /// Карточка с действиями над графом
  Widget _buildActionsCard(BuildContext context, AppLocalizations l10n) {
    return Card(
      child: Column(
        children: [
          ListTile(
            leading: Icon(Icons.create, color: Theme.of(context).colorScheme.primary),
            title: Text(l10n.createNew, style: Theme.of(context).textTheme.bodyMedium),
            onTap: onCreateNew,
          ),
          const Divider(height: 1),
          ListTile(
            leading: Icon(Icons.edit, color: Theme.of(context).colorScheme.primary),
            title: Text(l10n.rename, style: Theme.of(context).textTheme.bodyMedium),
            onTap: onRename,
          ),
          const Divider(height: 1),
          ListTile(
            leading: Icon(Icons.copy, color: Theme.of(context).colorScheme.primary),
            title: Text(l10n.clone, style: Theme.of(context).textTheme.bodyMedium),
            onTap: () {
              onClone();
              onSwitchTab(0);
            },
          ),
          const Divider(height: 1),
          ListTile(
            leading: Icon(Icons.download, color: Theme.of(context).colorScheme.primary),
            title: Text(l10n.export, style: Theme.of(context).textTheme.bodyMedium),
            onTap: onExport,
          ),
          const Divider(height: 1),
          ListTile(
            leading: Icon(Icons.upload, color: Theme.of(context).colorScheme.primary),
            title: Text(l10n.import, style: Theme.of(context).textTheme.bodyMedium),
            onTap: onImport,
          ),
          const Divider(height: 1),
          ListTile(
            leading: Icon(Icons.delete, color: Theme.of(context).colorScheme.error),
            title: Text(l10n.delete, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.error)),
            onTap: onDelete,
          ),
        ],
      ),
    );
  }

  /// Карточка с управлением кэшем изображений
  Widget _buildCacheCard(BuildContext context, AppLocalizations l10n) {
    final hasCachedImages = cacheStats != null && cacheStats!.cached > 0;

    return Card(
      child: Column(
        children: [
          // Кнопка скачивания изображений
          ListTile(
            leading: Icon(
              Icons.cloud_download_outlined,
              color: Theme.of(context).colorScheme.primary,
            ),
            title: Text(l10n.downloadImages, style: Theme.of(context).textTheme.bodyMedium),
            onTap: onDownloadImages,
          ),
          const Divider(height: 1),
          // Кнопка очистки кэша
          ListTile(
            leading: Icon(
              Icons.delete_outline,
              color: hasCachedImages
                  ? Theme.of(context).colorScheme.error
                  : Theme.of(context).colorScheme.outline,
            ),
            title: Text(
              l10n.clearImageCache,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: hasCachedImages
                    ? Theme.of(context).colorScheme.error
                    : Theme.of(context).colorScheme.onSurface,
              ),
            ),
            enabled: hasCachedImages,
            onTap: onClearImageCache,
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year} '
        '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}

/// Внутренний виджет для отображения строки информации
class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppConstants.kSpacingTiny),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
