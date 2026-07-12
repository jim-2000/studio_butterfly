import '../../core/error/either.dart';
import '../../core/error/failure.dart';
import '../models/message_page_model.dart';
import '../models/sms_cost_breakdown_model.dart';
import '../models/sms_send_result_model.dart';

abstract class SmsRepository {
  Future<Either<Failure, SmsSendResultModel>> sendSms({
    required String to,
    required String body,
    String? referenceId,
  });

  Future<Either<Failure, SmsCostBreakdownModel>> getCostBreakdown({DateTime? from, DateTime? to});

  Future<Either<Failure, MessagePageModel>> getMessages({String? cursor, int limit = 50});
}
