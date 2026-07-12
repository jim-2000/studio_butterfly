import 'package:studio_butterfly/data/models/sms/sms_cost_row_model.dart';
import 'package:studio_butterfly/data/models/sms/sms_send_result_model.dart';

abstract class SmsRepository {
  Future<SmsSendResultModel> sendSms({required String phone, required String body});

  Future<List<SmsCostRowModel>> getCostBreakdown();

  Future<double> getTotalCost();
}
