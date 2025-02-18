import 'package:flutter/material.dart';
import '../services/api_service.dart';

class MyKanjiScreen extends StatefulWidget {
  @override
  _MyKanjiScreenState createState() => _MyKanjiScreenState();
}

class _MyKanjiScreenState extends State<MyKanjiScreen> {
  ApiService apiService = ApiService();
  List<String> savedKanji = [];

  @override
  void initState() {
    super.initState();
    loadSavedKanji();
  }

  void loadSavedKanji() async {
    List<String> kanjiList = await apiService.getSavedKanji();
    setState(() {
      savedKanji = kanjiList;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (savedKanji.isEmpty) {
      return Center(child: Text("Chưa có kanji nào được lưu.", style: TextStyle(fontSize: 18)));
    }

    return ListView.builder(
      itemCount: savedKanji.length,
      itemBuilder: (context, index) {
        return Card(
          elevation: 3,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ListTile(
            contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            title: Text(savedKanji[index], style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
          ),
        );
      },
    );
  }
}
