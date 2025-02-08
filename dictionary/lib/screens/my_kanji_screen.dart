import 'package:flutter/material.dart';
import '../database_helper.dart';
class MyKanjiScreen extends StatefulWidget {
  @override
  _MyKanjiScreenState createState() => _MyKanjiScreenState();
}

class _MyKanjiScreenState extends State<MyKanjiScreen> {
  List<String> savedKanji = [];

  void loadSavedKanji() async {
    final db = await DatabaseHelper().database;
    final res = await db.query('saved_kanji');
    setState(() {
      savedKanji = res.map((e) => e['kanji'] as String).toList();
    });
  }

  @override
  void initState() {
    super.initState();
    loadSavedKanji();
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: savedKanji.length,
      itemBuilder: (context, index) {
        return Card(
          margin: EdgeInsets.all(8),
          child: ListTile(
            title: Text(savedKanji[index], style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
          ),
        );
      },
    );
  }
}
