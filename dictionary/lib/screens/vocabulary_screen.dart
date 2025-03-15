import 'package:flutter/material.dart';
import '../models/word_model.dart';
import '../services/api_service.dart';
import 'auth_screen.dart';

class VocabularyScreen extends StatefulWidget {
  final List<Word> words;
  final ApiService apiService = ApiService();

  VocabularyScreen({required this.words});

  @override
  _VocabularyScreenState createState() => _VocabularyScreenState();
}

class _VocabularyScreenState extends State<VocabularyScreen> {
  Set<String> savedWords = {}; // Lưu danh sách các từ đã lưu

  @override
  void initState() {
    super.initState();
    loadSavedWords();
  }

  void loadSavedWords() async {
    List<Map<String, dynamic>> savedKanjiList =
        await widget.apiService.getSavedKanji();
    setState(() {
      savedWords =
          savedKanjiList.map((word) => word['kanji'] as String).toSet();
    });
  }

  void toggleSaveWord(String written, String pronounced, String meaning) async {
    final isLoggedIn = await widget.apiService.isLoggedIn();
    if (!isLoggedIn) {
      _showLoginRequiredDialog();
      return;
    }

    try {
      if (savedWords.contains(written)) {
        await widget.apiService.removeKanji(written);
        setState(() => savedWords.remove(written));
      } else {
        await widget.apiService.saveKanji(written, pronounced, meaning);
        setState(() => savedWords.add(written));
      }
    } catch (e) {
      _showErrorDialog(e.toString());
    }
  }

  void _showLoginRequiredDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Yêu cầu đăng nhập"),
        content: Text("Bạn cần đăng nhập để sử dụng tính năng này"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Hủy"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => AuthScreen()),
              );
            },
            child: Text("Đăng nhập"),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Lỗi"),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("OK"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.words.isEmpty) {
      return Center(
        child: Text(
          "Not found the vocabulary.",
          style: TextStyle(fontSize: 18),
        ),
      );
    }

    Map<String, Map<String, dynamic>> groupedWords = {};

    for (var word in widget.words) {
      if (!groupedWords.containsKey(word.written)) {
        groupedWords[word.written] = {
          'pronounced': <String>{},
          'meaning': word.glosses,
        };
      }
      groupedWords[word.written]!['pronounced'].add(word.pronounced);
    }

    final uniqueWords = groupedWords.entries.map((entry) {
      return {
        'written': entry.key,
        'pronounced': (entry.value['pronounced'] as Set<String>).join(" | "),
        'meaning': entry.value['meaning'],
      };
    }).toList();

    return ListView.builder(
      padding: EdgeInsets.all(8),
      itemCount: uniqueWords.length,
      itemBuilder: (context, index) {
        final word = uniqueWords[index];
        final isSaved =
            savedWords.contains(word['written']); // Kiểm tra từ đã lưu chưa

        return Card(
          elevation: 3,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ListTile(
            contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            title: Text(
              word['written']!,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.hearing, color: Colors.blueAccent, size: 18),
                    SizedBox(width: 4),
                    Text(
                      'Pronounced: ${word['pronounced']}',
                      style: TextStyle(fontSize: 16, color: Colors.blueAccent),
                    ),
                  ],
                ),
                SizedBox(height: 4),
                Text(
                  'Meaning: ${word['meaning']}',
                  style: TextStyle(fontSize: 16),
                ),
              ],
            ),
            trailing: IconButton(
              icon: Icon(
                isSaved ? Icons.bookmark : Icons.bookmark_border,
                color: isSaved ? Colors.blueAccent : Colors.grey,
              ),
              onPressed: () {
                toggleSaveWord(
                    word['written']!, word['pronounced']!, word['meaning']!);
              },
            ),
          ),
        );
      },
    );
  }
}
