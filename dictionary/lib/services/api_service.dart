import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/word_model.dart';
import '../models/kanji_model.dart';
import 'dart:typed_data';

class ApiService {
//   static const String baseUrl = "http://127.0.0.1:8000";
  static const String baseUrl = "http://192.168.1.15:8000";
  // thay 192.168.1.9 bằng địa chỉ Ipv4 trong Wireless LAN adapter Wi-Fi (ipconfig)
  Future<List<Word>> getWords(String query) async {
    final response = await http.get(Uri.parse("$baseUrl/words?search=$query"));
    if (response.statusCode == 200) {
      List data = json.decode(utf8.decode(
          response.bodyBytes)); // Sử dụng utf8.decode để đảm bảo mã hóa đúng
      return data.map((word) => Word.fromJson(word)).toList();
    } else {
      throw Exception("Failed to load words");
    }
  }

  Future<List<Kanji>> getKanji(String query) async {
    final response = await http.get(Uri.parse("$baseUrl/kanji?search=$query"));
    if (response.statusCode == 200) {
      List data = json.decode(utf8.decode(
          response.bodyBytes)); // Sử dụng utf8.decode để đảm bảo mã hóa đúng
      return data.map((kanji) => Kanji.fromJson(kanji)).toList();
    } else {
      throw Exception("Failed to load kanji");
    }
  }

  Future<void> saveKanji(
      String kanji, String pronounced, String meaning) async {
    final response = await http.post(
      Uri.parse("$baseUrl/save_kanji"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "kanji": kanji,
        "pronounced": pronounced,
        "meaning": meaning,
      }),
    );
  }

  Future<void> removeKanji(String kanji) async {
    await http.delete(
      Uri.parse('$baseUrl/delete_kanji/$kanji'),
    );
  }

  Future<List<Map<String, dynamic>>> getSavedKanji() async {
    final response = await http.get(Uri.parse("$baseUrl/saved_kanji"));
    if (response.statusCode == 200) {
      List data = json
          .decode(utf8.decode(response.bodyBytes)); // Giải mã với utf8.decode
      return List<Map<String, dynamic>>.from(data);
    } else {
      return [];
    }
  }

  Future<List<String>> recognizeKanji(Uint8List imageData) async {
    try {
      var response = await http.post(
        Uri.parse("$baseUrl/recognize-kanji"), // Đúng endpoint
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"image": base64Encode(imageData)}),
      );

      if (response.statusCode == 200) {
        List<dynamic> results =
            jsonDecode(utf8.decode(response.bodyBytes))["predictions"];
        return results.cast<String>();
      } else {
        throw Exception("Lỗi API: ${response.statusCode}");
      }
    } catch (e) {
      print("Lỗi nhận diện kanji: $e");
      return [];
    }
  }
}
