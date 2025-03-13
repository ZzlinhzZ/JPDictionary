import 'package:flutter/material.dart';
import '../models/kanji_model.dart';
import '../services/api_service.dart';
import 'login_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class KanjiScreen extends StatefulWidget {
  final List<Kanji> kanjiList;
  final String searchQuery;

  KanjiScreen({required this.kanjiList, required this.searchQuery});

  @override
  _KanjiScreenState createState() => _KanjiScreenState();
}

class _KanjiScreenState extends State<KanjiScreen> {
  ApiService apiService = ApiService();
  Set<String> savedKanji = {}; // Lưu danh sách các kanji đã lưu
  String? username;

  @override
  void initState() {
    super.initState();
    checkLoginStatus();
    loadSavedKanji();
  }

  Future<void> checkLoginStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      username = prefs.getString("username");
    });
  }

  void loadSavedKanji() async {
    List<Map<String, dynamic>> savedKanjiList =
        await apiService.getSavedKanji();
    setState(() {
      savedKanji =
          savedKanjiList.map((kanji) => kanji['kanji'] as String).toSet();
    });
  }

  void toggleSaveKanji(Kanji kanji) async {
    if (username == null) {
      bool? result = await Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => LoginScreen()),
      );
      if (result == true) {
        checkLoginStatus();
      }
      return;
    }
    if (savedKanji.contains(kanji.kanji)) {
      await apiService.removeKanji(kanji.kanji);
      setState(() {
        savedKanji.remove(kanji.kanji);
      });
    } else {
      await apiService.saveKanji(
          kanji.kanji, kanji.kunReadings ?? "", kanji.meanings ?? "");
      setState(() {
        savedKanji.add(kanji.kanji);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    List<String> queryKanji = widget.searchQuery
        .split(''); // Chia từ khóa thành từng kanji riêng biệt
    final filteredKanjiList = widget.kanjiList.where((kanji) {
      return queryKanji.contains(kanji.kanji);
    }).toList();

    if (filteredKanjiList.isEmpty) {
      return Center(
          child:
              Text("Không tìm thấy hán tự.", style: TextStyle(fontSize: 18)));
    }

    return ListView.builder(
      padding: EdgeInsets.all(8),
      itemCount: filteredKanjiList.length,
      itemBuilder: (context, index) {
        final kanji = filteredKanjiList[index];
        final isSaved =
            savedKanji.contains(kanji.kanji); // Kiểm tra kanji đã lưu chưa

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
                Text('Nghĩa: ${kanji.meanings ?? "Không có"}'),
                Text('Âm Kun: ${kanji.kunReadings ?? "Không có"}'),
                Text('Âm On: ${kanji.onReadings ?? "Không có"}'),
                Text('Số nét: ${kanji.strokeCount}'),
              ],
            ),
            trailing: IconButton(
              icon: Icon(
                isSaved ? Icons.bookmark : Icons.bookmark_border,
                color: isSaved ? Colors.blueAccent : Colors.grey,
              ),
              onPressed: () {
                toggleSaveKanji(kanji);
              },
            ),
          ),
        );
      },
    );
  }
}
