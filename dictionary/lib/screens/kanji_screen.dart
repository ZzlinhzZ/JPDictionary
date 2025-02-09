import 'package:flutter/material.dart';
import '../models/KanjiModel.dart';
import '../database_helper.dart';

class KanjiScreen extends StatefulWidget {
  final List<Kanji> kanjiList;

  KanjiScreen({required this.kanjiList});

  @override
  _KanjiScreenState createState() => _KanjiScreenState();
}

class _KanjiScreenState extends State<KanjiScreen> {
  final DatabaseHelper dbHelper = DatabaseHelper();
  Set<String> savedKanji = {};

  @override
  void initState() {
    super.initState();
    loadSavedKanji();
  }

  void loadSavedKanji() async {
    final saved = await dbHelper.getSavedKanji();
    setState(() {
      savedKanji = saved.toSet();
    });
  }

  void toggleSave(String kanji) async {
    if (savedKanji.contains(kanji)) {
      await dbHelper.removeKanji(kanji);
      savedKanji.remove(kanji);
    } else {
      await dbHelper.saveKanji(kanji);
      savedKanji.add(kanji);
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (widget.kanjiList.isEmpty) {
      return Center(
          child:
              Text("Không tìm thấy hán tự.", style: TextStyle(fontSize: 18)));
    }

    return ListView.builder(
      padding: EdgeInsets.all(8),
      itemCount: widget.kanjiList.length,
      itemBuilder: (context, index) {
        final kanji = widget.kanjiList[index];
        bool isSaved = savedKanji.contains(kanji.kanji);
        return Card(
          elevation: 3,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ListTile(
            contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            title: Text(kanji.kanji,
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 4),
                Text('Nghĩa: ${kanji.meanings}',
                    style: TextStyle(fontSize: 16)),
                SizedBox(height: 4),
                Text('Âm Kun: ${kanji.kunReadings}',
                    style: TextStyle(fontSize: 16)),
                Text('Âm On: ${kanji.onReadings}',
                    style: TextStyle(fontSize: 16)),
                Text('Số nét: ${kanji.strokeCount}',
                    style: TextStyle(fontSize: 16)),
              ],
            ),
            trailing: IconButton(
              icon: Icon(isSaved ? Icons.bookmark : Icons.bookmark_border,
                  color: isSaved ? Colors.blue : Colors.grey),
              onPressed: () => toggleSave(kanji.kanji),
            ),
          ),
        );
      },
    );
  }
}
