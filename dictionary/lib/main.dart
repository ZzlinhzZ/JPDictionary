import 'package:flutter/material.dart';
import 'database_helper.dart';
import 'models/KanjiModel.dart';
import 'models/WordModel.dart';
import 'dictionary_screen.dart';
void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: DictionaryScreen(),
    );
  }
}

// class DictionaryScreen extends StatefulWidget {
//   @override
//   _DictionaryScreenState createState() => _DictionaryScreenState();
// }

// class _DictionaryScreenState extends State<DictionaryScreen> {
//   DatabaseHelper dbHelper = DatabaseHelper();
//   List<Kanji> kanjiResults = [];
//   List<Word> wordResults = [];
//   TextEditingController searchController = TextEditingController();

//   void search(String query) async {
//     final kanjiList = await dbHelper.getKanjiList(query);
//     final wordList = await dbHelper.getWordList(query);
//     setState(() {
//       kanjiResults = kanjiList;
//       wordResults = wordList;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text('Từ điển tiếng Nhật')),
//       body: Column(
//         children: [
//           Padding(
//             padding: EdgeInsets.all(8.0),
//             child: TextField(
//               controller: searchController,
//               decoration: InputDecoration(
//                 labelText: 'Nhập từ cần tra...',
//                 border: OutlineInputBorder(),
//               ),
//               onChanged: search,
//             ),
//           ),
//           Expanded(
//             child: ListView(
//               children: [
//                 if (kanjiResults.isNotEmpty) ...[
//                   ListTile(title: Text('Kanji')),
//                   ...kanjiResults.map((kanji) => ListTile(
//                         title: Text(kanji.kanji, style: TextStyle(fontSize: 24)),
//                         subtitle: Text('Ý nghĩa: ${kanji.meanings}'),
//                       )),
//                 ],
//                 if (wordResults.isNotEmpty) ...[
//                   ListTile(title: Text('Từ vựng')),
//                   ...wordResults.map((word) => ListTile(
//                         title: Text(word.written),
//                         subtitle: Text('${word.pronounced} - ${word.glosses}'),
//                       )),
//                 ],
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
