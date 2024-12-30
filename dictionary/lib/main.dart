import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:io';  // dùng lớp file
import 'dart:typed_data';  // dùng lớp ByteData
// import 'package:sqflite_common_ffi/sqflite_ffi.dart';
// Import sqflite_common_ffi for desktop or test environments

void main() {
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
    // Copy the database file from assets to the device
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'dictionary.db');

    // Check if the database already exists
    final exists = await databaseExists(path);

    if (!exists) {
      // Copy from assets
      ByteData data = await rootBundle.load('assets/dictionary.db');
      List<int> bytes = data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);

      // Write the bytes to the file
      await File(path).writeAsBytes(bytes, flush: true);
    }

    // Open the database
    _database = await openDatabase(path);

    // Fetch data for id = 1
    await _fetchData();
  }

  Future<void> _fetchData() async {
    if (_database == null) return;

    // Fetch data from kanji table
    final kanjiData = await _database!.query('kanji', where: 'id = ?', whereArgs: [1]);
    final wordsData = await _database!.query('words_test', where: 'id = ?', whereArgs: [1]);
     
    // In ra dữ liệu để kiểm tra
    print('Kanji Data: $kanjiData');
    print('Words Data: $wordsData');

    setState(() {
      _kanjiData = kanjiData;
      _wordsData = wordsData;
    });
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
            Text('Kanji Table:', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            ..._kanjiData.map((e) => Text(e.toString())).toList(),
            SizedBox(height: 20),
            Text('Words Test Table:', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
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
