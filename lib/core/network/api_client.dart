import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../../env.dart';
import '../../service/local_storage_key.dart';
import '../../service/local_storage_service.dart';
import '../utils/url_container.dart';
import 'api_exception.dart';

/// Thin wrapper around [http.Client]: attaches auth/tenant headers, applies
/// a timeout, refreshes an expired access token and retries once, decodes
/// JSON, and maps every non-2xx status (and every transport failure) to a
/// typed [ApiException] — call sites never see a raw [http.Response] or a
/// `dynamic` body.
class ApiClient {
  ApiClient({
    String? baseUrl,
    http.Client? httpClient,
    Future<Map<String, String>> Function()? authHeaders,
    Duration timeout = const Duration(seconds: 10),
  })  : _baseUrl = baseUrl ?? Environment.kApiBase,
        _httpClient = httpClient ?? http.Client(),
        _authHeaders = authHeaders ?? apiAuthHeaders,
        _timeout = timeout;

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
    return {
      if (token != null) 'Authorization': 'Bearer $token',
      if (tenantId != null) 'X-Tenant-Id': tenantId,
    };
  }

  Future<Map<String, dynamic>> get(
    String path, {
    Map<String, String>? query,
  }) async {
    final uri = Uri.parse('$_baseUrl$path').replace(queryParameters: query);
    final response = await _send(() async => _httpClient.get(uri, headers: await _authHeaders()));
    return _decode(response);
  }

  Future<Map<String, dynamic>> post(String path, {Object? body}) async {
    final uri = Uri.parse('$_baseUrl$path');
    final response = await _send(
      () async => _httpClient.post(
        uri,
        headers: {...await _authHeaders(), 'Content-Type': 'application/json'},
        body: jsonEncode(body),
      ),
    );
    return _decode(response);
  }

  /// Tokens are short-lived (contract: 15 min) — a `401` here means expired,
  /// not necessarily invalid. Refreshes once and retries the same request
  /// with the new token; if refresh itself fails, the original `401` falls
  /// through to `_decode` as an [UnauthorizedApiException].
  Future<http.Response> _send(Future<http.Response> Function() request) async {
    try {
      final response = await request().timeout(_timeout);
      if (response.statusCode == 401 && await _tryRefreshAccessToken()) {
        return await request().timeout(_timeout);
      }
      return response;
    } on TimeoutException {
      throw const NetworkApiException('Request timed out');
    } on SocketException catch (e) {
      throw NetworkApiException(e.message);
    } on http.ClientException catch (e) {
      throw NetworkApiException(e.message);
    }
  }

  Future<bool> _tryRefreshAccessToken() async {
    final storage = LocalStorageService();
    final refreshToken = storage.getString(LocalStorageKey.refreshTokenKey);
    if (refreshToken == null) return false;

    try {
      final uri = Uri.parse('$_baseUrl${UrlContainer.authRefresh}');
      final response = await _httpClient
          .post(
            uri,
            headers: const {'Content-Type': 'application/json'},
            body: jsonEncode({'refreshToken': refreshToken}),
          )
          .timeout(_timeout);
      if (response.statusCode != 200) return false;

      final json = jsonDecode(response.body) as Map<String, dynamic>;
      final newAccessToken = json['accessToken'] as String?;
      if (newAccessToken == null) return false;

      await storage.setString(LocalStorageKey.accessTokenKey, newAccessToken);
      return true;
    } catch (_) {
      return false;
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
        return ValidationApiException(
          (body?['errorCode'] as String?) ?? 'VALIDATION_ERROR',
          (body?['message'] as String?) ?? 'Invalid request',
        );
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
        return UnknownApiException(
          response.statusCode,
          (body?['message'] as String?) ?? 'Unexpected error',
        );
    }
  }

  void dispose() => _httpClient.close();
}
