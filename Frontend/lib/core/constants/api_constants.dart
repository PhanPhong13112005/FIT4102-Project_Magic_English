import 'package:flutter/foundation.dart';

class ApiConstants {
  // Logic tự động chọn URL:
  // - Nếu build Release (xuất APK thật): Dùng Domain thật (Production).
  // - Nếu chạy Debug: Dùng IP Server VPS của nhóm (Lp deploy).
  static String get baseUrl {
    if (kReleaseMode) {
      return "https://hoctienganh.ddns.net/api"; // URL Production
    } else {
      // Trỏ thẳng lên Server VPS của nhóm để test chung Database
      return "http://localhost:5000/api";
    }
  }
}
