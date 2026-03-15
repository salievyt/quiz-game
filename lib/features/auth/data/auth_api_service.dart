import 'package:dio/dio.dart';

class AuthApiService {
  final Dio _dio;

  AuthApiService(this._dio);

  Future<Response> login(String username, String password) async {
    return await _dio.post(
      'users/login/',
      data: {'username': username, 'password': password},
    );
  }

  Future<Response> register(String username, String password) async {
    return await _dio.post(
      'users/register/',
      data: {'username': username, 'password': password},
    );
  }

  Future<Response> getProfile() async {
    return await _dio.get('users/profile/');
  }

  Future<Response> updateProfile(Map<String, dynamic> data) async {
    return await _dio.patch('users/profile/', data: data);
  }
}
