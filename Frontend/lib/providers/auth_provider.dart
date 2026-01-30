import 'package:fit4102_project_magic_english/models/auth_response.dart';
import 'package:fit4102_project_magic_english/services/api_client.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthProvider extends ChangeNotifier {
  AuthResponseData? _currentUser;
  String? _token;
  bool _isLoading = false;
  String? _error;

  AuthResponseData? get currentUser => _currentUser;
  String? get token => _token;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _token != null && _currentUser != null;

  AuthProvider() {
    _loadStoredToken();
  }

  Future<void> _loadStoredToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _token = prefs.getString('auth_token');
      final userId = prefs.getInt('user_id');
      final email = prefs.getString('user_email');
      final username = prefs.getString('user_username');
      final fullName = prefs.getString('user_fullName');
      final tokenExpirationStr = prefs.getString('token_expiration');

      if (_token != null &&
          userId != null &&
          email != null &&
          username != null &&
          fullName != null) {
        _currentUser = AuthResponseData(
          userId: userId,
          email: email,
          username: username,
          fullName: fullName,
          token: _token!,
          tokenExpiration: tokenExpirationStr != null
              ? DateTime.parse(tokenExpirationStr)
              : DateTime.now(),
        );
        ApiClient.setToken(_token!);
      }
      notifyListeners();
    } catch (e) {
      print('Error loading stored token: $e');
    }
  }

  Future<bool> register({
    required String email,
    required String username,
    required String password,
    required String fullName,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await ApiClient.post('/auth/register', {
        'email': email,
        'username': username,
        'password': password,
        'fullName': fullName,
      });

      final authResponse = AuthResponse.fromJson(response);

      if (authResponse.success && authResponse.data != null) {
        _currentUser = authResponse.data;
        _token = authResponse.data!.token;

        // Store token and user info
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', _token!);
        await prefs.setInt('user_id', _currentUser!.userId);
        await prefs.setString('user_email', _currentUser!.email);
        await prefs.setString('user_username', _currentUser!.username);
        await prefs.setString('user_fullName', _currentUser!.fullName);
        await prefs.setString(
          'token_expiration',
          _currentUser!.tokenExpiration.toIso8601String(),
        );

        ApiClient.setToken(_token!);
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = authResponse.message;
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'Registration failed: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> login({required String email, required String password}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await ApiClient.post('/auth/login', {
        'email': email,
        'password': password,
      });

      final authResponse = AuthResponse.fromJson(response);

      if (authResponse.success && authResponse.data != null) {
        _currentUser = authResponse.data;
        _token = authResponse.data!.token;

        // Store token and user info
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', _token!);
        await prefs.setInt('user_id', _currentUser!.userId);
        await prefs.setString('user_email', _currentUser!.email);
        await prefs.setString('user_username', _currentUser!.username);
        await prefs.setString('user_fullName', _currentUser!.fullName);
        await prefs.setString(
          'token_expiration',
          _currentUser!.tokenExpiration.toIso8601String(),
        );

        ApiClient.setToken(_token!);
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = authResponse.message;
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'Login failed: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    _currentUser = null;
    _token = null;
    _error = null;

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    await prefs.remove('user_id');
    await prefs.remove('user_email');
    await prefs.remove('user_username');
    await prefs.remove('user_fullName');
    await prefs.remove('token_expiration');

    ApiClient.clearToken();
    notifyListeners();
  }
}
