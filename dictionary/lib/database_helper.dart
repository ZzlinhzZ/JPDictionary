import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'models/KanjiModel.dart';
import 'models/SavedKanjiModel.dart';
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
    final res =
        await db.query('kanji', where: 'kanji LIKE ?', whereArgs: ['%$query%']);
    return res.map((e) => Kanji.fromMap(e)).toList();
  }

  Future<List<Word>> getWordList(String query) async {
    final db = await database;
    final res = await db.query('words_Test',
        where: 'written LIKE ? OR kanji LIKE ?',
        whereArgs: ['%$query%', '%$query%']);
    return res.map((e) => Word.fromMap(e)).toList();
  }

  Future<Word?> getExactWordMatch(String query) async {
    final db = await database;
    final res =
        await db.query('words_Test', where: 'written = ?', whereArgs: [query]);
    if (res.isNotEmpty) {
      return Word.fromMap(res.first);
    }
    return null;
  }

  Future<List<Kanji>> getKanjiFromWord(String query) async {
    final db = await database;
    Set<String> kanjiSet =
        query.split('').toSet(); // Lấy từng chữ Kanji trong từ
    List<Kanji> results = [];

    for (String kanji in kanjiSet) {
      final res =
          await db.query('kanji', where: 'kanji = ?', whereArgs: [kanji]);
      if (res.isNotEmpty) {
        results.add(Kanji.fromMap(res.first));
      }
    }

    return results;
  }

  Future<void> saveWord(
      String written, String pronounced, String glosses) async {
    final db = await database;
    await db.insert(
        'saved_kanji',
        {
          'kanji': written, // Lưu toàn bộ từ vựng
          'pronounced': pronounced,
          'meaning': glosses
        },
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> removeWord(String written) async {
    final db = await database;
    await db.delete('saved_kanji', where: 'kanji = ?', whereArgs: [written]);
  }

  // Future<bool> isKanjiSaved(String kanji) async {
  //   final db = await database;
  //   final result =
  //       await db.query('saved_kanji', where: 'kanji = ?', whereArgs: [kanji]);
  //   return result.isNotEmpty;
  // }

  // Future<List<String>> getSavedKanji() async {
  //   final db = await database;
  //   final result = await db.query('saved_kanji');
  //   return result.map((e) => e['kanji'] as String).toList();
  // }

  //
  // Thêm một từ vào bảng saved_kanji
  Future<void> saveKanji(SavedKanji kanji) async {
    final db = await database;
    await db.insert(
      'saved_kanji',
      kanji.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

// Xóa một từ khỏi bảng saved_kanji
  Future<void> removeKanji(int id) async {
    final db = await database;
    await db.delete('saved_kanji', where: 'id = ?', whereArgs: [id]);
  }

// Kiểm tra xem Kanji đã được lưu chưa
  Future<bool> isKanjiSaved(String kanji) async {
    final db = await database;
    final result =
        await db.query('saved_kanji', where: 'kanji = ?', whereArgs: [kanji]);
    return result.isNotEmpty;
  }

// Lấy danh sách tất cả Kanji đã lưu
  Future<List<SavedKanji>> getSavedKanji() async {
    final db = await database;
    final resuilt = await db.query('saved_kanji');
    return resuilt.map((e) => SavedKanji.fromMap(e)).toList();
  }
}
