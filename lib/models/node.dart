/// Узел графа — точка в здании с ближайшими соседями
/// 
/// Модель для алгоритма A*: узел знает только своих соседей (их ID).
/// Алиасы нужны только для поиска узла по имени (ауд. 608 → room_608).
class Node {
  /// Уникальный ID узла (например: "room_608", "stair_north")
  final String id;
  
  /// Название для отображения: "Аудитория 608"
  final String name;
  
  /// Алиасы для поиска: ["аудитория 608", "ауд. 608", "608"]
  final List<String> aliases;
  
  /// ID ближайших соседей (куда можно пойти из этого узла)
  final List<String> neighbors;

  /// Ссылки на фото узла (опционально)
  final List<String> imageUrls;

  /// Ссылки на 3D-туры (опционально)
  final List<String> tour3dUrls;

  Node({
    required this.id,
    required this.name,
    this.aliases = const [],
    this.neighbors = const [],
    this.imageUrls = const [],
    this.tour3dUrls = const [],
  });

  @override
  String toString() => '$name ($id)';

  /// Проверяет, соответствует ли узел запросу
  /// 
  /// Поддерживает поиск по нескольким словам: каждый токен запроса должен
  /// встречаться в названии, ID или алиасах узла (порядок слов не важен).
  /// Пример: запрос "2 Юж" найдёт узел "Южная 2".
  bool matches(String query) {
    final q = query.toLowerCase().trim();
    if (q.isEmpty) return false;
    
    // Разбиваем запрос на токены (слова) по пробелам
    final tokens = q.split(RegExp(r'\s+')).where((t) => t.isNotEmpty).toList();
    if (tokens.isEmpty) return false;
    
    // Подготавливаем поисковые тексты (в нижнем регистре)
    final lowerName = name.toLowerCase();
    final lowerId = id.toLowerCase();
    final lowerAliases = aliases.map((a) => a.toLowerCase()).toList();
    
    // Проверяем, что каждый токен встречается хотя бы в одном из полей
    for (final token in tokens) {
      bool tokenFound = false;
      
      // Проверяем name
      if (lowerName.contains(token)) {
        tokenFound = true;
      }
      // Проверяем id (точное совпадение или подстрока)
      else if (lowerId == token || lowerId.contains(token)) {
        tokenFound = true;
      }
      // Проверяем aliases
      else {
        for (final alias in lowerAliases) {
          if (alias.contains(token)) {
            tokenFound = true;
            break;
          }
        }
      }
      
      // Если хотя бы один токен не найден, узел не подходит
      if (!tokenFound) {
        return false;
      }
    }
    
    // Все токены найдены
    return true;
  }

  // Сериализация в JSON (дополнительные поля только при наличии)
  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'id': id,
      'name': name,
      'aliases': aliases,
      'neighbors': neighbors,
    };
    if (imageUrls.isNotEmpty) {
      map['imageUrls'] = imageUrls;
    }
    if (tour3dUrls.isNotEmpty) {
      map['tour3dUrls'] = tour3dUrls;
    }
    return map;
  }

  // Десериализация из JSON
  factory Node.fromJson(Map<String, dynamic> json) => Node(
    id: json['id'] as String,
    name: json['name'] as String,
    aliases: (json['aliases'] as List<dynamic>?)?.cast<String>() ?? [],
    neighbors: (json['neighbors'] as List<dynamic>?)?.cast<String>() ?? [],
    imageUrls: (json['imageUrls'] as List<dynamic>?)?.cast<String>() ?? [],
    tour3dUrls: (json['tour3dUrls'] as List<dynamic>?)?.cast<String>() ?? [],
  );
}
