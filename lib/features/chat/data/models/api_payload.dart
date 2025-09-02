import 'package:json_annotation/json_annotation.dart';

part 'api_payload.g.dart';

@JsonSerializable()
class ApiPayload {
  const ApiPayload({
    required this.messages,
    required this.threadId,
    required this.resourceId,
  });

  factory ApiPayload.singleUserMessage({
    required String text,
    required String threadId,
    required String resourceId,
  }) {
    return ApiPayload(
      messages: [
        {'role': 'user', 'content': text},
      ],
      threadId: threadId,
      resourceId: resourceId,
    );
  }

  final List<Map<String, String>> messages;
  final String threadId;
  final String resourceId;

  Map<String, dynamic> toJson() => _$ApiPayloadToJson(this);
}
