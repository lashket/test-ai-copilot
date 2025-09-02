import 'package:dio/dio.dart';
import 'package:test_task_oncom/core/data/env.dart';
import 'package:test_task_oncom/core/data/interceptors.dart';

class DioClient {
  factory DioClient() {
    final dio = Dio(
      BaseOptions(
        baseUrl: Env.baseUrl,
        connectTimeout: const Duration(seconds: 20),
        receiveTimeout: const Duration(minutes: 2),
        sendTimeout: const Duration(minutes: 2),
      ),
    );
    dio.interceptors.addAll([
      ApiKeyInterceptor(),
      LogInterceptor(
        requestBody: true,
        responseBody: true,
      ),
    ]);
    return DioClient._(dio);
  }

  DioClient._(this.dio);

  final Dio dio;
}
