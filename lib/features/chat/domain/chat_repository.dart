import 'package:dio/dio.dart';
import 'package:quiz/core/error/failures.dart';
import 'package:quiz/core/utils/result.dart';
import 'package:quiz/features/chat/data/chat_api_service.dart';

class ChatMessage {
  final int id;
  final String senderName;
  final bool isSupport;
  final String content;
  final String timestamp;
  final bool isRead;

  ChatMessage({
    required this.id,
    required this.senderName,
    required this.isSupport,
    required this.content,
    required this.timestamp,
    required this.isRead,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'],
      senderName: json['sender_name'],
      isSupport: json['is_support'],
      content: json['content'],
      timestamp: json['timestamp'],
      isRead: json['is_read'],
    );
  }
}

class ChatSession {
  final int id;
  final String userName;
  final bool isOpen;
  final List<ChatMessage> messages;

  ChatSession({
    required this.id,
    required this.userName,
    required this.isOpen,
    required this.messages,
  });

  factory ChatSession.fromJson(Map<String, dynamic> json) {
    return ChatSession(
      id: json['id'],
      userName: json['user_name'],
      isOpen: json['is_open'],
      messages: (json['messages'] as List)
          .map((msg) => ChatMessage.fromJson(msg))
          .toList(),
    );
  }
}

class ChatRepository {
  final ChatApiService _apiService;

  ChatRepository(this._apiService);

  Future<Result<ChatSession>> getOrCreatePersonalSession() async {
    try {
      final response = await _apiService.getSessionDetails();
      if (response.statusCode == 200) {
        return Result.success(ChatSession.fromJson(response.data));
      }
      return Result.failure(ServerFailure('Failed to load chat session'));
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return Result.failure(ServerFailure('Chat not found'));
      }
      return Result.failure(ServerFailure(e.message ?? 'Unknown error'));
    } catch (e) {
      return Result.failure(UnknownFailure(e.toString()));
    }
  }

  Future<Result<bool>> sendMessage(int sessionId, String content) async {
    try {
      final response = await _apiService.sendMessage(sessionId, content);
      if (response.statusCode == 201) {
        return Result.success(true);
      }
      return Result.failure(ServerFailure('Failed to send message'));
    } on DioException catch (e) {
      return Result.failure(ServerFailure(e.message ?? 'Sending failed'));
    } catch (e) {
      return Result.failure(UnknownFailure(e.toString()));
    }
  }

  Future<Result<List<ChatSession>>> getSupportSessions() async {
    try {
      final response = await _apiService.getSupportSessions();
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['results'] ?? response.data;
        final sessions = data
            .map((json) => ChatSession.fromJson(json))
            .toList();
        return Result.success(sessions);
      }
      return Result.failure(ServerFailure('Failed to load sessions'));
    } on DioException catch (e) {
      return Result.failure(ServerFailure(e.message ?? 'Admin error'));
    } catch (e) {
      return Result.failure(UnknownFailure(e.toString()));
    }
  }
}
