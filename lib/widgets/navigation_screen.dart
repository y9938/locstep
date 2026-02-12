import 'package:flutter/material.dart';
import '../data/graph_storage.dart';
import '../utils/open_3d_tour_helper.dart';
import '../app_config.dart';
import '../l10n/app_localizations.dart';
import '../engine/pathfinder.dart';
import '../engine/instruction_builder.dart';
import '../models/graph.dart';
import '../models/node.dart';
import '../app_constants.dart';
import 'common/custom_app_bar.dart';
import 'common/node_autocomplete_field.dart';
import 'common/unfocus_on_tap.dart';
import 'common/cached_node_image.dart';
import 'common/fullscreen_image_dialog.dart';
import 'graph_editor/graph_editor_screen.dart';
import 'navigation/node_search_overlay.dart';
import 'navigation/route_instructions_view.dart';
import 'settings_screen.dart';

class NavigationScreen extends StatefulWidget {
  const NavigationScreen({super.key});

  @override
  State<NavigationScreen> createState() => _NavigationScreenState();
}

class _NavigationScreenState extends State<NavigationScreen> {
  BuildingGraph? graph;
  bool _isLoading = true;
  
  final startController = TextEditingController();
  final targetController = TextEditingController();

  String resultText = '';
  List<Instruction> instructions = [];

  // Состояние поиска узлов
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  bool _isSearchExpanded = false;
  String _searchQuery = '';
  List<Node> _searchResults = [];

  @override
  void initState() {
    super.initState();
    _loadGraph();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _searchFocusNode.dispose();
    startController.dispose();
    targetController.dispose();
    super.dispose();
  }

  Future<void> _loadGraph() async {
    final savedGraph = await GraphStorage.loadGraph();
    
    if (savedGraph != null && savedGraph.nodeCount > 0) {
      graph = savedGraph;
    } else {
      graph = null;
    }
    
    setState(() {
      _isLoading = false;
    });
  }

