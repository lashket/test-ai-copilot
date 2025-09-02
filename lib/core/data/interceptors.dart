import 'package:dio/dio.dart';
import 'package:test_task_oncom/core/data/env.dart';

class ApiKeyInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    options.headers.addAll({
      'Convai-Api-Key': Env.apiKey,
      'Content-Type': 'application/json',
    });
    super.onRequest(options, handler);
  }
}
