import 'package:equatable/equatable.dart';

import '../../core/money/money.dart';
import 'sms_cost_row_model.dart';

/// The cost endpoint never returns recipient phone numbers
/// (API-CONTRACT.md) — this model has no such field, so there is nothing
/// for the UI to render even by accident (see REVIEW.md finding #10, the
/// starter's fabricated `recipient` on this exact screen).
class SmsCostBreakdownModel extends Equatable {
  const SmsCostBreakdownModel({
    required this.currency,
    required this.totalCost,
    required this.rows,
  });

  factory SmsCostBreakdownModel.fromJson(Map<String, dynamic> json) {
    final currency = json['currency'] as String;
    final rowsJson = json['rows'] as List<dynamic>;
    return SmsCostBreakdownModel(
      currency: currency,
      totalCost: Money.parse(json['totalCost'] as String, currency),
      rows: rowsJson
          .map((row) => SmsCostRowModel.fromJson(row as Map<String, dynamic>, currency))
          .toList(),
    );
  }

  final String currency;
  final Money totalCost;
  final List<SmsCostRowModel> rows;

  @override
  List<Object?> get props => [currency, totalCost, rows];
}
