import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'dart:math';

class QuizScreen extends StatefulWidget {
  @override
  _QuizScreenState createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  ApiService apiService = ApiService();
  List<Map<String, dynamic>> savedWords = [];
  List<Map<String, dynamic>> wrongAnswers = [];
  List<int> usedIndices = [];
  int? currentQuestionIndex;
  Map<String, dynamic>? currentQuestion;
  List<String> choices = [];
  int score = 0;
  bool showAnswer = false;
  String? selectedAnswer;

  @override
  void initState() {
    super.initState();
    loadSavedWords();
  }

  void loadSavedWords() async {
    List<Map<String, dynamic>> words = await apiService.getSavedKanji();
    setState(() {
      savedWords = words;
      if (savedWords.isNotEmpty) {
        generateQuestion();
      }
    });
  }

  void generateQuestion() {
    // Tạo danh sách index chưa dùng
    List<int> availableIndices = [];
    for (int i = 0; i < savedWords.length; i++) {
      if (!usedIndices.contains(i)) {
        availableIndices.add(i);
      }
    }

    if (availableIndices.isEmpty) {
      _showResultDialog();
      return;
    }

    final random = Random();
    int randomIndex = availableIndices[random.nextInt(availableIndices.length)];
    currentQuestionIndex = randomIndex;
    currentQuestion = savedWords[randomIndex];
    usedIndices.add(randomIndex);

    // Tạo các lựa chọn
    List<String> allMeanings =
        savedWords.map((word) => word['meaning'] as String).toList();
    allMeanings.remove(currentQuestion!['meaning']);

    List<String> wrongChoices = List.from(allMeanings)..shuffle();
    wrongChoices = wrongChoices.take(3).toList();

    choices = [...wrongChoices, currentQuestion!['meaning']];
    choices.shuffle();

    setState(() {
      showAnswer = false;
      selectedAnswer = null;
    });
  }

  void checkAnswer(String selected) {
    setState(() {
      showAnswer = true;
      selectedAnswer = selected;
      if (selected == currentQuestion!['meaning']) {
        score += 1;
      } else {
        wrongAnswers.add(currentQuestion!);
      }
    });
  }

  void nextQuestion() {
    if (usedIndices.length < savedWords.length) {
      generateQuestion();
    } else {
      _showResultDialog();
    }
  }

  void _showResultDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("End Quiz"),
        content: Text(
            "You answered  $score / ${usedIndices.length} questions correctly!"),
        actions: [
          if (wrongAnswers.isNotEmpty)
            TextButton(
              onPressed: () {
                // Tạo bản sao của wrongAnswers trước khi xóa
                final newQuizList =
                    List<Map<String, dynamic>>.from(wrongAnswers);

                setState(() {
                  savedWords = newQuizList; // Sử dụng bản sao
                  usedIndices.clear();
                  wrongAnswers.clear(); // Chỉ xóa sau khi đã copy
                  score = 0;
                });

                Navigator.pop(context);

                // Kiểm tra danh sách mới có dữ liệu không
                if (savedWords.isNotEmpty) {
                  generateQuestion();
                }
              },
              child: Text("Review the wrong sentence"),
            ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: Text("OK"),
          ),
        ],
      ),
    );
  }

  Color getButtonColor(String choice) {
    if (!showAnswer) return Colors.blueAccent;
    if (choice == currentQuestion!['meaning']) return Colors.green;
    if (choice == selectedAnswer) return Colors.red;
    return Colors.grey.shade400;
  }

  double getButtonOpacity(String choice) {
    if (!showAnswer) return 1.0;
    if (choice == selectedAnswer || choice == currentQuestion!['meaning']) {
      return 1.0;
    }
    return 0.5; // Làm mờ các đáp án không liên quan
  }

  @override
  Widget build(BuildContext context) {
    if (savedWords.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text("Quiz Practice")),
        body: Center(
            child: Text(
          "There are no words in the saved list!",
          style: TextStyle(fontSize: 18),
        )),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text("Quiz Practice")),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Question ${usedIndices.length} / ${savedWords.length}",
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue),
            ),
            SizedBox(height: 16),
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 6)],
              ),
              child: Column(
                children: [
                  Text(
                    "Kanji: ${currentQuestion!['kanji']}",
                    style: TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                        color: Colors.black),
                  ),
                  SizedBox(height: 10),
                  Text(
                    "Choose the correct meaning of this Kanji:",
                    style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  int crossAxisCount = constraints.maxWidth > 600 ? 4 : 2;

                  return GridView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: choices.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      mainAxisSpacing: 10,
                      crossAxisSpacing: 10,
                      childAspectRatio: 1, // Tỉ lệ kích thước nút
                    ),
                    itemBuilder: (context, index) {
                      return ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: getButtonColor(choices[index]),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8)),
                          padding: EdgeInsets.symmetric(vertical: 16),
                        ),
                        onPressed: () {
                          if (!showAnswer) {
                            checkAnswer(choices[index]);
                          }
                        },
                        child: Text(
                          choices[index],
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 18, color: Colors.white),
                          maxLines: 3,
                          overflow: TextOverflow.visible,
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            SizedBox(height: 20),
            if (showAnswer)
              ElevatedButton(
                onPressed: nextQuestion,
                child: Text("Continute"),
              ),
          ],
        ),
      ),
    );
  }
}
