import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../repo/modifiedtab_actions_repo.dart';

final changedTabRepositoryProvider =
Provider<ChangedTabRepository>((ref) {
  return ChangedTabRepository();
});
