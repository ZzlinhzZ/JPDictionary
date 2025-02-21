import 'dart:ui' as ui;
import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'package:flutter/rendering.dart';

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
  
  Future<void> _sendToAPI() async {
    setState(() {
      _isLoading = true;
    });

    // Chuyển canvas thành ảnh PNG
    RenderRepaintBoundary boundary = _canvasKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
    ui.Image image = await boundary.toImage();
    ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    Uint8List pngBytes = byteData!.buffer.asUint8List();
    
    // Gửi ảnh đến API
    // ApiService apiService = ApiService();
    List<String> recognizedKanji = await apiService.recognizeKanji(pngBytes);

    setState(() {
      _isLoading = false;
    });

    _showKanjiOptions(recognizedKanji);
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
                  setState(() {
                    RenderBox renderBox = context.findRenderObject() as RenderBox;
                    _points.add(renderBox.globalToLocal(details.globalPosition));
                  });
                },
                onPanEnd: (details) => _points.add(null),
                child: CustomPaint(
                  painter: _KanjiPainter(_points),
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
                      onPressed: _sendToAPI,
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
