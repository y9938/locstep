import '../models/node.dart';

/// Генератор автоматических алиасов для узлов университета
/// 
/// Поддерживает предопределённые паттерны:
/// - Аудитории: аудитория ↔ room
/// - Кабинеты: кабинет ↔ cabinet
/// - Лестницы: лестница ↔ stairs
class AliasResolver {
  
  /// Предопределённые синонимы (исключены префиксы, покрываемые substring-поиском)
  static final Map<String, List<String>> _synonyms = {
    'аудитория': ['room', 'auditorium'],
    'ауд.': ['аудитория'],
    'кабинет': ['cabinet', 'office'],
    'каб.': ['кабинет'],
    'лаборатория': ['laboratory', 'lab'],
    'лаб.': ['лаборатория'],
    'лестница': ['stairs', 'staircase', 'stair'],
    'лестн.': ['лестница'],
    'лифт': ['elevator', 'lift'],
    'туалет': ['уборная', 'wc', 'restroom', 'toilet', 'санузел'],
    'северная': ['north'],
    'южная': ['south'],
    'восточная': ['east'],
    'западная': ['west'],
    'главный': ['main'],
    'вход': ['entrance', 'entry'],
    'коридор': ['corridor', 'hallway'],
    'ресепшен': ['reception', 'менеджер', 'manager'],
  };

  /// Генерирует все алиасы для названия
  /// 
  /// INVARIANT: Не возвращаем алиасы, являющиеся подстрокой name (покрыты contains-поиском).
  /// Пример: "Аудитория 608" → ["room", "auditorium"] ("ауд." исключён как подстрока)
  static List<String> generate(String name) {
    final aliases = <String>{};
    final lowerName = name.toLowerCase();
    
    // Извлекаем номер ТОЛЬКО для отделения префикса (синонимы без цифры)
    final numberMatch = RegExp(r'\d+').firstMatch(name);
    final prefix = (numberMatch != null)
        ? name.substring(0, numberMatch.start).trim().toLowerCase()
        : lowerName;
    
    // Генерируем синонимы ключевых слов
    for (final entry in _synonyms.entries) {
      if (prefix.contains(entry.key)) {
        for (final synonym in entry.value) {
          final lowerSynonym = synonym.toLowerCase();
          /* INVARIANT: Skip if already substring of name (covered by contains search) */
          if (lowerName.contains(lowerSynonym)) continue;
          aliases.add(synonym);
        }
      }
    }
    
    return aliases.toList()..sort();
  }

  /// Создаёт узел с автоматическими алиасами
  static Node createNode({
    required String id,
    required String name,
    List<String> customAliases = const [],
    List<String> neighbors = const [],
  }) {
    final autoAliases = generate(name);
    final allAliases = {...autoAliases, ...customAliases}.toList();
    
    return Node(
      id: id,
      name: name,
      aliases: allAliases,
      neighbors: neighbors,
    );
  }
}
