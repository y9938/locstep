import '../models/graph.dart';
import '../models/node.dart';

/// Результат поиска пути
class PathResult {
  final List<Node> nodes;
  final int steps;

  PathResult({
    required this.nodes,
    this.steps = 0,
  });

  bool get isEmpty => nodes.isEmpty;
  bool get isNotEmpty => nodes.isNotEmpty;

  @override
  String toString() => 'Path: ${nodes.length} nodes, $steps steps';
}

/// Поиск пути по графу (BFS — поиск в ширину)
/// 
/// Алгоритм работает с моделью "узел + соседи":
/// - Каждый узел знает только своих ближайших соседей
/// - Алгоритм строит маршрут, проходя от узла к узлу
/// 
/// BFS находит кратчайший путь по количеству шагов.
class PathFinder {
  final BuildingGraph graph;

  PathFinder(this.graph);

  /// Найти путь от startId до targetId
  PathResult findPath(String startId, String targetId) {
    final startNode = graph.getNode(startId);
    final targetNode = graph.getNode(targetId);
    
    if (startNode == null || targetNode == null) {
      return PathResult(nodes: []);
    }

    if (startId == targetId) {
      return PathResult(nodes: [startNode], steps: 0);
    }

    // BFS: очередь узлов для посещения
    final queue = <_QueueEntry>[];
    // Посещённые узлы: nodeId -> previousNodeId
    final visited = <String, String>{};
    
    queue.add(_QueueEntry(startId, null));
    visited[startId] = '';

    while (queue.isNotEmpty) {
      final current = queue.removeAt(0);
      final currentId = current.nodeId;

      if (currentId == targetId) {
        return _reconstructPath(visited, currentId, targetNode);
      }

      // Проверяем всех соседей текущего узла
      for (final neighbor in graph.getNeighbors(currentId)) {
        final neighborId = neighbor.id;
        
        if (!visited.containsKey(neighborId)) {
          visited[neighborId] = currentId;
          queue.add(_QueueEntry(neighborId, currentId));
        }
      }
    }

    // Путь не найден
    return PathResult(nodes: []);
  }

  PathResult _reconstructPath(
    Map<String, String> visited, 
    String targetId,
    Node targetNode,
  ) {
    final path = <Node>[];
    final idPath = <String>[];
    
    // Собираем путь с конца
    var currentId = targetId;
    while (currentId.isNotEmpty) {
      idPath.add(currentId);
      final prevId = visited[currentId];
      if (prevId == null || prevId.isEmpty) break;
      currentId = prevId;
    }
    
    // Разворачиваем и получаем узлы
    for (final id in idPath.reversed) {
      final node = graph.getNode(id);
      if (node != null) path.add(node);
    }
    
    return PathResult(nodes: path, steps: path.length - 1);
  }
}

/// Вспомогательный класс для очереди BFS
class _QueueEntry {
  final String nodeId;
  final String? fromId;
  _QueueEntry(this.nodeId, this.fromId);
}
