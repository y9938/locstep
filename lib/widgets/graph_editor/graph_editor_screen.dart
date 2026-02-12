import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../data/graph_storage.dart';
import '../../data/image_cache_service.dart';
import '../../l10n/app_localizations.dart';
import '../../models/graph.dart';
import '../../models/node.dart';
import '../../app_constants.dart';
import '../common/custom_app_bar.dart';
import '../common/unfocus_on_tap.dart';
import 'dialogs/graph_dialogs.dart';
import 'tabs/info_tab.dart';
import 'tabs/nodes_tab/nodes_tab.dart';

/// Главный экран редактора графов
/// 
/// Ответственность:
/// - Управление состоянием коллекции графов
/// - Переключение между графами
/// - Импорт/экспорт графов
/// - Отображение табов (Узлы, Инфо)
///
/// Дочерние компоненты:
/// - [NodesTab] - управление узлами
/// - [InfoTab] - информация и действия с графом
/// - [GraphDialogs] - диалоги создания/переименования/удаления
class GraphEditorScreen extends StatefulWidget {
  const GraphEditorScreen({super.key});

  @override
  State<GraphEditorScreen> createState() => _GraphEditorScreenState();
}

class _GraphEditorScreenState extends State<GraphEditorScreen>
    with SingleTickerProviderStateMixin {
  late GraphCollection _collection;
  late TabController _tabController;
  bool _isLoading = true;
  String _statusMessage = '';
  CacheStats _cacheStats = const CacheStats(cached: 0, total: 0);

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadCollection(context);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadCollection(BuildContext context) async {
    _collection = await GraphStorage.loadCollection();

    if (_collection.isEmpty) {
      // ignore: use_build_context_synchronously
      final defaultGraph = GraphStorage.getDefaultGraph(context);
      _collection.addGraph(defaultGraph);
      await GraphStorage.saveCollection(_collection);
    }

    await _updateCacheStats();

    setState(() {
      _isLoading = false;
    });
  }

  /// Обновляет статистику кэша изображений
  Future<void> _updateCacheStats() async {
    final graph = _currentGraph;
    if (graph == null) return;

    final cacheService = context.read<ImageCacheService>();
    final stats = await cacheService.getGraphCacheStats(graph);

    setState(() {
      _cacheStats = CacheStats(cached: stats.cached, total: stats.total);
    });
  }

  BuildingGraph? get _currentGraph => _collection.activeGraph;

  void _showStatus(String message) {
    setState(() {
      _statusMessage = message;
    });
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _statusMessage = '';
        });
      }
    });
  }

  // === Действия с графами ===

  Future<void> _createNewGraph() async {
    final l10n = AppLocalizations.of(context)!;
    final name = await GraphDialogs.showCreateDialog(context);
    if (name == null || name.isEmpty) return;

    final graph = BuildingGraph(name: name);
    setState(() {
      _collection.addGraph(graph);
    });
    await GraphStorage.saveCollection(_collection);
    _showStatus('${l10n.graphCreated}: $name');
  }

  Future<void> _renameCurrentGraph() async {
    final l10n = AppLocalizations.of(context)!;
    final graph = _currentGraph;
    if (graph == null) return;

    final newName = await GraphDialogs.showRenameDialog(context, graph.name);
    if (newName == null || newName.isEmpty) return;

    setState(() {
      graph.name = newName;
    });
    await GraphStorage.saveCollection(_collection);
    _showStatus(l10n.graphRenamed);
  }

  void _cloneCurrentGraph() {
    final l10n = AppLocalizations.of(context)!;
    final graph = _currentGraph;
    if (graph == null) return;

    final cloned = graph.clone(newName: '${graph.name} ${l10n.graphCloneSuffix}');
    setState(() {
      _collection.addGraph(cloned);
    });
    GraphStorage.saveCollection(_collection);
    _showStatus(l10n.graphCloned);
  }

  Future<void> _deleteCurrentGraph() async {
    final l10n = AppLocalizations.of(context)!;
    final graph = _currentGraph;
    if (graph == null) return;

    // Получаем сервис до await, чтобы избежать проблем с context
    final cacheService = context.read<ImageCacheService>();

    final confirmed = await GraphDialogs.showDeleteConfirmation(
      context,
      graph.name,
    );
    if (!confirmed) return;

    // Очищаем кэш изображений перед удалением графа
    await cacheService.clearGraphCache(graph);

    setState(() {
      _collection.removeGraph(graph.id);
      // Автосоздание графа, если удалили последний
      if (_collection.isEmpty) {
        // ignore: use_build_context_synchronously
        final defaultGraph = GraphStorage.getDefaultGraph(context);
        _collection.addGraph(defaultGraph);
      }
    });
    await GraphStorage.saveCollection(_collection);
    await _updateCacheStats();
    _showStatus(l10n.graphDeleted);
  }

  void _switchGraph(String graphId) {
    setState(() {
      _collection.setActiveGraph(graphId);
    });
    GraphStorage.saveCollection(_collection);
    _updateCacheStats();
  }

  // === Управление кэшем изображений ===

  Future<void> _downloadAllImages() async {
    final l10n = AppLocalizations.of(context)!;
    final graph = _currentGraph;
    if (graph == null) return;

    final cacheService = context.read<ImageCacheService>();
    final urls = cacheService.getGraphImageUrls(graph);

    if (urls.isEmpty) {
      _showStatus(l10n.noImagesToDownload);
      return;
    }

    // Показываем диалог прогресса
    if (mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => _DownloadProgressDialog(
          cacheService: cacheService,
          graph: graph,
        ),
      );
    }

    final result = await cacheService.downloadAllImages(graph);

    if (mounted) {
      Navigator.of(context).pop(); // Закрываем диалог прогресса
    }

    await _updateCacheStats();

    if (result.total == 0) {
      _showStatus(l10n.noImagesToDownload);
    } else if (result.failed == 0) {
      _showStatus(l10n.downloadImagesComplete(result.downloaded, result.total));
    } else {
      _showStatus('${l10n.downloadImagesComplete(result.downloaded, result.total)} (${result.failed} failed)');
    }
  }

  Future<void> _clearImageCache() async {
    final l10n = AppLocalizations.of(context)!;
    final graph = _currentGraph;
    if (graph == null) return;

    final cacheService = context.read<ImageCacheService>();
    final deleted = await cacheService.clearGraphCache(graph);

    await _updateCacheStats();

    if (deleted == 0) {
      _showStatus(l10n.noCachedImages);
    } else {
      _showStatus(l10n.imagesCacheCleared);
    }
  }

  // === Импорт/Экспорт ===

  /// Проверяет, является ли имя английским (содержит только ASCII символы)
  bool _isEnglishName(String name) {
    if (name.isEmpty) return false;
    // Проверяем, что все символы являются ASCII и допустимыми для имени файла
    final regex = RegExp(r'^[a-zA-Z0-9\s\-_]+$');
    return regex.hasMatch(name);
  }

  /// Очищает имя от недопустимых символов для имени файла
  String _sanitizeFileName(String name) {
    // Заменяем пробелы на подчеркивания и удаляем недопустимые символы
    return name
        .replaceAll(RegExp(r'[^\w\s\-]'), '') // Удаляем недопустимые символы
        .replaceAll(RegExp(r'\s+'), '_') // Заменяем пробелы на подчеркивания
        .replaceAll(RegExp(r'_+'), '_') // Убираем множественные подчеркивания
        .replaceAll(RegExp(r'^_'), '') // Убираем подчеркивание в начале
        .replaceAll(RegExp(r'_$'), ''); // Убираем подчеркивание в конце
  }


  Future<void> _exportGraph() async {
    final l10n = AppLocalizations.of(context)!;
    final graph = _currentGraph;
    if (graph == null) return;

    // Имя файла: имя (если английское) или ID + дата изменения в ISO 8601
    final dateStr = DateFormat('yyyy-MM-ddTHH-mm').format(graph.modifiedAt);
    String fileNamePrefix;
    if (_isEnglishName(graph.name)) {
      fileNamePrefix = _sanitizeFileName(graph.name);
    } else {
      fileNamePrefix = graph.id;
    }
    final defaultFileName = '${fileNamePrefix}_$dateStr.json';

    final jsonData = GraphStorage.getGraphAsJson(graph);
    final bytes = utf8.encode(jsonData);

    final String? outputPath = await FilePicker.platform.saveFile(
      dialogTitle: l10n.saveGraphDialogTitle,
      fileName: defaultFileName,
      type: FileType.custom,
      allowedExtensions: ['json'],
      bytes: bytes,
    );

    if (outputPath != null) {
      _showStatus('${l10n.graphSaved}: $outputPath');
    }
  }

  Future<void> _importGraph() async {
    final l10n = AppLocalizations.of(context)!;
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['json'],
    );

    if (result == null || result.files.single.path == null) return;

    final rawImportedGraph = await GraphStorage.importFromFile(
      result.files.single.path!,
    );

    if (rawImportedGraph == null) {
      _showStatus(l10n.importError);
      return;
    }

    // Проверяем, существует ли граф с таким ID
    final BuildingGraph graphToAdd;
    if (_collection.getGraph(rawImportedGraph.id) != null) {
      // Создаем новый граф с новым ID, но с данными импортированного
      final newGraph = BuildingGraph(
        name: rawImportedGraph.name,
      );
      // Копируем все узлы из импортированного графа
      for (final node in rawImportedGraph.allNodes) {
        newGraph.addNode(node);
      }
      graphToAdd = newGraph;
    } else {
      graphToAdd = rawImportedGraph;
    }

    setState(() {
      _collection.addGraph(graphToAdd);
      _collection.setActiveGraph(graphToAdd.id);
    });
    await GraphStorage.saveCollection(_collection);
    await _updateCacheStats();
    _showStatus(l10n.graphImported);
  }

  // === Действия с узлами ===

  void _addNode(Node node) {
    final l10n = AppLocalizations.of(context)!;
    final graph = _currentGraph;
    if (graph == null) return;

    setState(() {
      graph.addNode(node);
    });
    GraphStorage.saveCollection(_collection);
    _showStatus(l10n.nodeAdded);
  }

  void _updateNode(
    String nodeId, {
    String? name,
    List<String>? aliases,
    List<String>? imageUrls,
    List<String>? tour3dUrls,
  }) {
    final l10n = AppLocalizations.of(context)!;
    final graph = _currentGraph;
    if (graph == null) return;

    setState(() {
      graph.updateNode(
        nodeId,
        name: name,
        aliases: aliases,
        imageUrls: imageUrls,
        tour3dUrls: tour3dUrls,
      );
    });
    GraphStorage.saveCollection(_collection);
    _showStatus(l10n.nodeUpdated);
  }

  void _deleteNode(String nodeId) {
    final l10n = AppLocalizations.of(context)!;
    final graph = _currentGraph;
    if (graph == null) return;

    setState(() {
      graph.removeNode(nodeId);
    });
    GraphStorage.saveCollection(_collection);
    _showStatus(l10n.nodeDeleted);
  }

  // === Действия со связями ===

  void _addConnection(String from, String to) {
    final l10n = AppLocalizations.of(context)!;
    final graph = _currentGraph;
    if (graph == null) return;

    if (from == to) {
      _showStatus(l10n.sameNodeConnection);
      return;
    }

    setState(() {
      graph.addConnection(from, to);
    });
    GraphStorage.saveCollection(_collection);
    _showStatus(l10n.edgeAdded);
  }

  void _deleteConnection(String from, String to) {
    final l10n = AppLocalizations.of(context)!;
    final graph = _currentGraph;
    if (graph == null) return;

    setState(() {
      graph.removeConnection(from, to);
    });
    GraphStorage.saveCollection(_collection);
    _showStatus(l10n.edgeDeleted);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final graph = _currentGraph!;
    
    // Используем MediaQuery.sizeOf для производительности
    final screenWidth = MediaQuery.sizeOf(context).width;
    final isLargeScreen = screenWidth >= AppConstants.kLargeScreenBreakpoint;
    
    // На больших экранах используем NavigationRail вместо TabBar
    if (isLargeScreen) {
      return _buildLargeScreenLayout(context, l10n, graph);
    }
    
    // Мобильный layout с TabBar
    return _buildMobileLayout(context, l10n, graph);
  }
  
  /// Мобильный layout с TabBar (как было)
  Widget _buildMobileLayout(BuildContext context, AppLocalizations l10n, BuildingGraph graph) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: CustomGradientAppBar(
        title: graph.name,
        actions: [
          _GraphSelector(
            collection: _collection,
            currentGraph: graph,
            onSwitch: _switchGraph,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Theme.of(context).colorScheme.onPrimary,
          labelColor: Theme.of(context).colorScheme.onPrimary,
          unselectedLabelColor: Theme.of(context).colorScheme.onPrimary.withAlpha(179),
          tabs: [
            Tab(icon: const Icon(Icons.circle_outlined), text: l10n.nodes),
            Tab(icon: const Icon(Icons.info_outline), text: l10n.info),
          ],
        ),
      ),
      body: UnfocusOnTap(
        child: SafeArea(
          child: Column(
            children: [
              if (_statusMessage.isNotEmpty) StatusBar(message: _statusMessage),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: _buildTabChildren(graph),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  /// Layout для больших экранов с NavigationRail
  Widget _buildLargeScreenLayout(BuildContext context, AppLocalizations l10n, BuildingGraph graph) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: CustomGradientAppBar(
        title: graph.name,
        actions: [
          _GraphSelector(
            collection: _collection,
            currentGraph: graph,
            onSwitch: _switchGraph,
          ),
        ],
      ),
      body: UnfocusOnTap(
        child: SafeArea(
          child: Row(
            children: [
              // NavigationRail для больших экранов - более удобная навигация
              NavigationRail(
                selectedIndex: _tabController.index,
                onDestinationSelected: (index) {
                  setState(() {
                    _tabController.index = index;
                  });
                },
                labelType: NavigationRailLabelType.all,
                backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                selectedIconTheme: IconThemeData(color: Theme.of(context).colorScheme.primary),
                selectedLabelTextStyle: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
                destinations: [
                  NavigationRailDestination(
                    icon: const Icon(Icons.circle_outlined),
                    selectedIcon: const Icon(Icons.circle),
                    label: Text(l10n.nodes),
                  ),
                  NavigationRailDestination(
                    icon: const Icon(Icons.info_outline),
                    selectedIcon: const Icon(Icons.info),
                    label: Text(l10n.info),
                  ),
                ],
              ),
              const VerticalDivider(thickness: 1, width: 1),
              // Контент
              Expanded(
                child: Column(
                  children: [
                    if (_statusMessage.isNotEmpty) StatusBar(message: _statusMessage),
                    Expanded(
                      child: AnimatedBuilder(
                        animation: _tabController,
                        builder: (context, child) {
                          return IndexedStack(
                            index: _tabController.index,
                            children: _buildTabChildren(graph),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  /// Строит дочерние виджеты для табов
  List<Widget> _buildTabChildren(BuildingGraph graph) {
    return [
      NodesTab(
        graph: graph,
        onAddNode: _addNode,
        onUpdateNode: _updateNode,
        onDeleteNode: _deleteNode,
        onAddConnection: _addConnection,
        onDeleteConnection: _deleteConnection,
        onShowStatus: _showStatus,
      ),
      InfoTab(
        graph: graph,
        onCreateNew: _createNewGraph,
        onRename: _renameCurrentGraph,
        onClone: _cloneCurrentGraph,
        onExport: _exportGraph,
        onImport: _importGraph,
        onDelete: _deleteCurrentGraph,
        onDownloadImages: _downloadAllImages,
        onClearImageCache: _clearImageCache,
        onSwitchTab: (index) => _tabController.animateTo(index),
        cacheStats: _cacheStats,
      ),
    ];
  }
}

/// Селектор графов (PopupMenu в AppBar)
class _GraphSelector extends StatelessWidget {
  final GraphCollection collection;
  final BuildingGraph currentGraph;
  final Function(String) onSwitch;

  const _GraphSelector({
    required this.collection,
    required this.currentGraph,
    required this.onSwitch,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return PopupMenuButton<String>(
      tooltip: l10n.switchGraph,
      icon: const Icon(Icons.folder_open),
      onSelected: onSwitch,
      itemBuilder: (context) {
        return collection.allGraphs.map((graph) {
          final isActive = graph.id == currentGraph.id;
          return PopupMenuItem(
            value: graph.id,
            child: Row(
              children: [
                Icon(
                  isActive
                      ? Icons.radio_button_checked
                      : Icons.radio_button_unchecked,
                  color: isActive ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.outline,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    graph.name,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontWeight:
                          isActive ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ),
                Text(
                  '${graph.nodeCount}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                ),
              ],
            ),
          );
        }).toList();
      },
    );
  }
}

/// Диалог прогресса скачивания изображений
class _DownloadProgressDialog extends StatefulWidget {
  final ImageCacheService cacheService;
  final BuildingGraph graph;

  const _DownloadProgressDialog({
    required this.cacheService,
    required this.graph,
  });

  @override
  State<_DownloadProgressDialog> createState() => _DownloadProgressDialogState();
}

class _DownloadProgressDialogState extends State<_DownloadProgressDialog> {
  int _downloaded = 0;
  int _total = 0;
  String _currentUrl = '';
  bool _isComplete = false;

  @override
  void initState() {
    super.initState();
    _startDownload();
  }

  Future<void> _startDownload() async {
    final urls = widget.cacheService.getGraphImageUrls(widget.graph);
    setState(() {
      _total = urls.length;
    });

    await widget.cacheService.downloadAllImages(
      widget.graph,
      onProgress: (downloaded, total, currentUrl) {
        if (mounted) {
          setState(() {
            _downloaded = downloaded;
            _total = total;
            _currentUrl = currentUrl;
          });
        }
      },
    );

    if (mounted) {
      setState(() {
        _isComplete = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final progress = _total > 0 ? _downloaded / _total : 0.0;

    return AlertDialog(
      title: Text(l10n.downloadImages),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          LinearProgressIndicator(value: progress),
          const SizedBox(height: 16),
          Text(
            l10n.downloadImagesProgress(_downloaded, _total),
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          if (_currentUrl.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              _currentUrl.split('/').last,
              style: Theme.of(context).textTheme.bodySmall,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ),
      actions: [
        if (_isComplete || _total == 0)
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.confirm),
          ),
      ],
    );
  }
}

/// Виджет статусной панели
class StatusBar extends StatelessWidget {
  final String message;

  const StatusBar({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: Theme.of(context).colorScheme.primaryContainer,
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Text(
        message,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: Theme.of(context).colorScheme.onPrimaryContainer,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}
