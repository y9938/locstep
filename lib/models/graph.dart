import 'node.dart';

/// Граф здания с метаданными
class BuildingGraph {
  final String id;
  String name;
  final Map<String, Node> _nodes = {};
  DateTime createdAt;
  DateTime modifiedAt;

  BuildingGraph({
    String? id,
    required this.name,
    DateTime? createdAt,
    DateTime? modifiedAt,
  })  : id = id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        createdAt = createdAt ?? DateTime.now(),
        modifiedAt = modifiedAt ?? DateTime.now();

  /// Обновить время модификации
  void _touch() {
    modifiedAt = DateTime.now();
  }

  /// Добавить узел
  void addNode(Node node) {
    _nodes[node.id] = node;
    _touch();
  }

  /// Обновить узел
  void updateNode(String nodeId, {
    String? name,
    List<String>? aliases,
    List<String>? neighbors,
    List<String>? imageUrls,
    List<String>? tour3dUrls,
  }) {
    final node = _nodes[nodeId];
    if (node == null) return;

    _nodes[nodeId] = Node(
      id: node.id,
      name: name ?? node.name,
      aliases: aliases ?? node.aliases,
      neighbors: neighbors ?? node.neighbors,
      imageUrls: imageUrls ?? node.imageUrls,
      tour3dUrls: tour3dUrls ?? node.tour3dUrls,
    );
    _touch();
  }

  /// Удалить узел и все ссылки на него из других узлов
  void removeNode(String nodeId) {
    _nodes.remove(nodeId);
    // Удаляем ссылки из других узлов
    for (final node in _nodes.values) {
      if (node.neighbors.contains(nodeId)) {
        _updateNodeInternal(node.id, neighbors: node.neighbors.where((id) => id != nodeId).toList());
      }
    }
    _touch();
  }

  void _updateNodeInternal(String nodeId, {List<String>? neighbors}) {
    final node = _nodes[nodeId];
    if (node == null) return;
    
    _nodes[nodeId] = Node(
      id: node.id,
      name: node.name,
      aliases: node.aliases,
      neighbors: neighbors ?? node.neighbors,
      imageUrls: node.imageUrls,
      tour3dUrls: node.tour3dUrls,
    );
  }

  /// Добавить связь между двумя узлами (двунаправленную)
  void addConnection(String nodeId1, String nodeId2) {
    _addNeighbor(nodeId1, nodeId2);
    _addNeighbor(nodeId2, nodeId1);
    _touch();
  }

  /// Удалить связь между узлами
  void removeConnection(String nodeId1, String nodeId2) {
    _removeNeighbor(nodeId1, nodeId2);
    _removeNeighbor(nodeId2, nodeId1);
    _touch();
  }

  void _addNeighbor(String nodeId, String neighborId) {
    final node = _nodes[nodeId];
    if (node == null) return;
    if (node.neighbors.contains(neighborId)) return;
    
    _nodes[nodeId] = Node(
      id: node.id,
      name: node.name,
      aliases: node.aliases,
      neighbors: [...node.neighbors, neighborId],
      imageUrls: node.imageUrls,
      tour3dUrls: node.tour3dUrls,
    );
  }

  void _removeNeighbor(String nodeId, String neighborId) {
    final node = _nodes[nodeId];
    if (node == null) return;
    
    _nodes[nodeId] = Node(
      id: node.id,
      name: node.name,
      aliases: node.aliases,
      neighbors: node.neighbors.where((id) => id != neighborId).toList(),
      imageUrls: node.imageUrls,
      tour3dUrls: node.tour3dUrls,
    );
  }

  /// Получить узел по ID
  Node? getNode(String id) => _nodes[id];

  /// Получить все узлы
  List<Node> get allNodes => _nodes.values.toList();

  /// Получить соседей узла
  List<Node> getNeighbors(String nodeId) {
    final node = _nodes[nodeId];
    if (node == null) return [];
    return node.neighbors
        .map((id) => _nodes[id])
        .where((n) => n != null)
        .cast<Node>()
        .toList();
  }

  /// Найти узел по имени/алиасу/ID
  Node? findNode(String query) {
    if (query.isEmpty) return null;
    final q = query.toLowerCase().trim();

    // 1. Точное совпадение по ID
    if (_nodes.containsKey(q)) return _nodes[q];

    // 2. Ищем по имени и алиасам
    Node? bestMatch;
    int bestScore = 0;

    for (final node in _nodes.values) {
      if (node.matches(q)) {
        int score = 0;
        if (node.id.toLowerCase() == q) {
          score = 100;
        } else if (node.name.toLowerCase() == q) {
          score = 90;
        } else if (node.aliases.any((a) => a.toLowerCase() == q)) {
          score = 80;
        } else {
          score = 50;
        }

        if (score > bestScore) {
          bestScore = score;
          bestMatch = node;
        }
      }
    }

    return bestMatch;
  }

