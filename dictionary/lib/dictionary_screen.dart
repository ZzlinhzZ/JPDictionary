import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'services/api_service.dart';
import 'models/word_model.dart';
import 'models/kanji_model.dart';
import 'screens/vocabulary_screen.dart';
import 'screens/kanji_screen.dart';
import 'screens/my_kanji_screen.dart';

class DictionaryScreen extends StatefulWidget {
  @override
  _DictionaryScreenState createState() => _DictionaryScreenState();
}

class _DictionaryScreenState extends State<DictionaryScreen> {
  ApiService apiService = ApiService();
  List<Word> wordResults = [];
  List<Kanji> kanjiResults = [];
  TextEditingController searchController = TextEditingController();

void search(String query) async {
  if (query.isEmpty) {
    setState(() {
      wordResults.clear();
      kanjiResults.clear();
    });
    return;
  }

  try {
    // Gửi từ khóa vào API để tìm kiếm
    List<Word> words = await apiService.getWords(query);
    List<Kanji> kanji = await apiService.getKanji(query);

    setState(() {
      wordResults = words;
      kanjiResults = kanji;
    });
  } catch (e) {
    _showErrorDialog("Lỗi kết nối API: $e");
  }
}


  void checkApiConnection() async {
    try {
      final response = await http.get(Uri.parse("${ApiService.baseUrl}/words?search=test"));
      if (response.statusCode == 200) {
        _showSuccessDialog("API kết nối thành công!");
      } else {
        _showErrorDialog("Lỗi: API phản hồi với mã trạng thái ${response.statusCode}");
      }
    } catch (e) {
      _showErrorDialog("Không thể kết nối API: $e");
    }
  }

  void _showSuccessDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Thành công"),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("OK"),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Lỗi"),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("OK"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: searchController,
                      onChanged: search,
                      onSubmitted: (query){
                        search(query);
                      },
                      decoration: InputDecoration(
                        hintText: "Nhập từ khóa...",
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        prefixIcon: Icon(Icons.search),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.wifi),
                    onPressed: checkApiConnection, // Nút kiểm tra API
                  ),
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
                          VocabularyScreen(words: wordResults),
                          // KanjiScreen(kanjiList: kanjiResults),
                          // KanjiScreen(kanjiList: kanjiResults, searchQuery: searchController.text),
                            KanjiScreen(kanjiList: kanjiResults, searchQuery: searchController.text),
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
