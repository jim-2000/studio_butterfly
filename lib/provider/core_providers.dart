import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:studio_butterfly/core/network/api_client.dart';
import 'package:studio_butterfly/env.dart';

import '../service/local_storage_service.dart';

final httpClientProvider = Provider<http.Client>((ref) {
  final client = http.Client();
  ref.onDispose(client.close);
  return client;
});

final apiClientProvider = Provider<ApiClient>((ref) {
  // Shares httpClientProvider's client, which owns its own disposal —
  // ApiClient.dispose() is only for the case where it builds its own
  // client internally (baseUrl-only construction, e.g. in tests).
  return ApiClient(
    baseUrl: Environment.kApiBase,
    httpClient: ref.watch(httpClientProvider),
  );
});

final localStorageServiceProvider = Provider<LocalStorageService>((ref) => LocalStorageService());
