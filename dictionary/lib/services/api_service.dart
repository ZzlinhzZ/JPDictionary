import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/word_model.dart';
import '../models/kanji_model.dart';
import 'dart:typed_data';
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
//   static const String baseUrl = "http://127.0.0.1:8000";
  static const String baseUrl = "http://192.168.1.15:8000";
  // thay 192.168.1.9 bằng địa chỉ Ipv4 trong Wireless LAN adapter Wi-Fi (ipconfig)

  // Thêm phương thức kiểm tra đăng nhập
  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('authToken') != null;
  }

  Future<Map<String, dynamic>> register(
      String username, String email, String password) async {
    final response = await http.post(
      Uri.parse("$baseUrl/register"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(
          {"username": username, "email": email, "password": password}),
    );

    return _handleAuthResponse(response);
  }

  Future<Map<String, dynamic>> login(String username, String password) async {
    final response = await http.post(
      Uri.parse("$baseUrl/login"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"username": username, "password": password}),
    );

    return _handleAuthResponse(response);
  }

  Future<void> logout(String token) async {
    await http.post(
      Uri.parse("$baseUrl/logout"),
      headers: {"Authorization": "Bearer $token"},
    );
  }

  Future<Map<String, dynamic>> getCurrentUser(String token) async {
    final response = await http.get(
      Uri.parse("$baseUrl/me"),
      headers: {"Authorization": token},
    );

    if (response.statusCode == 200) {
      return json.decode(utf8.decode(response.bodyBytes));
    }
    throw Exception("Failed to get user");
  }

  Map<String, dynamic> _handleAuthResponse(http.Response response) {
    if (response.statusCode == 200) {
      return json.decode(utf8.decode(response.bodyBytes));
    }
    throw Exception(json.decode(utf8.decode(response.bodyBytes))['error'] ??
        'Authentication failed');
  }

  // ##############################
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
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('authToken');

    final response = await http.post(
      Uri.parse("$baseUrl/save_kanji"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token"
      },
      body: jsonEncode({
        "kanji": kanji,
        "pronounced": pronounced,
        "meaning": meaning,
      }),
    );
    if (response.statusCode != 200) {
      throw Exception("Failed to save kanji");
    }
  }

  Future<void> removeKanji(String kanji) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('authToken');

    await http.delete(
      Uri.parse('$baseUrl/delete_kanji/$kanji'),
      headers: {"Authorization": "Bearer $token"},
    );
  }

  Future<List<Map<String, dynamic>>> getSavedKanji() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('authToken');

    final response = await http.get(
      Uri.parse("$baseUrl/saved_kanji"),
      headers: {"Authorization": "Bearer $token"},
    );

    if (response.statusCode == 200) {
      List data = json.decode(utf8.decode(response.bodyBytes));
      return List<Map<String, dynamic>>.from(data);
    }
    // throw Exception("Failed to load saved kanji");
    return [];
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
      // print("Lỗi nhận diện kanji: $e");
      return [];
    }
  }

  Future<Map<String, dynamic>> getComments(String kanji, int page) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('authToken');

    final response = await http.get(
      Uri.parse("$baseUrl/comments/$kanji?page=$page"),
      headers: {"Authorization": "Bearer $token"},
    );

    return json.decode(utf8.decode(response.bodyBytes));
  }

  Future<void> addComment(String kanji, String content) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('authToken');

    await http.post(
      Uri.parse("$baseUrl/comments"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token"
      },
      body: jsonEncode({"kanji": kanji, "content": content}),
    );
  }

  Future<void> voteComment(int commentId, String action) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('authToken');

    await http.post(
      Uri.parse("$baseUrl/comments/$commentId/vote"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token"
      },
      body: jsonEncode({"action": action.replaceAll('un', '')}),
    );
  }
}
