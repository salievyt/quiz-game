import 'package:dio/dio.dart';
import 'package:quiz/core/error/failures.dart';
import 'package:quiz/core/storage/secure_storage.dart';
import 'package:quiz/core/utils/result.dart';
import 'package:quiz/features/auth/data/auth_api_service.dart';

class UserProfile {
  final int id;
  final String username;
  final int points;
  final int coins;
  final bool isSupport;

  UserProfile({
    required this.id,
    required this.username,
    required this.points,
    required this.coins,
    required this.isSupport,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'],
      username: json['username'],
      points: json['points'],
      coins: json['coins'],
      isSupport: json['is_support'],
    );
  }
}

class AuthRepository {
  final AuthApiService _apiService;
  final SecureStorage _secureStorage;

  AuthRepository(this._apiService, this._secureStorage);

  Future<Result<bool>> login(String username, String password) async {
    try {
      final response = await _apiService.login(username, password);

      if (response.statusCode == 200) {
        final data = response.data;
        await _secureStorage.saveToken(data['access']);
        if (data['refresh'] != null) {
          await _secureStorage.saveRefreshToken(data['refresh']);
        }
        return Result.success(true);
      }
      return Result.failure(AuthFailure('Invalid credentials'));
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        return Result.failure(AuthFailure('Invalid username or password'));
      }
      return Result.failure(ServerFailure(e.message ?? 'Server error'));
    } catch (e) {
      return Result.failure(UnknownFailure(e.toString()));
    }
  }

  Future<Result<bool>> register(String username, String password) async {
    try {
      final response = await _apiService.register(username, password);

      if (response.statusCode == 201) {
        return Result.success(true);
      }
      return Result.failure(AuthFailure('Registration failed'));
    } on DioException catch (e) {
      return Result.failure(ServerFailure(e.message ?? 'Server error'));
    } catch (e) {
      return Result.failure(UnknownFailure(e.toString()));
    }
  }

  Future<void> logout() async {
    await _secureStorage.clearAll();
  }

  Future<bool> isAuthenticated() async {
    final token = await _secureStorage.getToken();
    return token != null && token.isNotEmpty;
  }

  Future<Result<UserProfile>> getProfile() async {
    try {
      final response = await _apiService.getProfile();
      if (response.statusCode == 200) {
        return Result.success(UserProfile.fromJson(response.data));
      }
      return Result.failure(ServerFailure('Failed to load profile'));
    } on DioException catch (e) {
      return Result.failure(ServerFailure(e.message ?? 'Network error'));
    } catch (e) {
      return Result.failure(UnknownFailure(e.toString()));
    }
  }

  Future<Result<UserProfile>> updateProfile({int? points, int? coins}) async {
    try {
      final data = <String, dynamic>{};
      if (points != null) data['points'] = points;
      if (coins != null) data['coins'] = coins;

      final response = await _apiService.updateProfile(data);
      if (response.statusCode == 200) {
        return Result.success(UserProfile.fromJson(response.data));
      }
      return Result.failure(ServerFailure('Failed to update profile'));
    } on DioException catch (e) {
      return Result.failure(ServerFailure(e.message ?? 'Network error'));
    } catch (e) {
      return Result.failure(UnknownFailure(e.toString()));
    }
  }
}
