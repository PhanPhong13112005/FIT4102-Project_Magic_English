
import 'package:fit4102_project_magic_english/Model/user_model.dart';

import '../config/database.dart';

class LoginController {
  /// Login thật dựa vào DB
  Future<bool> login(UserModel user) async {
    try {
      final conn = await DatabaseConfig.connection;

      final results = await conn.execute(
        'SELECT COUNT(*) AS count FROM users WHERE username = ? AND password = ?',
        [user.username, user.password] as Map<String, dynamic>?,
      );

      final row = results.rows.first;
      final count = row.assoc()['count'] as int;

      return count > 0;
    } catch (e) {
      print("Login error: $e");
      return false;
    }
  }
}
