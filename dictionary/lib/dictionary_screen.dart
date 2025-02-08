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

    // Lọc ra các từ `written` duy nhất để tránh trùng lặp trong kết quả tìm kiếm
    Set<String> uniqueWords = {};
    List<Word> filteredWords = [];
    for (var word in wordList) {
      if (!uniqueWords.contains(word.written)) {
        uniqueWords.add(word.written);
        filteredWords.add(word);
      }
    }

    wordList.sort((a, b) => (a.written == query ? 0 : 1).compareTo(b.written == query ? 0 : 1));
    kanjiList.sort((a, b) => (a.kanji == query ? 0 : 1).compareTo(b.kanji == query ? 0 : 1));

    setState(() {
      kanjiResults = kanjiList;
      wordResults = filteredWords; // Sử dụng danh sách đã lọc
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
