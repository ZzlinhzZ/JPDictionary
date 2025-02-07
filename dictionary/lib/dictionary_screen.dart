import 'package:flutter/material.dart';
import 'database_helper.dart';
import 'models/KanjiModel.dart';
import 'models/WordModel.dart';
// import 'vocabulary_screen.dart';
// import 'kanji_screen.dart';
// import 'my_kanji_screen.dart';
class DictionaryScreen extends StatefulWidget {
  @override
  _DictionaryScreenState createState() => _DictionaryScreenState();
}

class _DictionaryScreenState extends State<DictionaryScreen> {
  DatabaseHelper dbHelper = DatabaseHelper();
  Word? exactMatch;
  List<Kanji> kanjiDetails = [];
  TextEditingController searchController = TextEditingController();

  void search() async {
    final query = searchController.text.trim();
    if (query.isEmpty) return;

    final word = await dbHelper.getExactWordMatch(query);
    final kanjiList = await dbHelper.getKanjiFromWord(query);

    setState(() {
      exactMatch = word;
      kanjiDetails = kanjiList;
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Từ điển tiếng Nhật'),
          bottom: TabBar(
            tabs: [
              Tab(text: "Từ vựng"),
              Tab(text: "Hán tự"),
              Tab(text: "Kanji của tôi"),
            ],
          ),
        ),
        body: Column(
          children: [
            Padding(
              padding: EdgeInsets.all(8.0),
              child: TextField(
                controller: searchController,
                decoration: InputDecoration(
                  labelText: 'Nhập từ cần tra...',
                  border: OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: Icon(Icons.search),
                    onPressed: search,
                  ),
                ),
                onSubmitted: (_) => search(),
              ),
            ),
            Expanded(
              child: TabBarView(
                children: [
                  VocabularyScreen(word: exactMatch),
                  KanjiScreen(kanjiList: kanjiDetails),
                  MyKanjiScreen(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
class VocabularyScreen extends StatelessWidget {
  final Word? word;

  VocabularyScreen({this.word});

  @override
  Widget build(BuildContext context) {
    if (word == null) {
      return Center(child: Text("Không tìm thấy từ vựng."));
    }

    return Card(
      margin: EdgeInsets.all(16),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(word!.written, style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Text('Cách đọc: ${word!.pronounced}', style: TextStyle(fontSize: 18)),
            SizedBox(height: 8),
            Text('Nghĩa: ${word!.glosses}', style: TextStyle(fontSize: 18)),
          ],
        ),
      ),
    );
  }
}
class KanjiScreen extends StatelessWidget {
  final List<Kanji> kanjiList;

  KanjiScreen({required this.kanjiList});

  @override
  Widget build(BuildContext context) {
    if (kanjiList.isEmpty) {
      return Center(child: Text("Không tìm thấy hán tự."));
    }

    return ListView.builder(
      itemCount: kanjiList.length,
      itemBuilder: (context, index) {
        final kanji = kanjiList[index];
        return Card(
          margin: EdgeInsets.all(8),
          child: ListTile(
            title: Text(kanji.kanji, style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Nghĩa: ${kanji.meanings}'),
                Text('Âm Kun: ${kanji.kunReadings}'),
                Text('Âm On: ${kanji.onReadings}'),
                Text('Số nét: ${kanji.strokeCount}'),
              ],
            ),
            trailing: IconButton(
              icon: Icon(Icons.bookmark_border),
              onPressed: () {
                // Thêm vào Kanji của tôi
              },
            ),
          ),
        );
      },
    );
  }
}
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
