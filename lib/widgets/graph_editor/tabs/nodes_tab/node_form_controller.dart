import 'package:flutter/material.dart';
import '../../../../engine/alias_resolver.dart';
import '../../../../models/node.dart';
import '../../utils/id_generator.dart';

/// Контроллер формы добавления/редактирования узла
/// 
/// Отделяет логику формы от UI, позволяет тестировать бизнес-логику отдельно
class NodeFormController extends ChangeNotifier {
  final TextEditingController nodeIdController = TextEditingController();
  final TextEditingController nodeNameController = TextEditingController();
  final TextEditingController neighborSearchController = TextEditingController();
  final TextEditingController customAliasController = TextEditingController();
  final TextEditingController tour3dUrlController = TextEditingController();
  final TextEditingController imageUrlController = TextEditingController();
  final FocusNode nodeIdFocusNode = FocusNode();
  
  bool _autoGenerateId = true;
  String? _editingNodeId;
  final List<String> _selectedNeighbors = [];
  final List<String> _customAliases = [];
  final List<String> _tour3dUrls = [];
  final List<String> _imageUrls = [];
  List<String>? _frozenAutoAliases;
  bool _autoAliasesEnabled = true;
  
  // Callbacks
  final void Function(String message) onShowStatus;
  final void Function(Node node) onAddNode;
  final void Function(String nodeId, {
    String? name,
    List<String>? aliases,
    List<String>? imageUrls,
    List<String>? tour3dUrls,
  }) onUpdateNode;
  final void Function(String from, String to) onAddConnection;
  final void Function(String from, String to) onDeleteConnection;
  final bool Function(String id) nodeExists;

  NodeFormController({
    required this.onShowStatus,
    required this.onAddNode,
    required this.onUpdateNode,
    required this.onAddConnection,
    required this.onDeleteConnection,
    required this.nodeExists,
  }) {
    _initListeners();
  }

  // Getters
  bool get autoGenerateId => _autoGenerateId;
  String? get editingNodeId => _editingNodeId;
  bool get isEditing => _editingNodeId != null;
  List<String> get selectedNeighbors => List.unmodifiable(_selectedNeighbors);
  List<String> get customAliases => List.unmodifiable(_customAliases);
  List<String> get tour3dUrls => List.unmodifiable(_tour3dUrls);
  List<String> get imageUrls => List.unmodifiable(_imageUrls);
  bool get autoAliasesEnabled => _autoAliasesEnabled;
  bool get isAutoAliasesFrozen => _frozenAutoAliases != null;
  
  List<String> get currentAutoAliases {
    if (!_autoAliasesEnabled) return [];
    if (isAutoAliasesFrozen) return _frozenAutoAliases!;
    if (nodeNameController.text.isEmpty) return [];
    return AliasResolver.generate(nodeNameController.text);
  }

  void _initListeners() {
    nodeNameController.addListener(_onNameChanged);
    nodeIdController.addListener(_onIdChanged);
  }

  void _onNameChanged() {
    if (_autoGenerateId && nodeNameController.text.isNotEmpty) {
      final generatedId = generateIdFromName(nodeNameController.text);
      nodeIdController.value = TextEditingValue(
        text: generatedId,
        selection: TextSelection.collapsed(offset: generatedId.length),
      );
    }
    if (_autoAliasesEnabled && !isAutoAliasesFrozen) {
      notifyListeners();
    }
  }

  void _onIdChanged() {
    if (_autoGenerateId && 
        nodeIdController.text.isNotEmpty && 
        nodeIdFocusNode.hasFocus) {
      _autoGenerateId = false;
      notifyListeners();
    }
  }

  void toggleAutoGenerateId() {
    _autoGenerateId = !_autoGenerateId;
    notifyListeners();
    if (_autoGenerateId) _onNameChanged();
  }

  void toggleFreezeAutoAliases() {
    if (isAutoAliasesFrozen) {
      _frozenAutoAliases = null;
    } else {
      _frozenAutoAliases = List.from(currentAutoAliases);
    }
    notifyListeners();
  }

  void toggleAutoAliases() {
    _autoAliasesEnabled = !_autoAliasesEnabled;
    if (!_autoAliasesEnabled) {
      _frozenAutoAliases = null;
    }
    notifyListeners();
  }

  void removeAutoAlias(String alias) {
    if (isAutoAliasesFrozen) {
      _frozenAutoAliases!.remove(alias);
      notifyListeners();
    }
  }

  void addCustomAlias(String alias) {
    if (alias.trim().isEmpty) return;
    if (_customAliases.contains(alias)) {
      onShowStatus('alias_exists'); // Key будет преобразован в UI
      return;
    }
    _customAliases.add(alias);
    notifyListeners();
  }

