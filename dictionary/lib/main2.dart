import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:path/path.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';
import 'dart:io';
import 'dart:async';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (kIsWeb) {
    // Use databaseFactoryFfiWeb for web
    databaseFactory = databaseFactoryFfiWeb;
  } else if (Platform.isWindows || Platform.isLinux) {
    // Initialize sqflite_ffi for desktop
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SQLite Viewer',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Database? _database;
  List<Map<String, dynamic>> _kanjiData = [];
  List<Map<String, dynamic>> _wordsData = [];

  @override
  void initState() {
    super.initState();
    _initDatabase();
  }

  Future<void> _initDatabase() async {
    final dbPath = 'dictionary.db';

    if (!kIsWeb) {
      // For non-web platforms, use getDatabasesPath to get the database path
      final databasesPath = await getDatabasesPath();
      final fullPath = join(databasesPath, dbPath);

      // Check if the database exists
      final exists = await databaseExists(fullPath);

      if (!exists) {
        print("Database does not exist. Copying from assets...");
        // If the database does not exist, load it from assets
        final data = await rootBundle.load('assets/dictionary.db');
        final bytes =
            data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
        await File(fullPath).writeAsBytes(bytes, flush: true);
      } else {
        print("Database exists at path: $fullPath");
      }

      // Open the database
      _database = await openDatabase(fullPath);
    } else {
      // For web platforms, open the database from the asset
      print("Opening database on Web: $dbPath");
      try {
        // Try opening the database or querying
        _database = await openDatabase(dbPath);
        // Do queries or other database operations
      } catch (e) {
        print("Database Error: $e");
      }
    }

    // Fetch data after initializing the database
    await _fetchData();
  }

  // Ensure that the necessary tables exist on the web platform
  Future<void> _ensureTablesExist() async {
    // Check if the 'kanji' table exists
    final result = await _database!.rawQuery(
        'SELECT name FROM sqlite_master WHERE type="table" AND name="kanji"');
    if (result.isEmpty) {
      // If the table doesn't exist, create it (or do any other necessary initialization)
      await _database!.execute(
        'CREATE TABLE kanji(id INTEGER PRIMARY KEY, character TEXT, meaning TEXT)',
      );
    }

    // Similarly, check and create the 'words_test' table if needed
    final wordsResult = await _database!.rawQuery(
        'SELECT name FROM sqlite_master WHERE type="table" AND name="words_test"');
    if (wordsResult.isEmpty) {
      await _database!.execute(
        'CREATE TABLE words_test(id INTEGER PRIMARY KEY, word TEXT, meaning TEXT)',
      );
    }
  }

  Future<void> _fetchData() async {
    if (_database == null) return;

    try {
      // Check if the 'kanji' table exists
      final kanjiData =
          await _database!.query('kanji', where: 'id = ?', whereArgs: [1]);
      print("Kanji Data: $kanjiData");

      final wordsData =
          await _database!.query('words_test', where: 'id = ?', whereArgs: [1]);
      print("Words Data: $wordsData");

      setState(() {
        _kanjiData = kanjiData;
        _wordsData = wordsData;
      });
    } catch (e) {
      print("Error fetching data: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('SQLite Viewer')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Kanji Table:',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            ..._kanjiData.map((e) => Text(e.toString())).toList(),
            SizedBox(height: 20),
            Text('Words Test Table:',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            ..._wordsData.map((e) => Text(e.toString())).toList(),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _database?.close();
    super.dispose();
  }
}
