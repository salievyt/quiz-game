import 'package:dio/dio.dart';

class LeaderboardApiService {
  final Dio _dio;

  LeaderboardApiService(this._dio);

  Future<Response> getLeaderboard({int limit = 20, int offset = 0}) async {
    return await _dio.get(
      'users/leaderboard/',
      queryParameters: {
        'limit': limit,
        'offset': offset,
      },
    );
  }
}
