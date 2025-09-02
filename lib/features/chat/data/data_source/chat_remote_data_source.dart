import 'dart:async';

import 'package:dio/dio.dart';
import 'package:test_task_oncom/core/data/dio_client.dart';
import 'package:test_task_oncom/features/chat/data/models/api_payload.dart';
import 'package:test_task_oncom/features/chat/data/parsers/plain_data_parser.dart';

class ChatRemoteDataSource {
  ChatRemoteDataSource(DioClient client) : dio = client.dio;
  final Dio dio;

  Future<String> fetchAssistantReply({
    required String userText,
    required String threadId,
    required String resourceId,
  }) async {
    final requestBody = ApiPayload.singleUserMessage(
      text: userText,
      threadId: threadId,
      resourceId: resourceId,
    ).toJson();

    final response = await dio.post<String>(
      '/api/agents/copilotAgent/stream',
      data: requestBody,
      options: Options(responseType: ResponseType.plain),
    );
    final raw = response.data ?? '';
    return PlainChannelCollector.collectByTag(raw, '0');
  }
}
