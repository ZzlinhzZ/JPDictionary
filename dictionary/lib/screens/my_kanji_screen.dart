import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'quiz_screen.dart';

class MyKanjiScreen extends StatefulWidget {
  @override
  _MyKanjiScreenState createState() => _MyKanjiScreenState();
}

class _MyKanjiScreenState extends State<MyKanjiScreen> {
  ApiService apiService = ApiService();
  List<Map<String, dynamic>> savedKanji = [];
  bool showPronounced = true;
  bool showMeaning = true;

  @override
  void initState() {
    super.initState();
    loadSavedKanji();
  }

  void loadSavedKanji() async {
    List<Map<String, dynamic>> kanjiList = await apiService.getSavedKanji();
    setState(() {
      savedKanji = kanjiList;
    });
  }

  void startQuiz() {
    if (savedKanji.isNotEmpty) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => QuizScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.all(8.0),
          child: ElevatedButton(
            onPressed: savedKanji.isNotEmpty ? startQuiz : null,
            child: Text("Start Quiz"),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Checkbox(
              value: showPronounced,
              onChanged: (value) {
                setState(() {
                  showPronounced = value!;
                });
              },
            ),
            Text("Show reading"),
            SizedBox(width: 16),
            Checkbox(
              value: showMeaning,
              onChanged: (value) {
                setState(() {
                  showMeaning = value!;
                });
              },
            ),
            Text("Show meaning"),
          ],
        ),
        Expanded(
          child: savedKanji.isEmpty
              ? Center(
                  child: Text("No kanji saved yet.",
                      style: TextStyle(fontSize: 18)))
              : ListView.builder(
                  itemCount: savedKanji.length,
                  itemBuilder: (context, index) {
                    final kanji = savedKanji[index];
                    return Card(
                      elevation: 3,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      child: ListTile(
                        contentPadding:
                            EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                        title: Text(kanji['kanji'],
                            style: TextStyle(
                                fontSize: 32, fontWeight: FontWeight.bold)),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (showPronounced)
                              Text('Pronouced: ${kanji['pronounced']}'),
                            if (showMeaning)
                              Text('Meaning: ${kanji['meaning']}'),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
