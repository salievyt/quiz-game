import 'package:dio/dio.dart';

class ChatApiService {
  final Dio _dio;

  ChatApiService(this._dio);

  Future<Response> getSessionDetails() async {
    return await _dio.get('chat/session/');
  }

  Future<Response> sendMessage(int sessionId, String content) async {
    return await _dio.post(
      'chat/session/$sessionId/messages/',
      data: {'content': content},
    );
  }

  Future<Response> getSupportSessions() async {
    return await _dio.get('chat/support/sessions/');
  }
}
