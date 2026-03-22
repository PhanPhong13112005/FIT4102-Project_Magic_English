import 'package:flutter/material.dart';
import 'package:magic_english/models/models.dart';
import 'package:magic_english/services/api_client.dart';

/// Provider for user authentication
class AuthProvider extends ChangeNotifier {
  User? _currentUser;
  bool _isLoading = false;
  String? _error;

  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _currentUser != null;

  /// Sign up a new user
  Future<bool> signUp(String name, String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final user = await ApiClient.createUser(name, email, password);
      _currentUser = user;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Login with email and password
  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final user = await ApiClient.loginUser(email, password);
      _currentUser = user;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Invalid email or password';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Logout
  void logout() {
    _currentUser = null;
    _error = null;
    notifyListeners();
  }

  /// Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }
}

/// Provider for vocabulary management
class VocabularyProvider extends ChangeNotifier {
  List<Vocabulary> _vocabularies = [];
  VocabularyStatistics? _statistics;
  bool _isLoading = false;
  String? _error;

  List<Vocabulary> get vocabularies => _vocabularies;
  VocabularyStatistics? get statistics => _statistics;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Add vocabulary
  Future<bool> addVocabulary(int userId, String word) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final vocab = await ApiClient.addVocabulary(userId, word);
      _vocabularies.insert(0, vocab);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Load vocabularies
  Future<void> loadVocabularies(int userId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _vocabularies = await ApiClient.getVocabularies(userId);
      _isLoading = false;
      _vocabularies.forEach((vocab) {
        debugPrint('Loaded vocabulary: Word=${vocab.word}, IPA=${vocab.ipa}, Meaning=${vocab.meaning}, PartOfSpeech=${vocab.partOfSpeech}, Example=${vocab.example}, CEFRLevel=${vocab.cefrLevel}');
      });
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      debugPrint('Error loading vocabularies: $_error');
      notifyListeners();
    }
  }

  /// Load statistics
  Future<void> loadStatistics(int userId) async {
    try {
      _statistics = await ApiClient.getVocabularyStatistics(userId);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  /// Search vocabularies
  Future<void> searchVocabularies(int userId, String query) async {
    _isLoading = true;
    notifyListeners();

    try {
      _vocabularies = await ApiClient.searchVocabularies(userId, query);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Delete vocabulary
  Future<bool> deleteVocabulary(int vocabularyId) async {
    try {
      await ApiClient.deleteVocabulary(vocabularyId);
      _vocabularies.removeWhere((v) => v.id == vocabularyId);
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}

/// Provider for grammar checking
class GrammarProvider extends ChangeNotifier {
  GrammarCheckResult? _lastResult;
  List<GrammarCheckResult> _history = [];
  bool _isLoading = false;
  String? _error;

  GrammarCheckResult? get lastResult => _lastResult;
  List<GrammarCheckResult> get history => _history;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Check grammar
  Future<bool> checkGrammar(int userId, String text) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await ApiClient.checkGrammar(userId, text);
      _lastResult = result;
      _history.insert(0, result);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Load grammar history
  Future<void> loadHistory(int userId) async {
    _isLoading = true;
    notifyListeners();

    try {
      _history = await ApiClient.getGrammarHistory(userId);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}

/// Provider for dashboard and statistics
class DashboardProvider extends ChangeNotifier {
  Dashboard? _dashboard;
  Streak? _streak;
  List<DailyActivity> _activityTrend = [];
  bool _isLoading = false;
  String? _error;

  Dashboard? get dashboard => _dashboard;
  Streak? get streak => _streak;
  List<DailyActivity> get activityTrend => _activityTrend;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Load dashboard
  Future<void> loadDashboard(int userId) async {
    _isLoading = true;
    _error = null;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });

    try {
      _dashboard = await ApiClient.getDashboard(userId);
      _isLoading = false;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        notifyListeners();
      });
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        notifyListeners();
      });
    }
  }

  /// Load streak
  Future<void> loadStreak(int userId) async {
    try {
      _streak = await ApiClient.getStreak(userId);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  /// Load activity trend
  Future<void> loadActivityTrend(int userId, {int days = 30}) async {
    try {
      _activityTrend = await ApiClient.getActivityTrend(userId, days: days);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
