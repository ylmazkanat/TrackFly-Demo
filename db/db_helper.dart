import 'package:mysql1/mysql1.dart';

class DatabaseHelper {
  static Future<MySqlConnection> connect() async {
    final settings = ConnectionSettings(
      host: 'xxxxxx', // Replace with your database host
      port: 3306, // Default MySQL port
      user: 'xxxxxx', // Replace with your database username
      password: 'xxxxxx', // Replace with your database password
      db: 'xxxxxx', // Replace with your database name
      
    );
    return await MySqlConnection.connect(settings);
  }
}
