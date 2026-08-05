import '../../../../core/api_config/api_config.dart';
import '../../../../core/api_constants/api_constants.dart';
import '../models/leave_clash_calendar_model.dart';

class LeaveClashCalendarRepository {
  Future<List<LeaveClashCalendarDay>> fetchCalendar({
    required int month,
    required int year,
  }) async {
    final response = await ApiConfig.dio.get(
      ApiConstants.leaveClashCalendar,
      queryParameters: {'month': month, 'year': year},
    );
    final data = response.data['data'] as Map<String, dynamic>?;
    final calendar = data?['calendar'] as List? ?? const [];

    return calendar
        .map(
          (item) =>
              LeaveClashCalendarDay.fromJson(item as Map<String, dynamic>),
        )
        .toList();
  }
}
