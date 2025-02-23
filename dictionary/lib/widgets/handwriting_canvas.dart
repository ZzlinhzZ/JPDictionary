import 'dart:ui' as ui;
import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'package:flutter/rendering.dart';
// import 'dart:html' as html;

class HandwritingCanvas extends StatefulWidget {
  final Function(String) onKanjiRecognized;

  HandwritingCanvas({required this.onKanjiRecognized});

  @override
  _HandwritingCanvasState createState() => _HandwritingCanvasState();
}

class _HandwritingCanvasState extends State<HandwritingCanvas> {
  List<Offset?> _points = [];
  GlobalKey _canvasKey = GlobalKey();
  bool _isLoading = false;
  final ApiService apiService = ApiService();

  void _clearCanvas() {
    setState(() {
      _points.clear();
    });
  }

Future<void> _saveAndSendToAPI() async {
  setState(() {
    _isLoading = true;
  });

  RenderRepaintBoundary boundary =
      _canvasKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
  ui.Image image = await boundary.toImage();
  ByteData? byteData = await _convertToWhiteBackground(image);
  Uint8List pngBytes = byteData!.buffer.asUint8List();

  // Tải ảnh xuống trình duyệt
  // final blob = html.Blob([pngBytes]);
  // final url = html.Url.createObjectUrlFromBlob(blob);
  // final anchor = html.AnchorElement(href: url)
  //   ..setAttribute("download", "kanji_drawing.png")
  //   ..click();
  // html.Url.revokeObjectUrl(url);

  // print("🖼 Ảnh đã tải xuống: kanji_drawing.png");

  //  Gửi ảnh đến API để nhận diện
  List<String> recognizedKanji = await apiService.recognizeKanji(pngBytes);

  setState(() {
    _isLoading = false;
  });

  _showKanjiOptions(recognizedKanji);
}

Future<ByteData?> _convertToWhiteBackground(ui.Image image) async {
  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder, Rect.fromLTWH(0, 0, image.width.toDouble(), image.height.toDouble()));

  //  Vẽ nền trắng
  Paint whitePaint = Paint()..color = Colors.white;
  canvas.drawRect(Rect.fromLTWH(0, 0, image.width.toDouble(), image.height.toDouble()), whitePaint);

  // Vẽ lại ảnh gốc (nét đen)
  Paint paint = Paint();
  canvas.drawImage(image, Offset.zero, paint);

  final newImage = await recorder.endRecording().toImage(image.width, image.height);
  return await newImage.toByteData(format: ui.ImageByteFormat.png);
}

  void _showKanjiOptions(List<String> kanjiList) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Chọn Kanji"),
        content: Wrap(
          children: kanjiList.map((kanji) {
            return GestureDetector(
              onTap: () {
                widget.onKanjiRecognized(kanji);
                Navigator.pop(context);
                Navigator.pop(context);
              },
              child: Padding(
                padding: EdgeInsets.all(8.0),
                child: Text(kanji, style: TextStyle(fontSize: 24)),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("Vẽ Kanji"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          RepaintBoundary(
            key: _canvasKey,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(border: Border.all(color: Colors.black)),
              child: GestureDetector(
                onPanUpdate: (details) {
                  RenderBox renderBox =
                      _canvasKey.currentContext!.findRenderObject() as RenderBox;
                  Offset localPosition =
                      renderBox.globalToLocal(details.globalPosition);
                  setState(() {
                    _points.add(localPosition);
                  });
                },
                onPanEnd: (details) => _points.add(null),
                child: CustomPaint(
                  painter: _KanjiPainter(_points),
                  size: Size(300, 300),
                ),
              ),
            ),
          ),
          SizedBox(height: 10),
          _isLoading
              ? CircularProgressIndicator()
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: _clearCanvas,
                      child: Text("Xóa"),
                    ),
                    SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: _saveAndSendToAPI,
                      child: Text("Gửi"),
                    ),
                  ],
                ),
        ],
      ),
    );
  }
}

class _KanjiPainter extends CustomPainter {
  List<Offset?> points;

  _KanjiPainter(this.points);

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = Colors.black
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 5.0;

    for (int i = 0; i < points.length - 1; i++) {
      if (points[i] != null && points[i + 1] != null) {
        canvas.drawLine(points[i]!, points[i + 1]!, paint);
      }
    }
  }

  @override
  bool shouldRepaint(_KanjiPainter oldDelegate) => true;
}
