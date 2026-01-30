import 'package:flutter/material.dart';
import '../models/stats_model.dart';
import '../services/api_client.dart';

class StatsProvider extends ChangeNotifier {
  DashboardResponse? _dashboard;
  StatsResponse? _stats;
  bool _isLoading = false;
  String _error = '';

  DashboardResponse? get dashboard => _dashboard;
  StatsResponse? get stats => _stats;
  bool get isLoading => _isLoading;
  String get error => _error;

  Future<void> loadDashboard() async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      _dashboard = await ApiClient.getDashboard();
      _stats = _dashboard?.stats;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateStreak() async {
    try {
      await ApiClient.updateStreak();
      await loadDashboard();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  void clearError() {
    _error = '';
    notifyListeners();
  }
}
