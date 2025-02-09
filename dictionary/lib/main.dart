import 'dart:io';
// import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sqflite/sqflite.dart';
import 'database_helper.dart';
// import 'models/KanjiModel.dart';
// import 'models/WordModel.dart';
import 'dictionary_screen.dart';
import 'dart:async';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await deleteDatabaseFile(); // Xóa database cũ
  await copyDatabaseFromAssets(); // Sao chép database mới
  await checkDatabase(); // Kiểm tra lại
  runApp(MyApp());
}

// Future<void> checkDatabase() async {
//   final db = await DatabaseHelper().database;
//   final result =
//       await db.rawQuery("SELECT name FROM sqlite_master WHERE type='table'");
//   print("Tables in database: ${result.map((e) => e['name'])}");
// }
Future<void> checkDatabase() async {
  final databasesPath = await getDatabasesPath();
  final dbPath = "$databasesPath/dictionary.db";

  print("Database path: $dbPath"); // Kiểm tra đường dẫn database

  final db = await DatabaseHelper().database;
  final result =
      await db.rawQuery("SELECT name FROM sqlite_master WHERE type='table'");
  print("Tables in database: ${result.map((e) => e['name'])}");
}

Future<void> deleteDatabaseFile() async {
  final databasesPath = await getDatabasesPath();
  final dbPath = "$databasesPath/dictionary.db";

  if (await File(dbPath).exists()) {
    await File(dbPath).delete();
    print("Database deleted successfully!");
  } else {
    print("Database does not exist.");
  }
}

Future<void> copyDatabaseFromAssets() async {
  final databasesPath = await getDatabasesPath();
  final dbPath = "$databasesPath/dictionary.db";

  if (!await File(dbPath).exists()) {
    print("Copying database from assets...");
    ByteData data = await rootBundle.load('assets/dictionary.db');
    List<int> bytes = data.buffer.asUint8List();
    await File(dbPath).writeAsBytes(bytes);
    print("Database copied successfully!");
  } else {
    print("Database already exists.");
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: DictionaryScreen(),
    );
  }
}
