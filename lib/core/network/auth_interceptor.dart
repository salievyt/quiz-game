import 'package:dio/dio.dart';
import 'package:quiz/core/storage/secure_storage.dart';

class AuthInterceptor extends Interceptor {
  final SecureStorage _storage;

  AuthInterceptor(this._storage);

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await _storage.getToken();

    // Add Authorization header if token exists and it's not a login/register request
    if (token != null &&
        !options.path.contains('/login') &&
        !options.path.contains('/register')) {
      options.headers['Authorization'] = 'Bearer $token';
    }

    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401) {
      final refreshToken = await _storage.getRefreshToken();

      if (refreshToken != null) {
        try {
          // Use a fresh Dio instance for the refresh call to avoid interceptor recursion
          final refreshDio = Dio(
            BaseOptions(baseUrl: err.requestOptions.baseUrl),
          );
          final response = await refreshDio.post(
            'users/refresh/',
            data: {'refresh': refreshToken},
          );

          if (response.statusCode == 200) {
            final newAccessToken = response.data['access'];
            await _storage.saveToken(newAccessToken);

            // Retry the original request with the new token
            final options = err.requestOptions;
            options.headers['Authorization'] = 'Bearer $newAccessToken';

            final retryResponse = await Dio(
              BaseOptions(baseUrl: options.baseUrl),
            ).fetch(options);
            return handler.resolve(retryResponse);
          }
        } catch (e) {
          // If refresh fails, clear storage and let the error propagate
          await _storage.clearAll();
        }
      } else {
        // No refresh token available
        await _storage.clearAll();
      }
    }

    handler.next(err);
  }
}
