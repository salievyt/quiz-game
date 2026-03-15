import 'package:dio/dio.dart';
import 'package:quiz/core/error/failures.dart';
import 'package:quiz/core/utils/result.dart';
import 'package:quiz/features/leaderboards/data/leaderboard_api_service.dart';

class LeaderboardUser {
  final int id;
  final String username;
  final int points;

  LeaderboardUser({
    required this.id,
    required this.username,
    required this.points,
  });

  factory LeaderboardUser.fromJson(Map<String, dynamic> json) {
    return LeaderboardUser(
      id: json['id'],
      username: json['username'],
      points: json['points'],
    );
  }
}

class LeaderboardRepository {
  final LeaderboardApiService _apiService;

  LeaderboardRepository(this._apiService);

  Future<Result<List<LeaderboardUser>>> getLeaderboard({int limit = 20, int offset = 0}) async {
    try {
      final response = await _apiService.getLeaderboard(limit: limit, offset: offset);
      
      if (response.statusCode == 200) {
        // SimpleJWT pagination format: { "count": X, "next": Y, "previous": Z, "results": [...] }
        // If not using pagination globally, it might just return a list.
        // Assuming limit/offset returns `{ "results" : [...] }` or just a List.
        final List<dynamic> data = response.data['results'] ?? response.data;
        
        final users = data.map((json) => LeaderboardUser.fromJson(json)).toList();
        return Result.success(users);
      }
      return Result.failure(ServerFailure('Failed to fetch leaderboard'));
    } on DioException catch (e) {
      return Result.failure(ServerFailure(e.message ?? 'Network error'));
    } catch (e) {
      return Result.failure(UnknownFailure(e.toString()));
    }
  }
}
