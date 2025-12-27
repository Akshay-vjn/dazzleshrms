import 'package:dazzleshrms/core/api_config/api_config.dart';
import 'package:dazzleshrms/core/api_constants/api_constants.dart';

import '../models/blocked_date_model.dart';

class BlockedDateRepository {
  Future<List<BlockedDateModel>> fetchBlockedDates() async {
    final response =
    await ApiConfig.dio.get(ApiConstants.blockedLeaveDates);
    final List list = response.data['data'];
    return list.map((e) => BlockedDateModel.fromJson(e)).toList();
  }
}
