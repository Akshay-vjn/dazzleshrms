import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../repo/changedtab_actions_repo.dart';

final changedTabRepositoryProvider =
Provider<ChangedTabRepository>((ref) {
  return ChangedTabRepository();
});
