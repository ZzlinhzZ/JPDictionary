import 'package:flutter/material.dart';
import '../models/word_model.dart';
import '../services/api_service.dart';

class VocabularyScreen extends StatelessWidget {
  final List<Word> words;
  final ApiService apiService = ApiService();

  VocabularyScreen({required this.words});

  void _saveWord(String written, String pronounced, String meaning) async {
    await apiService.saveKanji(written, pronounced, meaning);
  }

  @override
  Widget build(BuildContext context) {
    if (words.isEmpty) {
      return Center(
        child: Text(
          "Không tìm thấy từ vựng.",
          style: TextStyle(fontSize: 18),
        ),
      );
    }

    // Nhóm từ vựng theo `written` và gom cách đọc lại
    Map<String, Map<String, dynamic>> groupedWords = {};

    for (var word in words) {
      if (!groupedWords.containsKey(word.written)) {
        groupedWords[word.written] = {
          'pronounced': <String>{}, // Dùng Set để loại bỏ trùng lặp
          'meaning': word.glosses,
        };
      }
      groupedWords[word.written]!['pronounced'].add(word.pronounced);
    }

    final uniqueWords = groupedWords.entries.map((entry) {
      return {
        'written': entry.key,
        'pronounced': (entry.value['pronounced'] as Set<String>).join(" | "), // Ghép cách đọc
        'meaning': entry.value['meaning'],
      };
    }).toList();

    return ListView.builder(
      padding: EdgeInsets.all(8),
      itemCount: uniqueWords.length,
      itemBuilder: (context, index) {
        final word = uniqueWords[index];

        return Card(
          elevation: 3,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ListTile(
            contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            title: Text(
              word['written']!,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, fontFamily: 'NotoSansCJK'),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.hearing, color: Colors.blueAccent, size: 18),
                    SizedBox(width: 4),
                    Text(
                      'Cách đọc: ${word['pronounced']}',
                      style: TextStyle(fontSize: 16, color: Colors.blueAccent),
                    ),
                  ],
                ),
                SizedBox(height: 4),
                Text(
                  'Nghĩa: ${word['meaning']}',
                  style: TextStyle(fontSize: 16),
                ),
              ],
            ),
            trailing: IconButton(
              icon: Icon(Icons.bookmark_border, color: Colors.blueAccent),
              onPressed: () {
                _saveWord(word['written']!, word['pronounced']!, word['meaning']!);
              },
            ),
          ),
        );
      },
    );
  }
}
