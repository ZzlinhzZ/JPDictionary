import 'package:flutter/material.dart';
import '../models/KanjiModel.dart';

class KanjiScreen extends StatelessWidget {
  final List<Kanji> kanjiList;

  KanjiScreen({required this.kanjiList});

  @override
  Widget build(BuildContext context) {
    if (kanjiList.isEmpty) {
      return Center(child: Text("Không tìm thấy hán tự.", style: TextStyle(fontSize: 18)));
    }

    return ListView.builder(
      padding: EdgeInsets.all(8),
      itemCount: kanjiList.length,
      itemBuilder: (context, index) {
        final kanji = kanjiList[index];
        return Card(
          elevation: 3,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ListTile(
            contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            title: Text(kanji.kanji, style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 4),
                Text('Nghĩa: ${kanji.meanings}', style: TextStyle(fontSize: 16)),
                SizedBox(height: 4),
                Text('Âm Kun: ${kanji.kunReadings}', style: TextStyle(fontSize: 16)),
                Text('Âm On: ${kanji.onReadings}', style: TextStyle(fontSize: 16)),
                Text('Số nét: ${kanji.strokeCount}', style: TextStyle(fontSize: 16)),
              ],
            ),
          ),
        );
      },
    );
  }
}
