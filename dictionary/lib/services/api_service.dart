import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/word_model.dart';
import '../models/kanji_model.dart';

class ApiService {
//   static const String baseUrl = "http://127.0.0.1:8000";
    static const String baseUrl = "http://192.168.1.14:8000";
  Future<List<Word>> getWords(String query) async {
    final response = await http.get(Uri.parse("$baseUrl/words?search=$query"));
    if (response.statusCode == 200) {
      List data = json.decode(utf8.decode(response.bodyBytes));  // Sử dụng utf8.decode để đảm bảo mã hóa đúng
      return data.map((word) => Word.fromJson(word)).toList();
    } else {
      throw Exception("Failed to load words");
    }
  }

  Future<List<Kanji>> getKanji(String query) async {
    final response = await http.get(Uri.parse("$baseUrl/kanji?search=$query"));
    if (response.statusCode == 200) {
      List data = json.decode(utf8.decode(response.bodyBytes));  // Sử dụng utf8.decode để đảm bảo mã hóa đúng
      return data.map((kanji) => Kanji.fromJson(kanji)).toList();
    } else {
      throw Exception("Failed to load kanji");
    }
  }

  Future<List<String>> getSavedKanji() async {
    final response = await http.get(Uri.parse("$baseUrl/saved_kanji"));
    if (response.statusCode == 200) {
      return List<String>.from(json.decode(utf8.decode(response.bodyBytes)));  // Sử dụng utf8.decode để đảm bảo mã hóa đúng
    } else {
      throw Exception("Failed to load saved kanji");
    }
  }

  Future<void> saveKanji(String kanji) async {
    await http.post(Uri.parse("$baseUrl/saved_kanji"), 
      body: json.encode({"kanji": kanji}), 
      headers: {"Content-Type": "application/json"});
  }

  Future<void> removeKanji(String kanji) async {
    await http.delete(Uri.parse("$baseUrl/saved_kanji/$kanji"));
  }
}
