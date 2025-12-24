import 'package:shared_preferences/shared_preferences.dart';

/// Central place to read/write auth session data.
class SessionStorage {
  static const _keyToken = 'token';
  static const _keyEmployeeId = 'employeeId';
  static const _keyEmployeeName = 'employeeName';
  static const _keyStoreId = 'storeId';

  /// Save login/session details after a successful auth.
  static Future<void> saveSession({
    required String token,
    required int employeeId,
    required String employeeName,
    required int storeId,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyToken, token);
    await prefs.setInt(_keyEmployeeId, employeeId);
    await prefs.setString(_keyEmployeeName, employeeName);
    await prefs.setInt(_keyStoreId, storeId);
  }

  /// Read the auth token (used to decide logged-in state).
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyToken);
  }

  /// Clear all stored session details (used on logout).
  static Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyToken);
    await prefs.remove(_keyEmployeeId);
    await prefs.remove(_keyEmployeeName);
    await prefs.remove(_keyStoreId);
  }
}


