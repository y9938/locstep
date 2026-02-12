import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/graph.dart';
import '../l10n/app_localizations.dart';

/// Хранение и загрузка графов
class GraphStorage {
  static const String _collectionKey = 'saved_graphs';

  /// Сохранить коллекцию графов
  static Future<void> saveCollection(GraphCollection collection) async {
    final prefs = await SharedPreferences.getInstance();
    final json = jsonEncode(collection.toJson());
    await prefs.setString(_collectionKey, json);
  }

  /// Загрузить коллекцию графов
  static Future<GraphCollection> loadCollection() async {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString(_collectionKey);
    
    if (json == null) {
      return GraphCollection();
    }
    
    try {
      return GraphCollection.fromJson(jsonDecode(json));
    } catch (e) {
      debugPrint('Ошибка загрузки графов: $e');
      return GraphCollection();
    }
  }

  /// Сохранить один граф (для обратной совместимости)
  static Future<void> saveGraph(BuildingGraph graph) async {
    final collection = await loadCollection();
    
    // Удаляем старый граф с таким же ID если есть
    collection.removeGraph(graph.id);
    collection.addGraph(graph);
    collection.setActiveGraph(graph.id);
    
    await saveCollection(collection);
  }

  /// Загрузить активный граф
  static Future<BuildingGraph?> loadGraph() async {
    final collection = await loadCollection();
    return collection.activeGraph;
  }

  /// Экспорт графа в файл
  static Future<String?> exportToFile(BuildingGraph graph, String filePath) async {
    try {
      final file = File(filePath);
      final data = {
        'graph': graph.toJson(),
        'exportedAt': DateTime.now().toIso8601String(),
      };
      await file.writeAsString(JsonEncoder.withIndent('  ').convert(data));
      return file.path;
    } catch (e) {
      debugPrint('Ошибка экспорта: $e');
      return null;
    }
  }

  /// Получить JSON для экспорта
  static String getGraphAsJson(BuildingGraph graph) {
    final data = {
      'graph': graph.toJson(),
      'exportedAt': DateTime.now().toIso8601String(),
    };
    return JsonEncoder.withIndent('  ').convert(data);
  }

  /// Импорт графа из файла
  static Future<BuildingGraph?> importFromFile(String filePath) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) return null;
      
      final content = await file.readAsString();
      final data = jsonDecode(content) as Map<String, dynamic>;
      return BuildingGraph.fromJson(data['graph']);
    } catch (e) {
      debugPrint('Ошибка импорта: $e');
      return null;
    }
  }

  /// Пустой граф
  static BuildingGraph getDefaultGraph(BuildContext context) {
    String defaultName = AppLocalizations.of(context)!.newGraphDefaultName;
    return BuildingGraph(name: defaultName);
  }

  /// Есть ли сохранённые графы
  static Future<bool> hasSavedGraphs() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(_collectionKey);
  }

  /// Удалить все сохранённые графы
  static Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_collectionKey);
  }

  /// Удалить конкретный граф
  static Future<void> deleteGraph(String graphId) async {
    final collection = await loadCollection();
    collection.removeGraph(graphId);
    await saveCollection(collection);
  }
}
