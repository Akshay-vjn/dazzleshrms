import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/storage/session_storage.dart';

final permissionProvider = StateNotifierProvider<PermissionNotifier, Set<String>>((ref) {
  return PermissionNotifier();
});

class PermissionNotifier extends StateNotifier<Set<String>> {
  PermissionNotifier() : super({}) {
    init();
  }

  Future<void> init() async {
    final permissions = await SessionStorage.getPermissions();
    state = permissions.toSet();
  }

  void setPermissions(List<String> permissions) {
    state = permissions.toSet();
  }

  void clearPermissions() {
    state = {};
  }
}
