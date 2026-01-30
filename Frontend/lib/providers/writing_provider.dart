import 'package:flutter/material.dart';
import '../models/writing_model.dart';
import '../services/api_client.dart';

class WritingProvider extends ChangeNotifier {
  WritingCheckResponse? _lastCheck;
  List<WritingCheckResponse> _submissions = [];
  bool _isLoading = false;
  String _error = '';

  WritingCheckResponse? get lastCheck => _lastCheck;
  List<WritingCheckResponse> get submissions => _submissions;
  bool get isLoading => _isLoading;
  String get error => _error;

  Future<void> checkWriting(String content) async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      _lastCheck = await ApiClient.checkWriting(content);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadSubmissions() async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      _submissions = await ApiClient.getWritingSubmissions();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    _error = '';
    notifyListeners();
  }
}