  void _openGraphEditor() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const GraphEditorScreen()),
    ).then((_) => _loadGraph());
  }

  void _findRoute() {
    final l10n = AppLocalizations.of(context)!;
    
    if (graph == null) {
      setState(() {
        resultText = l10n.noGraphData;
        instructions = [];
      });
      return;
    }

    final startQuery = startController.text.trim();
    final targetQuery = targetController.text.trim();

    final startNode = graph!.findNode(startQuery);
    final targetNode = graph!.findNode(targetQuery);

    if (startNode == null) {
      setState(() {
        resultText = '${l10n.startNotFound}: "$startQuery"';
        instructions = [];
      });
      return;
    }

    if (targetNode == null) {
      setState(() {
        resultText = '${l10n.targetNotFound}: "$targetQuery"';
        instructions = [];
      });
      return;
    }

    final finder = PathFinder(graph!);
    final path = finder.findPath(startNode.id, targetNode.id);

    if (path.isEmpty) {
      setState(() {
        resultText = l10n.noRoute;
        instructions = [];
      });
      return;
    }

    final builder = InstructionBuilder(l10n);
    final summary = builder.buildSummary(path, targetNode.name);
    final inst = builder.build(path);

    setState(() {
      resultText = summary;
      instructions = inst;
    });
  }

  void _onSearchChanged() {
    final query = _searchController.text;
    setState(() {
      _searchQuery = query;
      _updateSearchResults();
    });

    // Восстанавливаем фокус только когда панель поиска развернута.
    // Это предотвращает повторное открытие клавиатуры после выбора узла.
    if (_isSearchExpanded) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_searchFocusNode.canRequestFocus && !_searchFocusNode.hasFocus) {
          _searchFocusNode.requestFocus();
        }
      });
    }
  }

  void _updateSearchResults() {
    if (graph == null || _searchQuery.isEmpty) {
      _searchResults = [];
      return;
    }

    final query = _searchQuery.trim();
    final matched = graph!.allNodes
        .where((node) => node.matches(query))
        .toList();

    // Сортировка по алфавиту по названию узла
    matched.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    _searchResults = matched;
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
                        onTap: () => FullscreenImageDialog.show(context, imageUrl: url),
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

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // Используем MediaQuery.sizeOf для производительности (перестраивается только при изменении размера)
    final screenWidth = MediaQuery.sizeOf(context).width;
    final isLargeScreen = screenWidth >= AppConstants.kLargeScreenBreakpoint;
    
    // На больших экранах ограничиваем ширину контента для лучшей читаемости
    // Согласно Material 3: макс ширина для comfortable чтения ~840dp
    final contentMaxWidth = isLargeScreen ? 840.0 : double.infinity;
    final contentPadding = isLargeScreen
        ? const EdgeInsets.symmetric(
            horizontal: AppConstants.kScreenPaddingWide,
            vertical: AppConstants.kScreenPadding,
          )
        : const EdgeInsets.all(AppConstants.kScreenPadding);

    return Scaffold(
      // SafeArea только снизу и по бокам, сверху НЕТ - чтобы SliverAppBar мог растянуться под статус-бар
      body: Stack(
        children: [
          UnfocusOnTap(
            child: SafeArea(
              top: false,
              bottom: true,
              left: true,
              right: true,
              child: CustomScrollView(
          slivers: [
            CustomSliverAppBar(
              expandedHeight: isLargeScreen ? 120 : 100,
              title: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.navigation, color: Theme.of(context).colorScheme.onPrimary, size: 20),
                  const SizedBox(width: AppConstants.kSpacingUnit),
                  Text(
                    AppConfig.appName,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onPrimary,
                    ),
                  ),
                ],
              ),
              actions: [
                IconButton(
                  icon: Icon(Icons.settings, color: Theme.of(context).colorScheme.onPrimary),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SettingsScreen(),
                      ),
                    );
                  },
                  tooltip: l10n.settings,
                ),
                IconButton(
                  icon: Icon(Icons.edit_location_alt, color: Theme.of(context).colorScheme.onPrimary),
                  onPressed: _openGraphEditor,
                  tooltip: l10n.graphEditor,
                ),
              ],
            ),
            
            // Контент с адаптивной шириной
            SliverPadding(
              padding: EdgeInsets.only(
                left: contentPadding.left,
                right: contentPadding.right,
                top: contentPadding.top,
                bottom: contentPadding.bottom + (_isSearchExpanded ? 80 : 60), // Отступ для поисковой строки
              ),
              sliver: SliverToBoxAdapter(
                child: Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: contentMaxWidth),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Карточка поиска маршрута (только если есть граф)
                        if (graph != null)
                        Card(
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppConstants.kCardBorderRadius),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(AppConstants.kCardPadding),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  l10n.buildRoute,
                                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: AppConstants.kCardPadding),
                                
                                // На больших экранах размещаем поля в ряд
                                if (isLargeScreen) ...[
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        child: NodeAutocompleteField(
                                          graph: graph!,
                                          controller: startController,
                                          labelText: l10n.from,
                                          hintText: l10n.fromHint,
                                          prefixIcon: Icon(Icons.my_location, color: Theme.of(context).colorScheme.tertiary),
                                        ),
                                      ),
                                      const SizedBox(width: AppConstants.kScreenPadding),
                                      Expanded(
                                        child: NodeAutocompleteField(
                                          graph: graph!,
                                          controller: targetController,
                                          labelText: l10n.to,
                                          hintText: l10n.toHint,
                                          prefixIcon: Icon(Icons.flag, color: Theme.of(context).colorScheme.error),
                                          excludeNodeIds: [],
                                        ),
                                      ),
                                    ],
                                  ),
                                ] else ...[
                                  // Поле Откуда (мобильный layout)
                                  NodeAutocompleteField(
                                    graph: graph!,
                                    controller: startController,
                                    labelText: l10n.from,
                                    hintText: l10n.fromHint,
                                    prefixIcon: Icon(Icons.my_location, color: Theme.of(context).colorScheme.tertiary),
                                  ),
                                  const SizedBox(height: AppConstants.kScreenPadding),

                                  // Поле Куда
                                  NodeAutocompleteField(
                                    graph: graph!,
                                    controller: targetController,
                                    labelText: l10n.to,
                                    hintText: l10n.toHint,
                                    prefixIcon: Icon(Icons.flag, color: Theme.of(context).colorScheme.error),
                                    excludeNodeIds: [],
                                  ),
                                ],
                                const SizedBox(height: AppConstants.kScreenPaddingWide),

                                // Кнопка поиска с фиксированной максимальной шириной на больших экранах
                                SizedBox(
                                  width: double.infinity,
                                  height: 50,
                                  child: ElevatedButton.icon(
                                    onPressed: _findRoute,
                                    icon: const Icon(Icons.directions_walk, size: 24),
                                    label: Text(
                                      l10n.buildRoute,
                                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: Theme.of(context).colorScheme.onPrimary,
                                      ),
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Theme.of(context).colorScheme.primary,
                                      foregroundColor: Theme.of(context).colorScheme.onPrimary,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(AppConstants.kCardBorderRadius),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        
                        if (graph != null) const SizedBox(height: AppConstants.kScreenPaddingWide),
                        
                        // Инструкции - используем GridView на больших экранах
                        if (instructions.isNotEmpty) ...[
                          Text(
                            l10n.routeInstructions,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: AppConstants.kCardBorderRadius),
                          RouteInstructionsView(
                            instructions: instructions,
                            isLargeScreen: isLargeScreen,
                            onOpen3DTour: _open3DTour,
                          ),
                        ],
                        
                        // Пустое состояние - нет графа
                        if (graph == null) ...[
                          SizedBox(height: AppConstants.kScreenPaddingWide + AppConstants.kScreenPadding),
                          Center(
                            child: Column(
                              children: [
                                Icon(
                                  Icons.map_outlined,
                                  size: 80,
                                  color: Theme.of(context).colorScheme.outline,
                                ),
                                const SizedBox(height: AppConstants.kScreenPadding),
                                Text(
                                  l10n.noGraphData,
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: AppConstants.kSpacingUnit),
                                Text(
                                  l10n.createGraphHint,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(color: Theme.of(context).colorScheme.outline)                                ),
                                const SizedBox(height: AppConstants.kScreenPaddingWide),
                                ElevatedButton.icon(
                                  onPressed: _openGraphEditor,
                                  icon: const Icon(Icons.add_location_alt),
                                  label: Text(l10n.createGraph),
                                ),
                              ],
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
        ),
            ),
          ),
          // Поиск узлов внизу экрана
          if (graph != null)
            NodeSearchOverlay(
              searchController: _searchController,
              searchFocusNode: _searchFocusNode,
              isSearchExpanded: _isSearchExpanded,
              searchResults: _searchResults,
              onCollapse: () {
                setState(() {
                  _isSearchExpanded = false;
                  _searchQuery = '';
                  _searchResults = [];
                  _searchController.clear();
                });
                FocusScope.of(context).unfocus();
                _searchFocusNode.unfocus();
              },
              onExpand: () => setState(() => _isSearchExpanded = true),
              onNodeTap: (node) => _showNodePreview(context, node),
            ),
        ],
      ),
    );
  }

  Future<void> _open3DTour(String url) async {
    await open3DTourWithConfirmation(context, url);
  }
}
