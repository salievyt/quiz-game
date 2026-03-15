import 'package:quiz/data/models/question.dart';

class CategoryModel {
  final int id;
  final String name;
  final String description;
  final String iconUrl;
  final String imageUrl;
  final bool isNew;

  CategoryModel({
    required this.id,
    required this.name,
    required this.description,
    required this.iconUrl,
    required this.imageUrl,
    this.isNew = false,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'],
      name: json['name'],
      description: json['description'] ?? '',
      iconUrl: json['icon'] ?? '',
      imageUrl: json['image'] ?? '',
      isNew: json['is_new'] ?? false,
    );
  }
}

abstract class QuizRepository {
  Future<List<CategoryModel>> getCategories();
  Future<List<Question>> getQuestions(int categoryId);
}
