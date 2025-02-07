import 'package:flutter/material.dart';
import 'database_helper.dart';
import 'models/KanjiModel.dart';
import 'models/WordModel.dart';
// import 'vocabulary_screen.dart';
// import 'kanji_screen.dart';
// import 'my_kanji_screen.dart';
import '../screens/vocabulary_screen.dart';
import '../screens/kanji_screen.dart';
import '../screens/my_kanji_screen.dart';

class DictionaryScreen extends StatefulWidget {
  @override
  _DictionaryScreenState createState() => _DictionaryScreenState();
}

class _DictionaryScreenState extends State<DictionaryScreen> {
  DatabaseHelper dbHelper = DatabaseHelper();
  List<Kanji> kanjiResults = [];
  List<Word> wordResults = [];
  List<Word> selectedWords = [];
  List<Kanji> selectedKanjiList = [];
  TextEditingController searchController = TextEditingController();
  bool isSearching = false;

  void search(String query) async {
    if (query.isEmpty) {
      setState(() {
        kanjiResults.clear();
        wordResults.clear();
        isSearching = false;
      });
      return;
    }

    final wordList = await dbHelper.getWordList(query);
    final kanjiList = await dbHelper.getKanjiList(query);

    wordList.sort((a, b) => (a.written == query ? 0 : 1).compareTo(b.written == query ? 0 : 1));
    kanjiList.sort((a, b) => (a.kanji == query ? 0 : 1).compareTo(b.kanji == query ? 0 : 1));

    setState(() {
      kanjiResults = kanjiList;
      wordResults = wordList;
      isSearching = true;
    });
  }

  void handleSelection(dynamic item) async {
    if (item is Word) {
      final words = wordResults.where((w) => w.written == item.written).toList();
      final kanjiList = <Kanji>[];

      for (var char in item.written.split('')) {
        final kanji = await dbHelper.getKanjiList(char);
        if (kanji.isNotEmpty) {
          kanjiList.addAll(kanji);
        }
      }

      setState(() {
        selectedWords = words;
        selectedKanjiList = kanjiList;
        searchController.text = item.written;
        isSearching = false;
      });
    }
  }

  void handleEnterPressed() {
    if (wordResults.isNotEmpty) {
      handleSelection(wordResults.first);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.all(8.0),
              child: TextField(
                controller: searchController,
                onChanged: search,
                onSubmitted: (_) => handleEnterPressed(),
                decoration: InputDecoration(
                  hintText: "Nhập từ khóa...",
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  prefixIcon: Icon(Icons.search),
                  suffixIcon: searchController.text.isNotEmpty
                      ? IconButton(
                          icon: Icon(Icons.clear),
                          onPressed: () {
                            searchController.clear();
                            search('');
                          },
                        )
                      : null,
                ),
              ),
            ),
            if (isSearching && (kanjiResults.isNotEmpty || wordResults.isNotEmpty))
              Container(
                height: 200, // Giới hạn chiều cao danh sách kết quả
                child: ListView(
                  shrinkWrap: true,
                  children: [
                    if (wordResults.isNotEmpty) ...[
                      ListTile(
                        title: Text("Từ vựng", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      ),
                      ...wordResults.map(
                        (word) => ListTile(
                          title: Text(word.written, style: TextStyle(fontSize: 20)),
                          subtitle: Text(word.glosses),
                          onTap: () => handleSelection(word),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            Expanded(
              child: DefaultTabController(
                length: 3,
                child: Column(
                  children: [
                    TabBar(
                      tabs: [
                        Tab(text: "Từ vựng"),
                        Tab(text: "Hán tự"),
                        Tab(text: "Kanji của tôi"),
                      ],
                    ),
                    Expanded(
                      child: TabBarView(
                        children: [
                          VocabularyScreen(words: selectedWords),
                          KanjiScreen(kanjiList: selectedKanjiList),
                          MyKanjiScreen(),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// class VocabularyScreen extends StatelessWidget {
//   final Word? word;

//   VocabularyScreen({this.word});

//   @override
//   Widget build(BuildContext context) {
//     if (word == null) {
//       return Center(child: Text("Không tìm thấy từ vựng."));
//     }

//     return Card(
//       margin: EdgeInsets.all(16),
//       child: Padding(
//         padding: EdgeInsets.all(16),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Text(word!.written, style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
//             SizedBox(height: 8),
//             Text('Cách đọc: ${word!.pronounced}', style: TextStyle(fontSize: 18)),
//             SizedBox(height: 8),
//             Text('Nghĩa: ${word!.glosses}', style: TextStyle(fontSize: 18)),
//           ],
//         ),
//       ),
//     );
//   }
// }
// class KanjiScreen extends StatelessWidget {
//   final List<Kanji> kanjiList;

//   KanjiScreen({required this.kanjiList});

//   @override
//   Widget build(BuildContext context) {
//     if (kanjiList.isEmpty) {
//       return Center(child: Text("Không tìm thấy hán tự."));
//     }

//     return ListView.builder(
//       itemCount: kanjiList.length,
//       itemBuilder: (context, index) {
//         final kanji = kanjiList[index];
//         return Card(
//           margin: EdgeInsets.all(8),
//           child: ListTile(
//             title: Text(kanji.kanji, style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
//             subtitle: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text('Nghĩa: ${kanji.meanings}'),
//                 Text('Âm Kun: ${kanji.kunReadings}'),
//                 Text('Âm On: ${kanji.onReadings}'),
//                 Text('Số nét: ${kanji.strokeCount}'),
//               ],
//             ),
//             trailing: IconButton(
//               icon: Icon(Icons.bookmark_border),
//               onPressed: () {
//                 // Thêm vào Kanji của tôi
//               },
//             ),
//           ),
//         );
//       },
//     );
//   }
// }
// class MyKanjiScreen extends StatefulWidget {
//   @override
//   _MyKanjiScreenState createState() => _MyKanjiScreenState();
// }

// class _MyKanjiScreenState extends State<MyKanjiScreen> {
//   List<String> savedKanji = [];

//   void loadSavedKanji() async {
//     final db = await DatabaseHelper().database;
//     final res = await db.query('saved_kanji');
//     setState(() {
//       savedKanji = res.map((e) => e['kanji'] as String).toList();
//     });
//   }

//   @override
//   void initState() {
//     super.initState();
//     loadSavedKanji();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return ListView.builder(
//       itemCount: savedKanji.length,
//       itemBuilder: (context, index) {
//         return Card(
//           margin: EdgeInsets.all(8),
//           child: ListTile(
//             title: Text(savedKanji[index], style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
//           ),
//         );
//       },
//     );
//   }
// }
