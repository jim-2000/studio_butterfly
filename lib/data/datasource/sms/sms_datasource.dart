import 'package:studio_butterfly/core/network/api_client.dart';
import 'package:studio_butterfly/data/models/sms/sms_cost_row_model.dart';

abstract class SmsRemoteDatasource {
  /// Sends the SMS and returns the raw provider name chosen by the backend.
  Future<String> sendSms({required String phone, required String body});

  Future<List<SmsCostRowModel>> getCostBreakdown();
}

class SmsRemoteDatasourceImpl implements SmsRemoteDatasource {
  final ApiClient _client;

  SmsRemoteDatasourceImpl(this._client);

  @override
  Future<String> sendSms({required String phone, required String body}) async {
    final result = await _client.post('/api/v1/sms/send', body: {'to': phone, 'body': body});

    final provider = result['provider'];
    if (provider is! String || provider.isEmpty) {
      throw StateError('Server did not return a provider for the sent SMS');
    }
    return provider;
  }

  @override
  Future<List<SmsCostRowModel>> getCostBreakdown() async {
    final result = await _client.get('/api/v1/sms/cost/breakdown');
    final rows = result['rows'];
    if (rows is! List) return const [];

    return rows.whereType<Map<String, dynamic>>().map(SmsCostRowModel.fromJson).toList();
  }
}
