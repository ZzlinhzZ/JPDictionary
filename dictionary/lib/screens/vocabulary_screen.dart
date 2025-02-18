import 'package:flutter/material.dart';
import '../models/word_model.dart';

class VocabularyScreen extends StatelessWidget {
  final List<Word> words;

  VocabularyScreen({required this.words});

  @override
  Widget build(BuildContext context) {
    if (words.isEmpty) {
      return Center(child: Text("Không tìm thấy từ vựng.", style: TextStyle(fontSize: 18)));
    }

    return ListView.builder(
      padding: EdgeInsets.all(8),
      itemCount: words.length,
      itemBuilder: (context, index) {
        final word = words[index];
        return Card(
          elevation: 3,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ListTile(
            contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            title: Text(
              word.written, 
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, fontFamily: 'NotoSansCJK'),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.hearing, color: Colors.blueAccent, size: 18),
                    SizedBox(width: 4),
                    Text('Cách đọc: ${word.pronounced}', style: TextStyle(fontSize: 16, color: Colors.blueAccent)),
                  ],
                ),
                SizedBox(height: 4),
                Text('Nghĩa: ${word.glosses}', style: TextStyle(fontSize: 16)),
              ],
            ),
          ),
        );
      },
    );
  }
}
