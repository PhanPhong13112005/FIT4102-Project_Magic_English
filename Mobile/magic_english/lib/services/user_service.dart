import 'package:shared_preferences/shared_preferences.dart';
import 'package:magic_english/models/models.dart';

/// Service for managing user session and preferences
class UserService {
  static const String _userIdKey = 'user_id';
  static const String _userNameKey = 'user_name';
  static const String _userEmailKey = 'user_email';

  static late SharedPreferences _prefs;

  /// Initialize service
  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  /// Save user (after login/signup)
  static Future<void> saveUser(User user) async {
    await _prefs.setInt(_userIdKey, user.id);
    await _prefs.setString(_userNameKey, user.name);
    await _prefs.setString(_userEmailKey, user.email);
  }

  /// Get saved user ID
  static int? getCurrentUserId() {
    return _prefs.getInt(_userIdKey);
  }

  /// Get saved user name
  static String? getCurrentUserName() {
    return _prefs.getString(_userNameKey);
  }

  /// Get saved user email
  static String? getCurrentUserEmail() {
    return _prefs.getString(_userEmailKey);
  }

  /// Check if user is logged in
  static bool isLoggedIn() {
    return _prefs.getInt(_userIdKey) != null;
  }

  /// Clear user session (logout)
  static Future<void> logout() async {
    await _prefs.remove(_userIdKey);
    await _prefs.remove(_userNameKey);
    await _prefs.remove(_userEmailKey);
  }

  /// Update user profile locally
  static Future<void> updateUserProfile(String name, String email) async {
    await _prefs.setString(_userNameKey, name);
    await _prefs.setString(_userEmailKey, email);
  }
}
