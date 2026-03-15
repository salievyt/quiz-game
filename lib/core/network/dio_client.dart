import 'dart:io';
import 'package:dio/dio.dart';
import 'package:quiz/core/network/auth_interceptor.dart';
import 'package:quiz/core/storage/secure_storage.dart';

class DioClient {
  late final Dio dio;

  DioClient(SecureStorage secureStorage) {
    // Using 10.0.2.2 for Android emulator to access localhost, 
    // real devices/iOS simulator would use the exact IP or localhost appropriately.
    String baseUrl = const String.fromEnvironment('API_URL', defaultValue: '');
    if (baseUrl.isEmpty) {
      if (Platform.isAndroid) {
         baseUrl = 'http://10.0.2.2:8001/api/';
      } else {
         baseUrl = 'http://127.0.0.1:8001/api/';
      }
    }

    dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    dio.interceptors.add(AuthInterceptor(secureStorage));
    // Optional Logger interceptor can be added here
    dio.interceptors.add(LogInterceptor(responseBody: true, requestBody: true));
  }
}
