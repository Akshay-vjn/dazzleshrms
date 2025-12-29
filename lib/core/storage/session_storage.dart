import 'package:shared_preferences/shared_preferences.dart';

class SessionStorage {
  static const _keyToken = 'token';
  static const _keyRefreshToken = 'refreshToken';
  static const _keyEmployeeId = 'employeeId';
  static const _keyEmployeeName = 'employeeName';
  static const _keyStoreId = 'storeId';
  static const _keyPermissions = 'permissions';

  /// Save login/session
  static Future<void> saveSession({
    required String token,
    String? refreshToken,
    required int employeeId,
    required String employeeName,
    required int storeId,

    List<String>? permissions,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(_keyToken, token);

    if (refreshToken != null) {
      await prefs.setString(_keyRefreshToken, refreshToken);
    }

    await prefs.setInt(_keyEmployeeId, employeeId);
    await prefs.setString(_keyEmployeeName, employeeName);
    await prefs.setInt(_keyStoreId, storeId);

    if (permissions != null) {
      await prefs.setStringList(_keyPermissions, permissions);
    }
  }

  /// Read the auth token.
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyToken);
  }

  /// Read the refresh token.
  static Future<String?> getRefreshToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyRefreshToken);
  }

  ///  Read permissions
  static Future<List<String>> getPermissions() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_keyPermissions) ?? [];
  }

  ///  Check single permission
  static Future<bool> hasPermission(String permission) async {
    final permissions = await getPermissions();
    return permissions.contains(permission);
  }

  /// Update tokens after refresh
  static Future<void> updateTokens({
    required String token,
    String? refreshToken,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyToken, token);

    if (refreshToken != null) {
      await prefs.setString(_keyRefreshToken, refreshToken);
    }
  }

  /// Clear all stored session details
  static Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.remove(_keyToken);
    await prefs.remove(_keyRefreshToken);
    await prefs.remove(_keyEmployeeId);
    await prefs.remove(_keyEmployeeName);
    await prefs.remove(_keyStoreId);

    //  CLEAR PERMISSIONS
    await prefs.remove(_keyPermissions);
  }
}
