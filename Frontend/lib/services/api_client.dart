import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/vocabulary_model.dart';
import '../models/writing_model.dart';
import '../models/stats_model.dart';

class ApiClient {
  // Development: Use localhost for both web and local
  static const String baseUrl = 'http://localhost:5181/api';
  static const Duration timeout = Duration(seconds: 30);

  static String? _authToken;

  static void setToken(String token) {
    _authToken = token;
  }

  static void clearToken() {
    _authToken = null;
  }

  static Map<String, String> _getHeaders() {
    final headers = {'Content-Type': 'application/json'};
    if (_authToken != null) {
      headers['Authorization'] = 'Bearer $_authToken';
    }
    return headers;
  }

  // ============ Authentication Endpoints ============

  static Future<Map<String, dynamic>> post(
    String endpoint,
    Map<String, dynamic> body,
  ) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl$endpoint'),
            headers: _getHeaders(),
            body: jsonEncode(body),
          )
          .timeout(timeout);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body);
      } else if (response.statusCode == 400) {
        return jsonDecode(response.body);
      } else if (response.statusCode == 401 || response.statusCode == 403) {
        throw Exception('Unauthorized');
      } else {
        throw Exception('Failed: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  // ============ Vocabulary Endpoints ============

  static Future<VocabularyModel> addVocabulary(String word) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/vocabulary/add'),
            headers: _getHeaders(),
            body: jsonEncode({'word': word}),
          )
          .timeout(timeout);

      if (response.statusCode == 200) {
        return VocabularyModel.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Failed to add vocabulary: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error adding vocabulary: $e');
    }
  }

  static Future<VocabularyListResponse> getVocabularyList({
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      final response = await http
          .get(
            Uri.parse('$baseUrl/vocabulary/list?page=$page&pageSize=$pageSize'),
            headers: _getHeaders(),
          )
          .timeout(timeout);

      if (response.statusCode == 200) {
        return VocabularyListResponse.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Failed to get vocabulary: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error getting vocabulary: $e');
    }
  }

  static Future<VocabularyModel?> getVocabularyById(int id) async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/vocabulary/$id'), headers: _getHeaders())
          .timeout(timeout);

      if (response.statusCode == 200) {
        return VocabularyModel.fromJson(jsonDecode(response.body));
      } else if (response.statusCode == 404) {
        return null;
      } else {
        throw Exception('Failed to get vocabulary: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error getting vocabulary: $e');
    }
  }

  static Future<List<VocabularyModel>> searchVocabulary(String term) async {
    try {
      final response = await http
          .get(
            Uri.parse('$baseUrl/vocabulary/search?term=$term'),
            headers: _getHeaders(),
          )
          .timeout(timeout);

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data
            .map((e) => VocabularyModel.fromJson(e as Map<String, dynamic>))
            .toList();
      } else {
        throw Exception('Failed to search vocabulary: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error searching vocabulary: $e');
    }
  }

  // ============ Writing Endpoints ============

  static Future<WritingCheckResponse> checkWriting(String content) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/writing/check'),
            headers: _getHeaders(),
            body: jsonEncode({'content': content}),
          )
          .timeout(timeout);

      if (response.statusCode == 200) {
        return WritingCheckResponse.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Failed to check writing: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error checking writing: $e');
    }
  }

  static Future<List<WritingCheckResponse>> getWritingSubmissions() async {
    try {
      final response = await http
          .get(
            Uri.parse('$baseUrl/writing/submissions'),
            headers: _getHeaders(),
          )
          .timeout(timeout);

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data
            .map(
              (e) => WritingCheckResponse.fromJson(e as Map<String, dynamic>),
            )
            .toList();
      } else {
        throw Exception('Failed to get submissions: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error getting submissions: $e');
    }
  }

  // ============ Stats Endpoints ============

  static Future<StatsResponse> getStats() async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/stats/stats'), headers: _getHeaders())
          .timeout(timeout);

      if (response.statusCode == 200) {
        return StatsResponse.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Failed to get stats: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error getting stats: $e');
    }
  }

  static Future<DashboardResponse> getDashboard() async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/stats/dashboard'), headers: _getHeaders())
          .timeout(timeout);

      if (response.statusCode == 200) {
        return DashboardResponse.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Failed to get dashboard: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error getting dashboard: $e');
    }
  }

  static Future<void> updateStreak() async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/stats/update-streak'),
            headers: _getHeaders(),
          )
          .timeout(timeout);

      if (response.statusCode != 200) {
        throw Exception('Failed to update streak: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error updating streak: $e');
    }
  }
}
