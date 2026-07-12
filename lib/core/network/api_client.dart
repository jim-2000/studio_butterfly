import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../../env.dart';
import '../../service/local_storage_key.dart';
import '../../service/local_storage_service.dart';
import 'api_exception.dart';

/// Thin wrapper around [http.Client]: attaches auth/tenant headers, applies
/// a timeout, decodes JSON, and maps every non-2xx status (and every
/// transport failure) to a typed [ApiException] — call sites never see a
/// raw [http.Response] or a `dynamic` body.
class ApiClient {
  ApiClient({String? baseUrl, http.Client? httpClient, Future<Map<String, String>> Function()? authHeaders, Duration timeout = const Duration(seconds: 10)}) : _baseUrl = baseUrl ?? Environment.kApiBase, _httpClient = httpClient ?? http.Client(), _authHeaders = authHeaders ?? apiAuthHeaders, _timeout = timeout;

  final http.Client _httpClient;
  final String _baseUrl;
  final Future<Map<String, String>> Function() _authHeaders;
  final Duration _timeout;

  /// Reads the bearer token + tenant id persisted by the session/tenant
  /// switcher. Injectable via the constructor so tests can stub fixed
  /// headers instead of going through [LocalStorageService].
  static Future<Map<String, String>> apiAuthHeaders() async {
    final storage = LocalStorageService();
    final token = storage.getString(LocalStorageKey.accessTokenKey);
    final tenantId = storage.getString(LocalStorageKey.tenantIdKey);
    return {if (token != null) 'Authorization': 'Bearer $token', if (tenantId != null) 'X-Tenant-Id': tenantId};
  }

  Future<Map<String, dynamic>> get(String path, {Map<String, String>? query}) async {
    final uri = Uri.parse('$_baseUrl$path').replace(queryParameters: query);
    final response = await _send(() async => _httpClient.get(uri, headers: await _authHeaders()));
    return _decode(response);
  }

  Future<Map<String, dynamic>> post(String path, {Object? body}) async {
    final uri = Uri.parse('$_baseUrl$path');
    final response = await _send(() async => _httpClient.post(uri, headers: {...await _authHeaders(), 'Content-Type': 'application/json'}, body: jsonEncode(body)));
    return _decode(response);
  }

  Future<http.Response> _send(Future<http.Response> Function() request) async {
    try {
      return await request().timeout(_timeout);
    } on TimeoutException {
      throw const NetworkApiException('Request timed out');
    } on SocketException catch (e) {
      throw NetworkApiException(e.message);
    } on http.ClientException catch (e) {
      throw NetworkApiException(e.message);
    }
  }

  Map<String, dynamic> _decode(http.Response response) {
    final status = response.statusCode;
    if (status >= 200 && status < 300) {
      if (response.body.isEmpty) return const <String, dynamic>{};
      return jsonDecode(response.body) as Map<String, dynamic>;
    }
    throw _exceptionForStatus(response);
  }

  ApiException _exceptionForStatus(http.Response response) {
    Map<String, dynamic>? body;
    try {
      body = jsonDecode(response.body) as Map<String, dynamic>;
    } catch (_) {
      body = null;
    }

    switch (response.statusCode) {
      case 400:
        return ValidationApiException((body?['errorCode'] as String?) ?? 'VALIDATION_ERROR', (body?['message'] as String?) ?? 'Invalid request');
      case 401:
        return const UnauthorizedApiException();
      case 403:
        return const ForbiddenApiException();
      case 429:
        final header = response.headers['retry-after'];
        final seconds = int.tryParse(header ?? '') ?? 1;
        return RateLimitedApiException(Duration(seconds: seconds));
      case 502:
        return const BadGatewayApiException();
      default:
        return UnknownApiException(response.statusCode, (body?['message'] as String?) ?? 'Unexpected error');
    }
  }

  void dispose() => _httpClient.close();
}
