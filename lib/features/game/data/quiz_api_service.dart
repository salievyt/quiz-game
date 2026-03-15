import 'package:dio/dio.dart';

class QuizApiService {
  final Dio _dio;

  QuizApiService(this._dio);

  Future<Response> getCategories() async {
    return await _dio.get('questions/categories/');
  }

  Future<Response> getQuestions(int categoryId) async {
    return await _dio.get(
      'questions/list/',
      queryParameters: {'category_id': categoryId},
    );
  }
}