  /// Найти все подходящие узлы
  List<Node> findNodes(String query) {
    if (query.isEmpty) return [];
    final q = query.toLowerCase().trim();
    return _nodes.values.where((n) => n.matches(q)).toList();
  }

  /// Очистить граф
  void clear() {
    _nodes.clear();
    _touch();
  }

  /// Количество узлов
  int get nodeCount => _nodes.length;

  /// Количество связей
  int get connectionCount {
    int count = 0;
    for (final node in _nodes.values) {
      count += node.neighbors.length;
    }
    return count ~/ 2;
  }

  /// Общее количество image URLs во всех узлах (включая дубликаты)
  int get imageUrlsCount {
    int count = 0;
    for (final node in _nodes.values) {
      count += node.imageUrls.length;
    }
    return count;
  }

  /// Количество уникальных image URLs
  int get uniqueImageUrlsCount {
    final uniqueUrls = <String>{};
    for (final node in _nodes.values) {
      for (final url in node.imageUrls) {
        uniqueUrls.add(url.trim());
      }
    }
    return uniqueUrls.length;
  }

  /// Общее количество tour3d URLs во всех узлах (включая дубликаты)
  int get tour3dUrlsCount {
    int count = 0;
    for (final node in _nodes.values) {
      count += node.tour3dUrls.length;
    }
    return count;
  }

  /// Количество уникальных tour3d URLs
  int get uniqueTour3dUrlsCount {
    final uniqueUrls = <String>{};
    for (final node in _nodes.values) {
      for (final url in node.tour3dUrls) {
        uniqueUrls.add(url.trim());
      }
    }
    return uniqueUrls.length;
  }

  /// Клонировать граф
  /// [newName] - обязательное новое имя (передаётся из UI с локализацией)
  BuildingGraph clone({required String newName}) {
    final cloned = BuildingGraph(name: newName);
    for (final node in _nodes.values) {
      cloned.addNode(Node(
        id: node.id,
        name: node.name,
        aliases: List.from(node.aliases),
        neighbors: List.from(node.neighbors),
        imageUrls: List.from(node.imageUrls),
        tour3dUrls: List.from(node.tour3dUrls),
      ));
    }
    return cloned;
  }

  @override
  String toString() => 'Graph "$name": $nodeCount nodes';

  // Сериализация в JSON
  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'createdAt': createdAt.toIso8601String(),
    'modifiedAt': modifiedAt.toIso8601String(),
    'nodes': _nodes.values.map((n) => n.toJson()).toList(),
  };

  // Десериализация из JSON
  factory BuildingGraph.fromJson(Map<String, dynamic> json) {
    final graph = BuildingGraph(
      id: json['id'] as String?,
      name: json['name'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      modifiedAt: DateTime.parse(json['modifiedAt'] as String),
    );
    
    final nodesJson = json['nodes'] as List<dynamic>?;
    if (nodesJson != null) {
      for (final nodeJson in nodesJson) {
        graph.addNode(Node.fromJson(nodeJson as Map<String, dynamic>));
      }
    }
    return graph;
  }
}

/// Менеджер коллекции графов
class GraphCollection {
  final List<BuildingGraph> _graphs = [];
  String? _activeGraphId;

  GraphCollection();

  List<BuildingGraph> get allGraphs => List.unmodifiable(_graphs);

  BuildingGraph? get activeGraph {
    if (_activeGraphId == null) return null;
    try {
      return _graphs.firstWhere((g) => g.id == _activeGraphId);
    } catch (_) {
      return null;
    }
  }

  String? get activeGraphId => _activeGraphId;

  void addGraph(BuildingGraph graph) {
    _graphs.add(graph);
    _activeGraphId ??= graph.id;
  }

  void removeGraph(String graphId) {
    _graphs.removeWhere((g) => g.id == graphId);
    if (_activeGraphId == graphId) {
      _activeGraphId = _graphs.isNotEmpty ? _graphs.first.id : null;
    }
  }

  void setActiveGraph(String graphId) {
    if (_graphs.any((g) => g.id == graphId)) {
      _activeGraphId = graphId;
    }
  }

  BuildingGraph? getGraph(String graphId) {
    try {
      return _graphs.firstWhere((g) => g.id == graphId);
    } catch (_) {
      return null;
    }
  }

  bool get isEmpty => _graphs.isEmpty;
  int get count => _graphs.length;

  // Сериализация
  Map<String, dynamic> toJson() => {
    'graphs': _graphs.map((g) => g.toJson()).toList(),
    'activeGraphId': _activeGraphId,
  };

  // Десериализация
  factory GraphCollection.fromJson(Map<String, dynamic> json) {
    final collection = GraphCollection();
    
    final graphsJson = json['graphs'] as List<dynamic>?;
    if (graphsJson != null) {
      for (final graphJson in graphsJson) {
        collection.addGraph(BuildingGraph.fromJson(graphJson as Map<String, dynamic>));
      }
    }
    
    collection._activeGraphId = json['activeGraphId'] as String?;
    return collection;
  }
}
