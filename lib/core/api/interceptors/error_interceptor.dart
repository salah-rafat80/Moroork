import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    debugPrint('Dio Error Occurred: ${err.type}');
    debugPrint('Status Code: ${err.response?.statusCode}');
    debugPrint('Path: ${err.requestOptions.path}');
    
    // You can log errors to a service like Sentry or Firebase Crashlytics here.
    
    if (err.response?.statusCode == 500) {
      debugPrint('🔥 CRITICAL: Internal Server Error at ${err.requestOptions.path}');
    }

    super.onError(err, handler);
  }
}
