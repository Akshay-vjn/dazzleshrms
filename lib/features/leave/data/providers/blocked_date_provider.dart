import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/blocked_date_model.dart';
import '../repo/blocked_date_repo.dart';

final blockedDateRepositoryProvider =
Provider((ref) => BlockedDateRepository());

final blockedDateProvider =
FutureProvider<List<BlockedDateModel>>((ref) async {
  return ref.read(blockedDateRepositoryProvider).fetchBlockedDates();
});
