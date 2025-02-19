import 'package:flutter/material.dart';
import '../services/api_service.dart';

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

  @override
  Widget build(BuildContext context) {
    if (savedKanji.isEmpty) {
      return Center(child: Text("Chưa có kanji nào được lưu.", style: TextStyle(fontSize: 18)));
    }

    return Column(
      children: [
        // Checkbox để bật/tắt hiển thị cách đọc và nghĩa
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
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
              Text("Hiển thị cách đọc"),
              SizedBox(width: 16),
              Checkbox(
                value: showMeaning,
                onChanged: (value) {
                  setState(() {
                    showMeaning = value!;
                  });
                },
              ),
              Text("Hiển thị nghĩa"),
            ],
          ),
        ),

        // Danh sách các từ đã lưu
        Expanded(
          child: ListView.builder(
            itemCount: savedKanji.length,
            itemBuilder: (context, index) {
              final kanji = savedKanji[index];
              return Card(
                elevation: 3,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  title: Text(kanji['kanji'], style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (showPronounced) 
                        Text('Cách đọc: ${kanji['pronounced']}', style: TextStyle(fontSize: 16, color: Colors.blueAccent)),
                      if (showMeaning) 
                        Text('Nghĩa: ${kanji['meaning']}', style: TextStyle(fontSize: 16)),
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
