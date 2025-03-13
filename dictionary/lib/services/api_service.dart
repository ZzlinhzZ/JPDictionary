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

  String? _authToken; // Lưu token đăng nhập
  int? _userId; // Lưu user_id sau khi đăng nhập

  Future<void> loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _authToken = prefs.getString('authToken');
    _userId = prefs.getInt('userId');
  }

  Future<bool> login(String username, String password) async {
    final response = await http.post(
      Uri.parse("$baseUrl/login"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "username": username,
        "password": password,
      }),
    );

    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      String token = data["token"];
      print(token);
      // Lưu token vào SharedPreferences
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString("auth_token", token);

      return true;
    }
    return false;
  }

  Future<bool> register(String username, String password) async {
    final response = await http.post(
      Uri.parse("$baseUrl/register"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "username": username,
        "password": password,
      }),
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      print("Lỗi đăng ký: ${response.body}");
      return false;
    }
  }

  //  Đăng xuất
  Future<void> logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove("auth_token");
  }

//  Hàm kiểm tra trạng thái đăng nhập
  Future<bool> isLoggedIn() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.containsKey("auth_token");
  }

  //  Kiểm tra đăng nhập
  Future<int?> getUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getInt("user_id");
  }

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
    int? userId = await getUserId();
    if (userId == null) throw Exception("Bạn cần đăng nhập trước!");
    await http.post(
      Uri.parse("$baseUrl/save_kanji"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "user_id": userId, // Gửi user_id để lưu dữ liệu riêng cho từng người
        "kanji": kanji,
        "pronounced": pronounced,
        "meaning": meaning,
      }),
    );
  }

  //  Xóa Kanji
  Future<void> removeKanji(String kanji) async {
    int? userId = await getUserId();
    if (userId == null) throw Exception("Bạn cần đăng nhập trước!");

    await http.delete(Uri.parse("$baseUrl/delete_kanji/$userId/$kanji"));
  }

  //  Lấy danh sách Kanji đã lưu
  Future<List<Map<String, dynamic>>> getSavedKanji() async {
    int? userId = await getUserId();
    if (userId == null) return [];

    final response = await http.get(Uri.parse("$baseUrl/saved_kanji/$userId"));
    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(json.decode(response.body));
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
