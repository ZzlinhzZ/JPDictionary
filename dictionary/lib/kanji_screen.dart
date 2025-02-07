// class KanjiScreen extends StatelessWidget {
//   final List<Kanji> kanjiList;

//   KanjiScreen({required this.kanjiList});

//   @override
//   Widget build(BuildContext context) {
//     if (kanjiList.isEmpty) {
//       return Center(child: Text("Không tìm thấy hán tự."));
//     }

//     return ListView.builder(
//       itemCount: kanjiList.length,
//       itemBuilder: (context, index) {
//         final kanji = kanjiList[index];
//         return Card(
//           margin: EdgeInsets.all(8),
//           child: ListTile(
//             title: Text(kanji.kanji, style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
//             subtitle: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text('Nghĩa: ${kanji.meanings}'),
//                 Text('Âm Kun: ${kanji.kunReadings}'),
//                 Text('Âm On: ${kanji.onReadings}'),
//                 Text('Số nét: ${kanji.strokeCount}'),
//               ],
//             ),
//             trailing: IconButton(
//               icon: Icon(Icons.bookmark_border),
//               onPressed: () {
//                 // Thêm vào Kanji của tôi
//               },
//             ),
//           ),
//         );
//       },
//     );
//   }
// }
