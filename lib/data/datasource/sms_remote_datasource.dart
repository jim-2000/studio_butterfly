import '../../core/network/api_client.dart';
import '../../core/utils/url_container.dart';
import '../models/message_page_model.dart';
import '../models/sms_cost_breakdown_model.dart';
import '../models/sms_send_result_model.dart';

/// Raw HTTP calls per API-CONTRACT.md — typed in, typed out. [ApiClient]
/// already turns non-2xx responses into [ApiException]s, so this layer
/// never has to touch a status code or a `dynamic` body itself.
abstract class SmsRemoteDataSource {
  Future<SmsSendResultModel> sendSms({required String to, required String body, String? referenceId});

  Future<SmsCostBreakdownModel> getCostBreakdown({DateTime? from, DateTime? to});

  Future<MessagePageModel> getMessages({String? cursor, int limit = 50});
}

class SmsRemoteDataSourceImpl implements SmsRemoteDataSource {
  SmsRemoteDataSourceImpl(this._client);

  final ApiClient _client;

  @override
  Future<SmsSendResultModel> sendSms({required String to, required String body, String? referenceId}) async {
    final json = await _client.post(
      UrlContainer.smsSend,
      body: {
        'to': to,
        'body': body,
        if (referenceId != null) 'referenceId': referenceId,
      },
    );
    return SmsSendResultModel.fromJson(json);
  }

  @override
  Future<SmsCostBreakdownModel> getCostBreakdown({DateTime? from, DateTime? to}) async {
    final json = await _client.get(
      UrlContainer.smsCostBreakdown,
      query: {
        if (from != null) 'from': from.toUtc().toIso8601String(),
        if (to != null) 'to': to.toUtc().toIso8601String(),
      },
    );
    return SmsCostBreakdownModel.fromJson(json);
  }

  @override
  Future<MessagePageModel> getMessages({String? cursor, int limit = 50}) async {
    final json = await _client.get(
      UrlContainer.smsMessages,
      query: {
        if (cursor != null) 'cursor': cursor,
        'limit': '$limit',
      },
    );
    return MessagePageModel.fromJson(json);
  }
}
