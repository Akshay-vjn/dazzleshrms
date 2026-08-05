import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/leave_clash_calendar_model.dart';
import '../repo/leave_clash_calendar_repo.dart';

final leaveClashCalendarRepositoryProvider = Provider(
  (ref) => LeaveClashCalendarRepository(),
);

final leaveClashCalendarFocusedDayProvider = StateProvider<DateTime>(
  (ref) => DateTime.now(),
);

final leaveClashCalendarProvider =
    FutureProvider.family<List<LeaveClashCalendarDay>, ({int month, int year})>(
      (ref, period) async {
        return ref
            .read(leaveClashCalendarRepositoryProvider)
            .fetchCalendar(month: period.month, year: period.year);
      },
    );
