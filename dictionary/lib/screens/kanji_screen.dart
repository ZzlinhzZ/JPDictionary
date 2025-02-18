import 'package:flutter/material.dart';
import '../models/kanji_model.dart';

class KanjiScreen extends StatelessWidget {
  final List<Kanji> kanjiList;
  final String searchQuery;

  KanjiScreen({required this.kanjiList, required this.searchQuery});

  @override
  Widget build(BuildContext context) {
    // Tạo một danh sách các kanji từ searchQuery
    List<String> queryKanji = searchQuery.split(''); // Chia từ khóa thành từng kanji riêng biệt

    // Lọc danh sách kanji dựa trên việc kiểm tra các kanji trong searchQuery
    final filteredKanjiList = kanjiList.where((kanji) {
      // Kiểm tra nếu kanji có trong danh sách các kanji của searchQuery
      return queryKanji.contains(kanji.kanji);
    }).toList();

    if (filteredKanjiList.isEmpty) {
      return Center(child: Text("Không tìm thấy hán tự.", style: TextStyle(fontSize: 18)));
    }

    return ListView.builder(
      padding: EdgeInsets.all(8),
      itemCount: filteredKanjiList.length,
      itemBuilder: (context, index) {
        final kanji = filteredKanjiList[index];
        return Card(
          elevation: 3,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ListTile(
            contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
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
          ),
        );
      },
    );
  }
}
