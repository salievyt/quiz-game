import 'package:quiz/features/game/data/quiz_api_service.dart';
import 'package:quiz/features/game/domain/quiz_repository.dart';
import 'package:quiz/data/models/question.dart';

class QuizRepositoryImpl implements QuizRepository {
  final QuizApiService _apiService;

  QuizRepositoryImpl(this._apiService);

  @override
  Future<List<CategoryModel>> getCategories() async {
    try {
      final response = await _apiService.getCategories();
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => CategoryModel.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<Question>> getQuestions(int categoryId) async {
    try {
      final response = await _apiService.getQuestions(categoryId);
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data
            .map(
              (json) => Question(
                question: json['text'],
                answers: List<String>.from(json['options'] ?? []),
                correctIndex: json['correct_index'] ?? 0,
              ),
            )
            .toList();
      }
      return [];
    } catch (e) {
      rethrow;
    }
  }
}
