 import 'package:sqflite/sqflite.dart';


// void openDatabase() async{
//     final db = await openDatabase('dictionary.db');
// }
void runQuery() async {
    final db = await openDatabase('my_database.db');

    try {
    await db.rawQuery('SELECT * FROM kanji WHERE id = 1');
    } catch (Exception) {
    print('An error occurred!');
    }
}