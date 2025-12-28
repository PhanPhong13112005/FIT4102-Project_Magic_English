import 'package:flutter/material.dart';

class LoginController extends ChangeNotifier {
  String email = '';
  String password = '';
  bool isLoading = false;

  void setEmail(String value) {
    email = value;
    notifyListeners();
  }

  void setPassword(String value) {
    password = value;
    notifyListeners();
  }

  Future<bool> login() async {
    isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(seconds: 1));

    isLoading = false;
    notifyListeners();

    return email == "admin@gmail.com" && password == "123456";
  }
}
