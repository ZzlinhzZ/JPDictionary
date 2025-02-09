import 'package:flutter/material.dart';
import '../models/WordModel.dart';
import '../database_helper.dart';

class VocabularyScreen extends StatefulWidget {
  final List<Word> words;

  VocabularyScreen({required this.words});

  @override
  _VocabularyScreenState createState() => _VocabularyScreenState();
}

class _VocabularyScreenState extends State<VocabularyScreen> {
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
    if (widget.words.isEmpty) {
      return Center(
          child:
              Text("Không tìm thấy từ vựng.", style: TextStyle(fontSize: 18)));
    }

    Map<String, Set<String>> wordMap = {};
    Map<String, String> wordMeanings = {};

    for (var word in widget.words) {
      if (!wordMap.containsKey(word.written)) {
        wordMap[word.written] = {};
        wordMeanings[word.written] = word.glosses;
      }
      wordMap[word.written]!.add(word.pronounced);
    }

    return ListView(
      padding: EdgeInsets.all(8),
      children: wordMap.entries.map((entry) {
        String written = entry.key;
        String readings = entry.value.join(" | ");
        String glosses = wordMeanings[written] ?? "";
        bool isSaved = savedKanji.contains(written);

        return Card(
          elevation: 3,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ListTile(
            contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            title: Text(written,
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 4),
                Text('Cách đọc: $readings',
                    style: TextStyle(fontSize: 16, color: Colors.blueAccent)),
                SizedBox(height: 4),
                Text('Nghĩa: $glosses', style: TextStyle(fontSize: 16)),
              ],
            ),
            trailing: IconButton(
              icon: Icon(isSaved ? Icons.bookmark : Icons.bookmark_border,
                  color: isSaved ? Colors.blue : Colors.grey),
              onPressed: () => toggleSave(written),
            ),
          ),
        );
      }).toList(),
    );
  }
}
