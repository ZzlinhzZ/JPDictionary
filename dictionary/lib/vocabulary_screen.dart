// class VocabularyScreen extends StatelessWidget {
//   final Word? word;

//   VocabularyScreen({this.word});

//   @override
//   Widget build(BuildContext context) {
//     if (word == null) {
//       return Center(child: Text("Không tìm thấy từ vựng."));
//     }

//     return Card(
//       margin: EdgeInsets.all(16),
//       child: Padding(
//         padding: EdgeInsets.all(16),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Text(word!.written, style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
//             SizedBox(height: 8),
//             Text('Cách đọc: ${word!.pronounced}', style: TextStyle(fontSize: 18)),
//             SizedBox(height: 8),
//             Text('Nghĩa: ${word!.glosses}', style: TextStyle(fontSize: 18)),
//           ],
//         ),
//       ),
//     );
//   }
// }
