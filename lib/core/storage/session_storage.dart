import 'package:shared_preferences/shared_preferences.dart';

class SessionStorage {
  static const _keyToken = 'token';
  static const _keyRefreshToken = 'refreshToken';
  static const _keyEmployeeId = 'employeeId';
  static const _keyEmployeeName = 'employeeName';
  static const _keyStoreId = 'storeId';
  static const _keyStoreName = 'storeName';
  static const _keyPermissions = 'permissions';
  static const _keyRole = 'role';
  static const _keyBreakReportsStoreFilterPrefix = 'breakReportsStoreFilter';

  /// Save login/session
  static Future<void> saveSession({
    required String token,
    String? refreshToken,
    int? employeeId,
    String? employeeName,
    required int storeId,
    String? storeName,
    required String role,
    List<String>? permissions,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(_keyToken, token);

    if (refreshToken != null) {
      await prefs.setString(_keyRefreshToken, refreshToken);
    }

    if (employeeId != null) {
      await prefs.setInt(_keyEmployeeId, employeeId);
    }

    if (employeeName != null) {
      await prefs.setString(_keyEmployeeName, employeeName);
    }

    await prefs.setInt(_keyStoreId, storeId);

    if (storeName != null) {
      await prefs.setString(_keyStoreName, storeName);
    }

    await prefs.setString(_keyRole, role);

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

  /// Read stored role
  static Future<String?> getRole() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyRole);
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

  /// Get employee ID
  static Future<int?> getEmployeeId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_keyEmployeeId);
  }

  /// Get employee name
  static Future<String?> getEmployeeName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyEmployeeName);
  }

  /// Get store name
  static Future<String?> getStoreName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyStoreName);
  }

  /// Get store ID
  static Future<int?> getStoreId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_keyStoreId);
  }

  /// Store the last break reports filter per employee so it survives logout.
  static Future<void> saveBreakReportsStoreFilter({
    required int employeeId,
    int? storeId,
    String? storeName,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final idKey = '${_keyBreakReportsStoreFilterPrefix}_$employeeId';
    final nameKey = '${idKey}Name';

    if (storeId == null) {
      await prefs.remove(idKey);
      await prefs.remove(nameKey);
      return;
    }

    await prefs.setInt(idKey, storeId);
    if (storeName != null) {
      await prefs.setString(nameKey, storeName);
    } else {
      await prefs.remove(nameKey);
    }
  }

  static Future<int?> getBreakReportsStoreFilter(int employeeId) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('${_keyBreakReportsStoreFilterPrefix}_$employeeId');
  }

  static Future<String?> getBreakReportsStoreFilterName(int employeeId) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(
      '${_keyBreakReportsStoreFilterPrefix}_${employeeId}Name',
    );
  }

  /// Clear all stored session details
  static Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.remove(_keyToken);
    await prefs.remove(_keyRefreshToken);
    await prefs.remove(_keyEmployeeId);
    await prefs.remove(_keyEmployeeName);
    await prefs.remove(_keyStoreId);
    await prefs.remove(_keyStoreName);
    await prefs.remove(_keyRole);

    //  CLEAR PERMISSIONS
    await prefs.remove(_keyPermissions);
  }
}
