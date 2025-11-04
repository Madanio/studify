import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import '../database/database_helper.dart';

class AuthService {
  static final AuthService instance = AuthService._init();
  AuthService._init();

  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  Future<User?> login(String username, String password) async {
    final user = await _dbHelper.getUser(username, password);
    if (user != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('logged_in_user', user.username);
      await prefs.setString('user_type', user.type.toString().split('.').last);
    }
    return user;
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('logged_in_user');
    await prefs.remove('user_type');
  }

  Future<String?> getLoggedInUsername() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('logged_in_user');
  }

  Future<String?> getUserType() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_type');
  }

  Future<bool> isLoggedIn() async {
    final username = await getLoggedInUsername();
    return username != null;
  }
}
