import 'package:mysql_client/mysql_client.dart';

class DatabaseConfig {
  static MySQLConnection? _connection;

  /// Lấy connection, nếu chưa kết nối sẽ tạo mới
  static Future<MySQLConnection> get connection async {
    if (_connection != null && _connection!.connected) {
      return _connection!;
    }

    _connection = await MySQLConnection.createConnection(
      host: '127.0.0.1',
      port: 3306,
      userName: 'root',
      password: '@Phongluu123',
      databaseName: 'MagicEnglishDB',
    );

    await _connection!.connect();
    return _connection!;
  }
}
