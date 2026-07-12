import 'package:equatable/equatable.dart';

class SmsSendResultModel extends Equatable {
  final String provider;
  final int segments;
  final double cost;

  const SmsSendResultModel({required this.provider, required this.segments, required this.cost});

  @override
  List<Object?> get props => [provider, segments, cost];
}
