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

 // 1. Sửa 'void' thành 'WritingCheckResponse'
  Future<WritingCheckResponse> checkWriting(String content) async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      // 2. Lấy kết quả từ API
      final result = await ApiClient.checkWriting(content);
      _lastCheck = result; // Vẫn lưu vào state như cũ
      
      return result; // 3. BẮT BUỘC có dòng này để ném dữ liệu sang file giao diện
      
    } catch (e) {
      _error = e.toString();
      rethrow; // 4. Ném lỗi ra ngoài để file giao diện bắt được và hiện SnackBar báo lỗi
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
