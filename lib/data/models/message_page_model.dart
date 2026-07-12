import 'package:equatable/equatable.dart';

import 'sms_message_model.dart';

class MessagePageModel extends Equatable {
  const MessagePageModel({required this.items, required this.nextCursor});

  factory MessagePageModel.fromJson(Map<String, dynamic> json) {
    final itemsJson = json['items'] as List<dynamic>;
    return MessagePageModel(
      items: itemsJson.map((item) => SmsMessageModel.fromJson(item as Map<String, dynamic>)).toList(),
      nextCursor: json['nextCursor'] as String?,
    );
  }

  final List<SmsMessageModel> items;
  final String? nextCursor;

  @override
  List<Object?> get props => [items, nextCursor];
}
