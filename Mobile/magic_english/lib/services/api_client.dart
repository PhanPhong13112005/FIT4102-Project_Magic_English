import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:magic_english/models/models.dart';

/// API Client for Magic English Backend
class ApiClient {
  static const String baseUrl = 'http://localhost:5000/api/v1';
  // For Android emulator: http://10.0.2.2:5000/api/v1
  // For iOS simulator: http://localhost:5000/api/v1
  // For physical device: http://YOUR_MACHINE_IP:5000/api/v1

  static const Duration timeout = Duration(seconds: 30);

  // Headers
  static Map<String, String> get _headers {
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
  }

  // ============ USER ENDPOINTS ============

  /// Create a new user (Sign up)
  static Future<User> createUser(String name, String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/users/signup'),
        headers: _headers,
        body: jsonEncode({
          'name': name,
          'email': email,
          'password': password,
        }),
      ).timeout(timeout);

      if (response.statusCode == 201 || response.statusCode == 200) {
        return User.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Failed to create user: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error creating user: $e');
    }
  }

  /// Login user with email and password
  static Future<User> loginUser(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/users/login'),
        headers: _headers,
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      ).timeout(timeout);

      if (response.statusCode == 200) {
        return User.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Login failed: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error logging in: $e');
    }
  }

  /// Get user by ID
  static Future<User> getUser(int userId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/users/$userId'),
        headers: _headers,
      ).timeout(timeout);

      if (response.statusCode == 200) {
        return User.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Failed to get user: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error getting user: $e');
    }
  }

  /// Get user by email
  static Future<User> getUserByEmail(String email) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/users/search/email/$email'),
        headers: _headers,
      ).timeout(timeout);

      if (response.statusCode == 200) {
        return User.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('User not found: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error getting user by email: $e');
    }
  }

  // ============ VOCABULARY ENDPOINTS ============

  /// Add a new vocabulary word
  static Future<Vocabulary> addVocabulary(int userId, String word) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/vocabulary/add?userId=$userId'),
        headers: _headers,
        body: jsonEncode({
          'word': word,
        }),
      ).timeout(timeout);

      if (response.statusCode == 201) {
        return Vocabulary.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Failed to add vocabulary: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error adding vocabulary: $e');
    }
  }

  /// Get all vocabularies for a user
  static Future<List<Vocabulary>> getVocabularies(int userId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/vocabulary/list?userId=$userId'),
        headers: _headers,
      ).timeout(timeout);

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((item) => Vocabulary.fromJson(item)).toList();
      } else {
        throw Exception('Failed to get vocabularies: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error getting vocabularies: $e');
    }
  }

  /// Search vocabularies
  static Future<List<Vocabulary>> searchVocabularies(int userId, String query) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/vocabulary/search?userId=$userId&query=$query'),
        headers: _headers,
      ).timeout(timeout);

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((item) => Vocabulary.fromJson(item)).toList();
      } else {
        throw Exception('Failed to search vocabularies: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error searching vocabularies: $e');
    }
  }

  /// Get vocabulary statistics
  static Future<VocabularyStatistics> getVocabularyStatistics(int userId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/vocabulary/statistics?userId=$userId'),
        headers: _headers,
      ).timeout(timeout);

      if (response.statusCode == 200) {
        return VocabularyStatistics.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Failed to get vocabulary statistics: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error getting vocabulary statistics: $e');
    }
  }

  /// Delete vocabulary
  static Future<void> deleteVocabulary(int vocabularyId) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/vocabulary/$vocabularyId'),
        headers: _headers,
      ).timeout(timeout);

      if (response.statusCode != 204) {
        throw Exception('Failed to delete vocabulary: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error deleting vocabulary: $e');
    }
  }

  // ============ GRAMMAR ENDPOINTS ============

  /// Check grammar of a text
  static Future<GrammarCheckResult> checkGrammar(int userId, String text) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/grammar/check?userId=$userId'),
        headers: _headers,
        body: jsonEncode({
          'text': text,
        }),
      ).timeout(timeout);

      if (response.statusCode == 200) {
        return GrammarCheckResult.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Failed to check grammar: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error checking grammar: $e');
    }
  }

  /// Get grammar check history
  static Future<List<GrammarCheckResult>> getGrammarHistory(int userId, {int pageSize = 10}) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/grammar/history?userId=$userId&pageSize=$pageSize'),
        headers: _headers,
      ).timeout(timeout);

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((item) => GrammarCheckResult.fromJson(item)).toList();
      } else {
        throw Exception('Failed to get grammar history: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error getting grammar history: $e');
    }
  }

  // ============ STATISTICS ENDPOINTS ============

  /// Get dashboard
  static Future<Dashboard> getDashboard(int userId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/statistics/dashboard?userId=$userId'),
        headers: _headers,
      ).timeout(timeout);

      if (response.statusCode == 200) {
        return Dashboard.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Failed to get dashboard: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error getting dashboard: $e');
    }
  }

  /// Get user streak
  static Future<Streak> getStreak(int userId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/statistics/streak?userId=$userId'),
        headers: _headers,
      ).timeout(timeout);

      if (response.statusCode == 200) {
        return Streak.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Failed to get streak: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error getting streak: $e');
    }
  }

  /// Get activity trend
  static Future<List<DailyActivity>> getActivityTrend(int userId, {int days = 30}) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/statistics/activity-trend?userId=$userId&days=$days'),
        headers: _headers,
      ).timeout(timeout);

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((item) => DailyActivity.fromJson(item)).toList();
      } else {
        throw Exception('Failed to get activity trend: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error getting activity trend: $e');
    }
  }
}
