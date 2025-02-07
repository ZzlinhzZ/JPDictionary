import 'package:flutter/material.dart';
import '../models/WordModel.dart';

class VocabularyScreen extends StatelessWidget {
  final List<Word> words;

  VocabularyScreen({required this.words});

  @override
  Widget build(BuildContext context) {
    if (words.isEmpty) {
      return Center(child: Text("Không tìm thấy từ vựng.", style: TextStyle(fontSize: 18)));
    }

    // Gom nhóm cách đọc của từng từ và loại bỏ trùng lặp
    Map<String, Set<String>> wordMap = {};
    Map<String, String> wordMeanings = {};

    for (var word in words) {
      if (!wordMap.containsKey(word.written)) {
        wordMap[word.written] = {};
        wordMeanings[word.written] = word.glosses; // Lấy nghĩa từ dòng đầu tiên
      }
      wordMap[word.written]!.add(word.pronounced); // Thêm cách đọc vào Set để tránh trùng lặp
    }

    return ListView(
      padding: EdgeInsets.all(8),
      children: wordMap.entries.map((entry) {
        String written = entry.key;
        String readings = entry.value.join(" | "); // Nối cách đọc bằng '|'
        String glosses = wordMeanings[written] ?? "";

        return Card(
          elevation: 3,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(written, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                SizedBox(height: 8),
                Text('Cách đọc: $readings', style: TextStyle(fontSize: 16, color: Colors.blueAccent)),
                SizedBox(height: 8),
                Text('Nghĩa: $glosses', style: TextStyle(fontSize: 16)),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}
