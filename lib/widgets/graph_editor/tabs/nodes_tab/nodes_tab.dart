import 'package:flutter/material.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../models/graph.dart';
import '../../../../models/node.dart';
import '../../../../app_constants.dart';
import 'node_form_controller.dart';
import 'node_form_view.dart';
import 'nodes_list_view.dart';

export 'node_form_controller.dart';
export 'node_form_view.dart';
export 'nodes_list_view.dart';
export 'alias_sections.dart';

/// Вкладка "Узлы" - управление узлами графа
///
/// Архитектура:
/// - [NodeFormController] - логика формы и состояние
/// - [NodeFormView] - UI формы добавления/редактирования
/// - [NodesListView] - список существующих узлов
/// - [AliasSections] - секции авто и кастомных алиасов
class NodesTab extends StatefulWidget {
  final BuildingGraph graph;
  final Function(Node node) onAddNode;
  final Function(String nodeId, {
    String? name,
    List<String>? aliases,
    List<String>? imageUrls,
    List<String>? tour3dUrls,
  }) onUpdateNode;
  final Function(String nodeId) onDeleteNode;
  final Function(String from, String to) onAddConnection;
  final Function(String from, String to) onDeleteConnection;
  final Function(String message) onShowStatus;

  const NodesTab({
    super.key,
    required this.graph,
    required this.onAddNode,
    required this.onUpdateNode,
    required this.onDeleteNode,
    required this.onAddConnection,
    required this.onDeleteConnection,
    required this.onShowStatus,
  });

  @override
  State<NodesTab> createState() => _NodesTabState();
}

class _NodesTabState extends State<NodesTab> {
  NodeFormController? _controller;
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _initController();
  }

  void _initController() {
    if (_controller != null) return;
    
    _controller = NodeFormController(
      onShowStatus: widget.onShowStatus,
      onAddNode: widget.onAddNode,
      onUpdateNode: widget.onUpdateNode,
      onAddConnection: widget.onAddConnection,
      onDeleteConnection: widget.onDeleteConnection,
      nodeExists: (id) => widget.graph.getNode(id) != null,
    );
  }

  @override
  void dispose() {
    _controller?.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    final l10n = AppLocalizations.of(context)!;
    final controller = _controller!;

    if (controller.isEditing) {
      // Получаем старых соседей для сравнения
      final oldNode = widget.graph.getNode(controller.editingNodeId!);
      final oldNeighbors = oldNode?.neighbors.toSet() ?? <String>{};
      controller.handleUpdateNode(oldNeighbors);
    } else {
      controller.handleAddNode((key) => _getLocalizedError(l10n, key));
    }
  }

  String _getLocalizedError(AppLocalizations l10n, String key) {
    switch (key) {
      case 'fill_required_fields':
        return l10n.fillRequiredFields;
      case 'node_exists':
        return l10n.nodeExists;
      case 'alias_exists':
        return l10n.aliasExists;
      default:
        return key;
    }
  }

  void _startEditing(Node node) {
    _controller!.startEditing(node);
  }

  void _clearForm() {
    _controller!.clearForm();
  }

  @override
  Widget build(BuildContext context) {
    final controller = _controller;
    if (controller == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        return LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth > AppConstants.kLargeScreenBreakpoint;
            
            if (isWide) {
              // Широкий экран - форма и список в ряд
              return Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Форма добавления/редактирования — слева
                  Expanded(
                    flex: 2,
                    child: NodeFormView(
                      controller: controller,
                      graph: widget.graph,
                      onSubmit: _handleSubmit,
                      onCancel: _clearForm,
                    ),
                  ),

                  // Вертикальный разделитель
                  const VerticalDivider(width: 1),

                  // Список узлов — справа
                  Expanded(
                    flex: 3,
                    child: NodesListView(
                      graph: widget.graph,
                      onEdit: _startEditing,
                      onDelete: widget.onDeleteNode,
                      searchController: _searchController,
                      searchQuery: _searchQuery,
                      onSearchChanged: (value) {
                        setState(() {
                          _searchQuery = value;
                        });
                      },
                    ),
                  ),
                ],
              );
            } else {
              // Узкий экран (телефон) - вкладки
              final l10n = AppLocalizations.of(context)!;
              return DefaultTabController(
                length: 2,
                child: Column(
                  children: [
                    TabBar(
                      tabs: [
                        Tab(
                          icon: const Icon(Icons.edit_outlined),
                          text: controller.isEditing ? l10n.edit : l10n.add,
                        ),
                        Tab(
                          icon: const Icon(Icons.list),
                          text: l10n.nodesList,
                        ),
                      ],
                    ),
                    Expanded(
                      child: TabBarView(
                        children: [
                          NodeFormView(
                            controller: controller,
                            graph: widget.graph,
                            onSubmit: _handleSubmit,
                            onCancel: _clearForm,
                          ),
                          NodesListView(
                            graph: widget.graph,
                            onEdit: _startEditing,
                            onDelete: widget.onDeleteNode,
                            searchController: _searchController,
                            searchQuery: _searchQuery,
                            onSearchChanged: (value) {
                              setState(() {
                                _searchQuery = value;
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }
          },
        );
      },
    );
  }
}
