import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'models/KanjiModel.dart';
import 'models/WordModel.dart';

class DatabaseHelper {
  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await initDB();
    return _database!;
  }

  Future<Database> initDB() async {
    String path = join(await getDatabasesPath(), 'dictionary.db');
    return await openDatabase(path, version: 1);
  }

  Future<List<Kanji>> getKanjiList(String query) async {
    final db = await database;
    final res = await db.query('kanji', where: 'kanji LIKE ?', whereArgs: ['%$query%']);
    return res.map((e) => Kanji.fromMap(e)).toList();
  }

  Future<List<Word>> getWordList(String query) async {
    final db = await database;
    final res = await db.query('words_Test', where: 'written LIKE ? OR kanji LIKE ?', whereArgs: ['%$query%', '%$query%']);
    return res.map((e) => Word.fromMap(e)).toList();
  }
  Future<Word?> getExactWordMatch(String query) async {
    final db = await database;
    final res = await db.query('words_Test', where: 'written = ?', whereArgs: [query]);
    if (res.isNotEmpty) {
        return Word.fromMap(res.first);
    }
    return null;
  }

  Future<List<Kanji>> getKanjiFromWord(String query) async {
    final db = await database;
    Set<String> kanjiSet = query.split('').toSet(); // Lấy từng chữ Kanji trong từ
    List<Kanji> results = [];

    for (String kanji in kanjiSet) {
        final res = await db.query('kanji', where: 'kanji = ?', whereArgs: [kanji]);
        if (res.isNotEmpty) {
        results.add(Kanji.fromMap(res.first));
        }
    }

    return results;
  }
  Future<void> saveKanji(String kanji) async {
    final db = await database;
    await db.insert('saved_kanji', {'kanji': kanji}, conflictAlgorithm: ConflictAlgorithm.ignore);
  }

}
