import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import 'token_storage.dart';
import 'interceptors/auth_interceptor.dart';
import 'interceptors/error_interceptor.dart';

@lazySingleton
class ApiClient {
  static const String baseUrl = 'http://morourak.runasp.net/api/v1';

  late final Dio dio;

  ApiClient(TokenStorage tokenStorage) {
    dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      headers: {
        'Content-Type': 'application/json',
        'Accept': '*/*',
      },
    ));
    dio.interceptors.add(AuthInterceptor(tokenStorage));
    dio.interceptors.add(ErrorInterceptor());
    if (kDebugMode) {
      dio.interceptors.add(LogInterceptor(
        requestBody: true,
        responseHeader: false,
        responseBody: true,
      ));
    }
  }
}
