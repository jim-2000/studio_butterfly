import 'dart:math';
import 'package:studio_butterfly/data/datasource/sms/sms_datasource.dart';
import 'package:studio_butterfly/data/models/sms/sms_cost_row_model.dart';
import 'package:studio_butterfly/data/models/sms/sms_send_result_model.dart';

import 'sms_repository.dart';

class SmsRepositoryImpl implements SmsRepository {
  final SmsRemoteDatasource _datasource;

  SmsRepositoryImpl(this._datasource);

  static const _gsm7SegmentLength = 160;

  double _rateFor(String provider) {
    switch (provider) {
      case 'TWILIO':
        return 0.075;
      case 'VONAGE':
        return 0.065;
      case 'AWS_SNS':
        return 0.046;
      default:
        return 0.07;
    }
  }

  int msgLength(String body) {
    if (body.isEmpty) return 1;
    return max(1, (body.length / _gsm7SegmentLength).ceil());
  }

  @override
  Future<SmsSendResultModel> sendSms({required String phone, required String body}) async {
    final provider = await _datasource.sendSms(phone: phone, body: body);
    final segments = msgLength(body);
    final cost = _rateFor(provider) * segments;

    return SmsSendResultModel(provider: provider, segments: segments, cost: cost);
  }

  @override
  Future<List<SmsCostRowModel>> getCostBreakdown() => _datasource.getCostBreakdown();

  @override
  Future<double> getTotalCost() async {
    final rows = await getCostBreakdown();
    return rows.fold<double>(0.0, (sum, row) => sum + row.totalCost);
  }
}
