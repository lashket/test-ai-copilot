// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'api_payload.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ApiPayload _$ApiPayloadFromJson(Map<String, dynamic> json) => ApiPayload(
  messages: (json['messages'] as List<dynamic>)
      .map((e) => Map<String, String>.from(e as Map))
      .toList(),
  threadId: json['threadId'] as String,
  resourceId: json['resourceId'] as String,
);

Map<String, dynamic> _$ApiPayloadToJson(ApiPayload instance) =>
    <String, dynamic>{
      'messages': instance.messages,
      'threadId': instance.threadId,
      'resourceId': instance.resourceId,
    };
