import 'package:flutter/material.dart';
import '../database_helper.dart';
import '../models/WordModel.dart';

class MyKanjiScreen extends StatefulWidget {
  @override
  _MyKanjiScreenState createState() => _MyKanjiScreenState();
}

class _MyKanjiScreenState extends State<MyKanjiScreen> {
  List<Word> savedWords = [];
  bool showPronunciation = true;
  bool showMeaning = true;

  @override
  void initState() {
    super.initState();
    loadSavedKanji();
  }

  void loadSavedKanji() async {
    final dbHelper = DatabaseHelper();
    final savedList = await dbHelper.getSavedKanji();

    setState(() {
      savedWords = savedList
          .map((kanji) => Word(
                id: kanji.id ?? 0,
                written: kanji.kanji,
                pronounced: kanji.pronounced,
                glosses: kanji.meaning,
                kanji: '',
              ))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Thanh chọn checkbox
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Checkbox(
                value: showPronunciation,
                onChanged: (value) {
                  setState(() {
                    showPronunciation = value!;
                  });
                },
              ),
              Text("Cách đọc"),
              SizedBox(width: 20),
              Checkbox(
                value: showMeaning,
                onChanged: (value) {
                  setState(() {
                    showMeaning = value!;
                  });
                },
              ),
              Text("Ý nghĩa"),
            ],
          ),
        ),
        // Danh sách Kanji đã lưu
        Expanded(
          child: ListView.builder(
            itemCount: savedWords.length,
            itemBuilder: (context, index) {
              final word = savedWords[index];

              return Card(
                margin: EdgeInsets.all(8),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Hiển thị Kanji
                      Text(
                        word.written,
                        style: TextStyle(
                            fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      // Hiển thị cách đọc (nếu được chọn)
                      if (showPronunciation)
                        Text(
                          '「${word.pronounced}」',
                          style:
                              TextStyle(fontSize: 18, color: Colors.blueAccent),
                        ),
                      // Hiển thị nghĩa (nếu được chọn)
                      if (showMeaning)
                        Text(
                          word.glosses,
                          style: TextStyle(fontSize: 16),
                        ),
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
