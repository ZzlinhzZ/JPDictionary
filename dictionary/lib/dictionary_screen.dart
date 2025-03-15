import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'services/api_service.dart';
import 'models/word_model.dart';
import 'models/kanji_model.dart';
import 'screens/vocabulary_screen.dart';
import 'screens/kanji_screen.dart';
import 'screens/my_kanji_screen.dart';
import 'screens/auth_screen.dart';
import '../widgets/handwriting_canvas.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class DictionaryScreen extends StatefulWidget {
  @override
  _DictionaryScreenState createState() => _DictionaryScreenState();
}

class _DictionaryScreenState extends State<DictionaryScreen> {
  ApiService apiService = ApiService();
  List<Word> wordResults = [];
  List<Kanji> kanjiResults = [];
  TextEditingController searchController = TextEditingController();

  String? authToken;
  String? username;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadAuthToken();
  }

  void _loadAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      authToken = prefs.getString('authToken');
      username = prefs.getString('username');
    });

    if (authToken != null) {
      _fetchCurrentUser();
    }
  }

  void _fetchCurrentUser() async {
    try {
      final user = await apiService.getCurrentUser(authToken!);
      setState(() {
        username = user['username'];
      });
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('username', user['username']);
    } catch (e) {
      print("Error fetching user: $e");
    }
  }

  void _showAuthDialog(bool isLogin) {
    TextEditingController usernameController = TextEditingController();
    TextEditingController passwordController = TextEditingController();
    TextEditingController emailController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isLogin ? 'Login' : 'Register'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (!isLogin)
                TextField(
                  controller: emailController,
                  decoration: InputDecoration(labelText: 'Email'),
                ),
              TextField(
                controller: usernameController,
                decoration: InputDecoration(labelText: 'Username'),
              ),
              TextField(
                controller: passwordController,
                obscureText: true,
                decoration: InputDecoration(labelText: 'Password'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              try {
                setState(() => isLoading = true);
                final prefs = await SharedPreferences.getInstance();

                if (isLogin) {
                  final response = await apiService.login(
                    usernameController.text,
                    passwordController.text,
                  );

                  await prefs.setString('authToken', response['token']);
                  await prefs.setString('username', usernameController.text);

                  setState(() {
                    authToken = response['token'];
                    username = usernameController.text;
                  });
                } else {
                  final response = await apiService.register(
                    usernameController.text,
                    emailController.text,
                    passwordController.text,
                  );

                  await prefs.setString('authToken', response['token']);
                  await prefs.setString('username', usernameController.text);

                  setState(() {
                    authToken = response['token'];
                    username = usernameController.text;
                  });
                }

                Navigator.pop(context);
              } catch (e) {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text('Error'),
                    content: Text(e.toString()),
                  ),
                );
              } finally {
                setState(() => isLoading = false);
              }
            },
            child: Text(isLogin ? 'Login' : 'Register'),
          ),
        ],
      ),
    );
  }

  // void _handleAuthButtonPress() {
  //   if (authToken != null) {
  //     showMenu(
  //       context: context,
  //       position: RelativeRect.fromLTRB(100, 100, 0, 0),
  //       items: [
  //         PopupMenuItem(
  //           child: ListTile(
  //             title: Text('Logout'),
  //             onTap: () async {
  //               Navigator.pop(context);
  //               await apiService.logout(authToken!);
  //               final prefs = await SharedPreferences.getInstance();
  //               await prefs.remove('authToken');
  //               await prefs.remove('username');
  //               setState(() {
  //                 authToken = null;
  //                 username = null;
  //               });
  //             },
  //           ),
  //         ),
  //       ],
  //     );
  //   } else {
  //     showDialog(
  //       context: context,
  //       builder: (context) => AlertDialog(
  //         title: Text('Authentication'),
  //         content: Text('Choose an option'),
  //         actions: [
  //           TextButton(
  //             onPressed: () {
  //               Navigator.pop(context);
  //               _showAuthDialog(true);
  //             },
  //             child: Text('Login'),
  //           ),
  //           TextButton(
  //             onPressed: () {
  //               Navigator.pop(context);
  //               _showAuthDialog(false);
  //             },
  //             child: Text('Register'),
  //           ),
  //         ],
  //       ),
  //     );
  //   }
  // }

  void search(String query) async {
    if (query.isEmpty) {
      setState(() {
        wordResults.clear();
        kanjiResults.clear();
      });
      return;
    }

    try {
      // Gửi từ khóa vào API để tìm kiếm
      List<Word> words = await apiService.getWords(query);
      List<Kanji> kanji = await apiService.getKanji(query);

      setState(() {
        wordResults = words;
        kanjiResults = kanji;
      });
    } catch (e) {
      _showErrorDialog("Error connect to API: $e");
    }
  }

  void checkApiConnection() async {
    try {
      final response =
          await http.get(Uri.parse("${ApiService.baseUrl}/words?search=test"));
      if (response.statusCode == 200) {
        _showSuccessDialog("API connected successfully!");
      } else {
        _showErrorDialog("Error connecting to API: ${response.statusCode}");
      }
    } catch (e) {
      _showErrorDialog("Cannot connect to API: $e");
    }
  }

  void _showSuccessDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Success"),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("OK"),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Error"),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("OK"),
          ),
        ],
      ),
    );
  }

  void _openHandwritingCanvas() async {
    String? imageData = await showDialog(
      context: context,
      builder: (context) => HandwritingCanvas(
        onKanjiRecognized: (recognizedKanji) {
          // Xử lý kết quả nhận diện
          setState(() {
            // Lấy nội dung hiện có trong ô tìm kiếm
            String currentText = searchController.text;
            // Thêm kanji mới vào sau nội dung hiện có
            searchController.text = currentText + recognizedKanji;
            // searchController.text = recognizedKanji;
          });
          search(searchController.text);
        },
      ),
    );

    if (imageData != null) {
      _recognizeKanji(imageData);
    }
  }

  void _recognizeKanji(String imageData) async {
    try {
      final response = await http.post(
        Uri.parse(
            "http://your-api-url.com/recognize_kanji"), // Cập nhật URL API
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"image": imageData}),
      );

      if (response.statusCode == 200) {
        List<dynamic> results = jsonDecode(response.body)["predictions"];
        _showKanjiResults(results);
      } else {
        _showErrorDialog("Error recognizing kanji.");
      }
    } catch (e) {
      _showErrorDialog("Error connecting to API: $e");
    }
  }

  void _showKanjiResults(List<dynamic> results) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Detected Kanji"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: results.map((kanji) {
            return ListTile(
              title: Text(kanji),
              onTap: () {
                searchController.text = kanji;
                Navigator.pop(context);
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.all(8.0),
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.person, color: Colors.blue),
                    onPressed: () async {
                      if (authToken == null) {
                        final result = await Navigator.push<bool>(
                          context,
                          MaterialPageRoute(builder: (_) => const AuthScreen()),
                        );
                        if (result ?? false) {
                          _loadAuthToken();
                        }
                      } else {
                        showDialog(
                          context: context,
                          builder: (_) => AlertDialog(
                            title: Text('Account'),
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Hello $username!'),
                                const SizedBox(height: 16),
                                ElevatedButton(
                                  onPressed: () async {
                                    await apiService.logout(authToken!);
                                    final prefs =
                                        await SharedPreferences.getInstance();
                                    await prefs.remove('authToken');
                                    await prefs.remove('username');
                                    setState(() {
                                      authToken = null;
                                      username = null;
                                    });
                                    Navigator.pop(context);
                                  },
                                  child: const Text('Logout'),
                                ),
                              ],
                            ),
                          ),
                        );
                      }
                    },
                  ),
                  Expanded(
                    child: TextField(
                      controller: searchController,
                      onChanged: search,
                      onSubmitted: (query) {
                        search(query);
                      },
                      decoration: InputDecoration(
                        hintText: "Enter a word...",
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12)),
                        prefixIcon: Icon(Icons.search),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.wifi),
                    onPressed: checkApiConnection, // Nút kiểm tra API
                  ),
                  IconButton(
                    // Nút mở khung vẽ Kanji
                    icon: Icon(Icons.edit),
                    onPressed: _openHandwritingCanvas,
                  ),
                ],
              ),
            ),
            Expanded(
              child: DefaultTabController(
                length: 3,
                child: Column(
                  children: [
                    TabBar(
                      tabs: [
                        Tab(text: "Vocabulary"),
                        Tab(text: "Kanji"),
                        Tab(text: "My kanji"),
                      ],
                    ),
                    Expanded(
                      child: TabBarView(
                        children: [
                          VocabularyScreen(words: wordResults),
                          // KanjiScreen(kanjiList: kanjiResults),
                          // KanjiScreen(kanjiList: kanjiResults, searchQuery: searchController.text),
                          KanjiScreen(
                              kanjiList: kanjiResults,
                              searchQuery: searchController.text),
                          MyKanjiScreen(),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
