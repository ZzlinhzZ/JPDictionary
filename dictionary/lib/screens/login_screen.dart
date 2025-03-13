import 'package:flutter/material.dart';
import '../services/api_service.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  TextEditingController usernameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  bool isRegistering = false;
  final ApiService apiService = ApiService();

  void submit() async {
    bool success;
    if (isRegistering) {
      success = await apiService.register(
          usernameController.text, passwordController.text);
    } else {
      success = await apiService.login(
          usernameController.text, passwordController.text);
    }

    if (success) {
      Navigator.pop(context, true); // Trở về màn hình trước đó
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Sai tài khoản hoặc mật khẩu!")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(isRegistering ? "Đăng ký" : "Đăng nhập",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              SizedBox(height: 20),
              TextField(
                controller: usernameController,
                decoration: InputDecoration(labelText: "Tên đăng nhập"),
              ),
              TextField(
                controller: passwordController,
                obscureText: true,
                decoration: InputDecoration(labelText: "Mật khẩu"),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: submit,
                child: Text(isRegistering ? "Đăng ký" : "Đăng nhập"),
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    isRegistering = !isRegistering;
                  });
                },
                child: Text(isRegistering
                    ? "Đã có tài khoản? Đăng nhập"
                    : "Chưa có tài khoản? Đăng ký"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