  void removeCustomAlias(String alias) {
    _customAliases.remove(alias);
    notifyListeners();
  }

  void addNeighbor(String nodeId) {
    if (!_selectedNeighbors.contains(nodeId)) {
      _selectedNeighbors.add(nodeId);
      notifyListeners();
    }
  }

  void removeNeighbor(String nodeId) {
    _selectedNeighbors.remove(nodeId);
    notifyListeners();
  }

  void addImageUrl(String url) {
    final u = url.trim();
    if (u.isEmpty) return;
    if (_imageUrls.contains(u)) return;
    _imageUrls.add(u);
    notifyListeners();
  }

  void removeImageUrl(int index) {
    if (index >= 0 && index < _imageUrls.length) {
      _imageUrls.removeAt(index);
      notifyListeners();
    }
  }

  void addTour3dUrl(String url) {
    final u = url.trim();
    if (u.isEmpty) return;
    if (_tour3dUrls.contains(u)) return;
    _tour3dUrls.add(u);
    notifyListeners();
  }

  void removeTour3dUrl(int index) {
    if (index >= 0 && index < _tour3dUrls.length) {
      _tour3dUrls.removeAt(index);
      notifyListeners();
    }
  }

  bool handleAddNode(String Function(String key) getLocalizedError) {
    if (nodeIdController.text.isEmpty || nodeNameController.text.isEmpty) {
      onShowStatus(getLocalizedError('fill_required_fields'));
      return false;
    }

    final id = nodeIdController.text.trim();

    if (nodeExists(id)) {
      onShowStatus('${getLocalizedError('node_exists')}: "$id"');
      return false;
    }

    final allAliases = {...currentAutoAliases, ..._customAliases}.toList();

    final node = Node(
      id: id,
      name: nodeNameController.text.trim(),
      aliases: allAliases,
      neighbors: [],
      imageUrls: List.from(_imageUrls),
      tour3dUrls: List.from(_tour3dUrls),
    );

    onAddNode(node);

    for (final neighborId in _selectedNeighbors) {
      onAddConnection(id, neighborId);
    }

    clearForm();
    return true;
  }

  bool handleUpdateNode(Set<String> oldNeighbors) {
    if (_editingNodeId == null) return false;

    final id = _editingNodeId!;
    final name = nodeNameController.text.trim();
    final allAliases = {...currentAutoAliases, ..._customAliases}.toList();
    final newNeighbors = _selectedNeighbors.toSet();

    onUpdateNode(
      id,
      name: name.isNotEmpty ? name : null,
      aliases: allAliases,
      imageUrls: List.from(_imageUrls),
      tour3dUrls: List.from(_tour3dUrls),
    );

    final addedNeighbors = newNeighbors.difference(oldNeighbors);
    for (final neighborId in addedNeighbors) {
      onAddConnection(id, neighborId);
    }

    final removedNeighbors = oldNeighbors.difference(newNeighbors);
    for (final neighborId in removedNeighbors) {
      onDeleteConnection(id, neighborId);
    }

    clearForm();
    return true;
  }

  void startEditing(Node node) {
    _editingNodeId = node.id;
    nodeIdController.text = node.id;
    nodeNameController.text = node.name;
    
    final autoAliases = AliasResolver.generate(node.name).toSet();
    _customAliases.clear();
    _customAliases.addAll(
      node.aliases.where((a) => !autoAliases.contains(a))
    );
    _frozenAutoAliases = null;
    _autoAliasesEnabled = true;
    
    _selectedNeighbors.clear();
    _selectedNeighbors.addAll(node.neighbors);
    _tour3dUrls.clear();
    _tour3dUrls.addAll(node.tour3dUrls);
    tour3dUrlController.clear();
    _imageUrls.clear();
    _imageUrls.addAll(node.imageUrls);
    _autoGenerateId = false;
    
    notifyListeners();
  }

  void clearForm() {
    nodeIdController.clear();
    nodeNameController.clear();
    neighborSearchController.clear();
    customAliasController.clear();
    tour3dUrlController.clear();
    imageUrlController.clear();
    _selectedNeighbors.clear();
    _customAliases.clear();
    _tour3dUrls.clear();
    _imageUrls.clear();
    _frozenAutoAliases = null;
    _autoGenerateId = true;
    _editingNodeId = null;
    notifyListeners();
  }

  @override
  void dispose() {
    nodeNameController.removeListener(_onNameChanged);
    nodeIdController.removeListener(_onIdChanged);
    nodeIdFocusNode.dispose();
    nodeIdController.dispose();
    nodeNameController.dispose();
    neighborSearchController.dispose();
    customAliasController.dispose();
    tour3dUrlController.dispose();
    imageUrlController.dispose();
    super.dispose();
  }
}
