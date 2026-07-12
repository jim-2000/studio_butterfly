import '../../core/error/either.dart';
import '../../core/error/failure.dart';
import '../../core/network/api_exception.dart';
import '../datasource/sms_remote_datasource.dart';
import '../models/message_page_model.dart';
import '../models/sms_cost_breakdown_model.dart';
import '../models/sms_send_result_model.dart';
import 'sms_repository.dart';

class SmsRepositoryImpl implements SmsRepository {
  SmsRepositoryImpl(this._remote);

  final SmsRemoteDataSource _remote;

  @override
  Future<Either<Failure, SmsSendResultModel>> sendSms({
    required String to,
    required String body,
    String? referenceId,
  }) async {
    try {
      final result = await _remote.sendSms(to: to, body: body, referenceId: referenceId);
      return Right(result);
    } on ApiException catch (e) {
      return Left(failureFromException(e));
    }
  }

  @override
  Future<Either<Failure, SmsCostBreakdownModel>> getCostBreakdown({DateTime? from, DateTime? to}) async {
    try {
      final result = await _remote.getCostBreakdown(from: from, to: to);
      return Right(result);
    } on ApiException catch (e) {
      return Left(failureFromException(e));
    }
  }

  @override
  Future<Either<Failure, MessagePageModel>> getMessages({String? cursor, int limit = 50}) async {
    try {
      final result = await _remote.getMessages(cursor: cursor, limit: limit);
      return Right(result);
    } on ApiException catch (e) {
      return Left(failureFromException(e));
    }
  }
}
