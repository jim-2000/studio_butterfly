import 'package:equatable/equatable.dart';

import '../../core/money/money.dart';

class SmsCostRowModel extends Equatable {
  const SmsCostRowModel({
    required this.provider,
    required this.totalCost,
    required this.messageCount,
  });

  factory SmsCostRowModel.fromJson(Map<String, dynamic> json, String currency) {
    return SmsCostRowModel(
      provider: json['provider'] as String,
      totalCost: Money.parse(json['totalCost'] as String, currency),
      messageCount: json['messageCount'] as int,
    );
  }

  final String provider;
  final Money totalCost;
  final int messageCount;

  @override
  List<Object?> get props => [provider, totalCost, messageCount];
}
