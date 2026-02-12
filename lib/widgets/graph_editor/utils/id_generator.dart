import 'package:snowball_stemmer/snowball_stemmer.dart';

/* INVARIANT: generate() outputs [a-z0-9_]+ only.
 * Sanitization via negative match [^a-z0-9_] occurs post-translation.
 */

abstract class IdGenerator {
  String generate(String name);
}

/// ---------- RUSSIAN (Cyrillic) ----------

class RussianIdGenerator implements IdGenerator {
  /* static final: shared instance avoids per-call construction. */
  static final _stemmer = SnowballStemmer(Algorithm.russian);
  
  static final _wordDict = const <String, String>{
    'аудитория': 'classroom', 'кабинет': 'office', 'лаборатория': 'laboratory',
    'лаб': 'lab', 'лестница': 'stairwell', 'лифт': 'elevator',
    'туалет': 'restroom', 'уборная': 'restroom', 'северная': 'north',
    'южная': 'south', 'восточная': 'east', 'западная': 'west',
    'главный': 'main', 'вход': 'entrance', 'выход': 'exit',
    'коридор': 'hallway', 'комната': 'room', 'зал': 'hall',
    'библиотека': 'library', 'буфет': 'snack_bar', 'столовая': 'dining_hall',
    'администрация': 'admin', 'кафедра': 'department', 'деканат': 'dean_office',
    'приемная': 'reception', 'комендант': 'housing_office', 
    'общежитие': 'dormitory', 'корпус': 'building', 'крыло': 'wing',
    'этаж': 'floor', 'цокольный': 'ground', 'подвал': 'basement',
    'крыша': 'roof', 'парковка': 'parking', 'велопарковка': 'bike_rack',
    'склад': 'storage', 'венткамера': 'mechanical_room', 'ректор': 'president',
    'бухгалтерия': 'bursar_office', 'автошкола': 'driving_school', 
    'спортзал': 'gym', 'гардероб': 'coatroom',
  };
  
  static final _phraseDict = const <String, String>{
    'эвакуационный_выход': 'emergency_exit', 'актовый_зал': 'assembly_hall',
    'читальный_зал': 'reading_room', 'зал_учённого_совета': 'faculty_senate_room',
    'кабинет_ректора': 'president_office', 'приемная_ректора': 'president_office',
    'приёмная_ректора': 'president_office', 'приемная_комиссия': 'admissions_office',
    'приёмная_комиссия': 'admissions_office', 
    'центр_маркетинга_и_развития': 'advancement_office',
    'научный_центр': 'research_center', 'бюро_пропусков': 'id_card_office',
    'пропускной_контроль': 'security_checkpoint',
  };
  
  static final _maxPhraseLen = _phraseDict.keys
      .map((k) => k.split('_').length)
      .reduce((a, b) => a > b ? a : b);
  
  static final _translitMap = const <String, String>{
    'а':'a','б':'b','в':'v','г':'g','д':'d','е':'e','ё':'yo',
    'ж':'zh','з':'z','и':'i','й':'y','к':'k','л':'l','м':'m',
    'н':'n','о':'o','п':'p','р':'r','с':'s','т':'t','у':'u',
    'ф':'f','х':'h','ц':'ts','ч':'ch','ш':'sh','щ':'sch',
    'ъ':'','ы':'y','ь':'','э':'e','ю':'yu','я':'ya',' ':'_'
  };
  
  static String _transliterate(String s) => 
      s.split('').map((c) => _translitMap[c] ?? c).join();

  @override
  String generate(String name) {
    /* Assumes: name non-null, caller validates input. */
    final tokens = name.toLowerCase().split(RegExp(r'\s+'));
    final out = <String>[];
    int i = 0;
    
    /* Algorithm: longest-match-first; prevents "cabinet" consuming "cabinet rector".
     * Phrase dict keys use '_' separators (e.g., "кабинет_ректора").
     */
    while (i < tokens.length) {
      bool hit = false;
      for (int len = _maxPhraseLen; len >= 2; len--) {
        if (i + len > tokens.length) continue;
        final key = tokens.sublist(i, i + len).join('_');
        final val = _phraseDict[key];
        if (val != null) { out.add(val); i += len; hit = true; break; }
      }
      if (hit) continue;
      
      final t = tokens[i];
      final w = _wordDict[t];
      if (w != null) {
        out.add(w);
      } else {
        final stem = _stemmer.stem(t);
        out.add(_wordDict[stem] ?? _transliterate(t));
      }
      i++;
    }
    
    return out.join('_')
        .replaceAll(RegExp(r'[^a-z0-9_]'), '')
        .replaceAll(RegExp(r'_+'), '_');
  }
}

/// ---------- GENERIC (Latin) ----------

class GenericIdGenerator implements IdGenerator {
  static final _nonAlnum = RegExp(r'[^a-z0-9\s]');
  static final _spaces = RegExp(r'\s+');
  
  @override
  String generate(String name) => name.toLowerCase()
      .replaceAll(_nonAlnum, '')
      .trim()
      .replaceAll(_spaces, '_');
}

/// ---------- FACTORY ----------

class IdGeneratorFactory {
  static final _ru = RussianIdGenerator();
  static final _gen = GenericIdGenerator();
  
  /* O(k) where k = index of first Cyrillic char; RegExp returns on first match.
   * Assumes: text non-null (caller checks).
   */
  static final _cyr = RegExp(r'[А-Яа-яЁё]');
  
  static IdGenerator get(String text) => 
      _cyr.hasMatch(text) ? _ru : _gen;
}

/// ---------- API ----------

String generateIdFromName(String name) => 
    IdGeneratorFactory.get(name).generate(name);
