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
  List<String> _recognizedKanji = []; // Danh sách kết quả nhận diện

  void _clearCanvas() {
    setState(() {
      _points.clear();
      _recognizedKanji.clear(); // Xóa kết quả nhận diện khi xóa canvas
    });
  }

  Future<void> _sendToAPI() async {
    if (_points.isEmpty) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // Chuyển canvas thành ảnh PNG
      RenderRepaintBoundary boundary = _canvasKey.currentContext!
          .findRenderObject() as RenderRepaintBoundary;
      ui.Image image = await boundary.toImage();
      ByteData? byteData = await _convertToWhiteBackground(image);
      Uint8List pngBytes = byteData!.buffer.asUint8List();

      // Gửi ảnh đến API để nhận diện
      List<String> recognizedKanji = await apiService.recognizeKanji(pngBytes);

      setState(() {
        _recognizedKanji = recognizedKanji; // Cập nhật kết quả nhận diện
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error recognizing Kanji: $e")),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<ByteData?> _convertToWhiteBackground(ui.Image image) async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(
      recorder,
      Rect.fromLTWH(0, 0, image.width.toDouble(), image.height.toDouble()),
    );

    // Vẽ nền trắng
    Paint whitePaint = Paint()..color = Colors.white;
    canvas.drawRect(
      Rect.fromLTWH(0, 0, image.width.toDouble(), image.height.toDouble()),
      whitePaint,
    );

    // Vẽ lại ảnh gốc (nét đen)
    Paint paint = Paint();
    canvas.drawImage(image, Offset.zero, paint);

    final newImage =
        await recorder.endRecording().toImage(image.width, image.height);
    return await newImage.toByteData(format: ui.ImageByteFormat.png);
  }

  void _undoLastStroke() {
    if (_points.isEmpty) return;

    setState(() {
      int lastNullIndex = _points.lastIndexOf(null);

      if (lastNullIndex != -1) {
        _points.removeRange(lastNullIndex, _points.length);

        if (lastNullIndex > 0) {
          int previousNullIndex =
              _points.sublist(0, lastNullIndex).lastIndexOf(null);
          int startIndex =
              (previousNullIndex != -1) ? previousNullIndex + 1 : 0;
          _points.removeRange(startIndex, lastNullIndex);
        }
      } else {
        _points.clear();
      }
    });

    // Đảm bảo UI đã được cập nhật trước khi gửi ảnh lên server
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _sendToAPI();
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("Draw Kanji"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Hiển thị kết quả nhận diện
          if (_recognizedKanji.isNotEmpty)
            Wrap(
              children: _recognizedKanji.map((kanji) {
                return GestureDetector(
                  onTap: () {
                    widget.onKanjiRecognized(
                        kanji); // Gọi callback khi chọn Kanji
                  },
                  child: Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(kanji, style: TextStyle(fontSize: 24)),
                  ),
                );
              }).toList(),
            ),
          SizedBox(height: 10),
          RepaintBoundary(
            key: _canvasKey,
            child: Container(
              width: 300,
              height: 300,
              decoration:
                  BoxDecoration(border: Border.all(color: Colors.black)),
              child: GestureDetector(
                onPanUpdate: (details) {
                  RenderBox renderBox = _canvasKey.currentContext!
                      .findRenderObject() as RenderBox;
                  Offset localPosition =
                      renderBox.globalToLocal(details.globalPosition);
                  setState(() {
                    _points.add(localPosition);
                  });
                },
                onPanEnd: (details) {
                  setState(() {
                    _points.add(null); // Kết thúc nét vẽ
                  });
                  _sendToAPI(); // Gửi ảnh lên server khi kết thúc nét vẽ
                },
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
                      child: Text("Delete"),
                    ),
                    SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: _undoLastStroke,
                      child: Text("Undo"),
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
