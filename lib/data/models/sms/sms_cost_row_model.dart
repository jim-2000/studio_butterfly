import 'package:equatable/equatable.dart';

class SmsCostRowModel extends Equatable {
  final String provider;
  final String recipient;
  final double totalCost;

  const SmsCostRowModel({required this.provider, required this.recipient, required this.totalCost});

  factory SmsCostRowModel.fromJson(Map<String, dynamic> json) {
    return SmsCostRowModel(
      provider: json['provider'] as String? ?? 'UNKNOWN',
      recipient: json['recipient'] as String? ?? '',
      // Server may send an int (e.g. 0) or a double — don't assume.
      totalCost: (json['totalCost'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() => {'provider': provider, 'recipient': recipient, 'totalCost': totalCost};

  @override
  List<Object?> get props => [provider, recipient, totalCost];
}
