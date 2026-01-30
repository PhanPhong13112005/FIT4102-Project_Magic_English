import 'package:flutter/material.dart';
import '../models/vocabulary_model.dart';
import '../services/api_client.dart';

class VocabularyProvider extends ChangeNotifier {
  List<VocabularyModel> _vocabularies = [];
  int _totalCount = 0;
  bool _isLoading = false;
  String _error = '';
  int _currentPage = 1;
  static const int pageSize = 20;

  List<VocabularyModel> get vocabularies => _vocabularies;
  int get totalCount => _totalCount;
  bool get isLoading => _isLoading;
  String get error => _error;
  int get currentPage => _currentPage;

  Future<void> loadVocabularies({int page = 1}) async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      final response = await ApiClient.getVocabularyList(
        page: page,
        pageSize: pageSize,
      );
      _vocabularies = response.items;
      _totalCount = response.totalCount;
      _currentPage = page;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addVocabulary(String word) async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      final newVocab = await ApiClient.addVocabulary(word);
      _vocabularies.insert(0, newVocab);
      _totalCount++;
      if (_vocabularies.length > pageSize) {
        _vocabularies.removeLast();
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> searchVocabularies(String term) async {
    if (term.isEmpty) {
      await loadVocabularies(page: 1);
      return;
    }

    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      _vocabularies = await ApiClient.searchVocabulary(term);
      _totalCount = _vocabularies.length;
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
