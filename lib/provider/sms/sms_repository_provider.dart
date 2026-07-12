import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasource/sms_remote_datasource.dart';
import '../../data/repositories/sms_repository.dart';
import '../../data/repositories/sms_repository_impl.dart';
import '../core_providers.dart';

final smsRemoteDataSourceProvider = Provider<SmsRemoteDataSource>((ref) {
  return SmsRemoteDataSourceImpl(ref.watch(apiClientProvider));
});

final smsRepositoryProvider = Provider<SmsRepository>((ref) {
  return SmsRepositoryImpl(ref.watch(smsRemoteDataSourceProvider));
});
