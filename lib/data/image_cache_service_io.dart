import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

import '../models/graph.dart';

/// IO implementation of image cache: stores files on disk with a JSON index.
class ImageCacheService {
  ImageCacheService();

  static const String _cacheSubdir = 'image_cache';
  static const String _indexFileName = 'image_cache_index.json';

  Directory? _cacheDir;
  final Map<String, String> _index = {};
  bool _indexLoaded = false;
  final Map<String, Future<String>> _inFlight = {};

  Future<Directory> _getCacheDir() async {
    if (_cacheDir != null) return _cacheDir!;
    final base = await getTemporaryDirectory();
    _cacheDir = Directory('${base.path}/$_cacheSubdir');
    if (!await _cacheDir!.exists()) {
      await _cacheDir!.create(recursive: true);
    }
    return _cacheDir!;
  }

  Future<void> _loadIndex() async {
    if (_indexLoaded) return;
    _indexLoaded = true;
    try {
      final dir = await _getCacheDir();
      final indexFile = File('${dir.path}/$_indexFileName');
      if (!await indexFile.exists()) return;
      final content = await indexFile.readAsString();
      final decoded = jsonDecode(content) as Map<String, dynamic>?;
      if (decoded != null) {
        for (final e in decoded.entries) {
          if (e.value is String) _index[e.key] = e.value as String;
        }
      }
    } catch (_) {
      _index.clear();
    }
  }

  Future<void> _saveIndex() async {
    final dir = await _getCacheDir();
    final indexFile = File('${dir.path}/$_indexFileName');
    await indexFile.writeAsString(jsonEncode(_index));
  }

  static String _hashUrl(String url) {
    final bytes = utf8.encode(url);
    final digest = sha256.convert(bytes);
    return digest.toString().substring(0, 16);
  }

  /// Returns the path to the cached file if present and the file exists; otherwise null.
  /// Removes stale index entries when the file is missing.
  Future<String?> getCachedPath(String url) async {
    final normalized = url.trim();
    if (normalized.isEmpty) return null;
    await _loadIndex();
    final fileName = _index[normalized];
    if (fileName == null) return null;
    final dir = await _getCacheDir();
    final file = File('${dir.path}/$fileName');
    if (await file.exists()) return file.path;
    _index.remove(normalized);
    await _saveIndex();
    return null;
  }

  /// Returns the path to the cached file, downloading and caching if necessary.
  /// Deduplicates concurrent downloads for the same URL.
  Future<String> getOrDownload(String url) async {
    final normalized = url.trim();
    if (normalized.isEmpty) {
      throw ArgumentError('Image URL must not be empty');
    }
    final existing = await getCachedPath(normalized);
    if (existing != null) return existing;

    if (_inFlight.containsKey(normalized)) {
      return _inFlight[normalized]!;
    }

    final future = _downloadAndCache(normalized);
    _inFlight[normalized] = future;
    try {
      final path = await future;
      return path;
    } finally {
      _inFlight.remove(normalized);
    }
  }

  Future<String> _downloadAndCache(String url) async {
    final response = await http.get(Uri.parse(url));
    if (response.statusCode != 200) {
      throw Exception('Failed to load image: HTTP ${response.statusCode}');
    }
    final bytes = response.bodyBytes;
    final fileName = _hashUrl(url);
    final dir = await _getCacheDir();
    final file = File('${dir.path}/$fileName');
    await file.writeAsBytes(bytes);
    await _loadIndex();
    _index[url] = fileName;
    await _saveIndex();
    return file.path;
  }

  // === Методы для работы с графом ===

  /// Получает все URL изображений из графа
  List<String> getGraphImageUrls(BuildingGraph graph) {
    final urls = <String>{};
    for (final node in graph.allNodes) {
      for (final url in node.imageUrls) {
        final trimmed = url.trim();
        if (trimmed.isNotEmpty) {
          urls.add(trimmed);
        }
      }
    }
    return urls.toList();
  }

  /// Скачивает все изображения графа и возвращает статистику
  /// [onProgress] — колбэк прогресса (скачано, всего, текущий url)
  Future<DownloadResult> downloadAllImages(
    BuildingGraph graph, {
    void Function(int downloaded, int total, String currentUrl)? onProgress,
  }) async {
    final urls = getGraphImageUrls(graph);
    if (urls.isEmpty) {
      return const DownloadResult(downloaded: 0, failed: 0, total: 0);
    }

    int downloaded = 0;
    int failed = 0;

    for (int i = 0; i < urls.length; i++) {
      final url = urls[i];
      onProgress?.call(downloaded, urls.length, url);

      try {
        await getOrDownload(url);
        downloaded++;
      } catch (e) {
        failed++;
      }
    }

    return DownloadResult(downloaded: downloaded, failed: failed, total: urls.length);
  }

  /// Очищает кэш для списка URL
  /// Возвращает количество удалённых файлов
  Future<int> clearCacheForUrls(List<String> urls) async {
    if (urls.isEmpty) return 0;
    await _loadIndex();

    int deletedCount = 0;
    final dir = await _getCacheDir();

    for (final url in urls) {
      final normalized = url.trim();
      if (normalized.isEmpty) continue;

      final fileName = _index[normalized];
      if (fileName != null) {
        final file = File('${dir.path}/$fileName');
        if (await file.exists()) {
          try {
            await file.delete();
            deletedCount++;
          } catch (_) {
            // Игнорируем ошибки удаления
          }
        }
        _index.remove(normalized);
      }
    }

    await _saveIndex();
    return deletedCount;
  }

  /// Очищает весь кэш изображений графа
  Future<int> clearGraphCache(BuildingGraph graph) async {
    final urls = getGraphImageUrls(graph);
    return clearCacheForUrls(urls);
  }

  /// Проверяет, сколько изображений графа уже закэшировано
  Future<CacheStats> getGraphCacheStats(BuildingGraph graph) async {
    final urls = getGraphImageUrls(graph);
    int cached = 0;

    for (final url in urls) {
      final path = await getCachedPath(url);
      if (path != null) cached++;
    }

    return CacheStats(cached: cached, total: urls.length);
  }
}

/// Результат массового скачивания
class DownloadResult {
  final int downloaded;
  final int failed;
  final int total;

  const DownloadResult({
    required this.downloaded,
    required this.failed,
    required this.total,
  });

  bool get success => failed == 0 && downloaded == total;
}

/// Статистика кэша
class CacheStats {
  final int cached;
  final int total;

  const CacheStats({required this.cached, required this.total});

  bool get isEmpty => total == 0;
  bool get isComplete => cached == total && total > 0;
}
