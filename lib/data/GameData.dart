import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:quiz/data/models/question.dart';
import 'dart:io';

class GameData {
  static final List<String> gameNames = [
    "Логикичеткая", "Geeks", "Для детей", "Основы ислама", "Дизайнер века",
    "Космос", "Наука", "Соцеальные сети","История","Музыка","География", "Speed RUN"
  ];
  static final List<int> gameIds = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12];
  
  static final List<String> images = [
    "https://i.ibb.co/k2fJzLgx/logic.jpg",
    "https://i.ibb.co/TxcY9GVk/Geeks.jpg",
    "https://i.ibb.co/zWPLDptZ/jun.jpg",
    "", "", "", "", "", ""
  ];

  static final List<String> imagesLocal = [
    "assets/images/logic.jpg",
    "assets/images/geeks.jpg",
    "assets/images/jun.jpg",
    "assets/images/islam.jpg",
    "assets/images/designer.jpg",
    "assets/images/cosmos.jpg",
    "assets/images/science.jpg",
    "assets/images/socialMedia.jpg",
    "assets/images/history.jpg",
    "assets/images/music.jpg",
    "assets/images/geography.jpg",
    "assets/images/speedRun.png"
  ];

  static final List<String> Icons = [
    "assets/icons/LOGIC_ICON.png",
    "assets/icons/GEEKS_ICON.png",
    "assets/icons/JUNIOR_ICON.png",
    "assets/icons/ISLAM_ICON.png",
    "assets/icons/DESIGNER_ICON.png",
    "assets/icons/COSMOS_ICON.png",
    "assets/icons/SCIENCE_ICON.png",
    "assets/icons/SOCIALMEDIA_ICON.png",
    "assets/icons/HISTORY_ICON.png",
    "assets/icons/MUSIC_ICON.png",
    "assets/icons/GEOGRAPHY_ICON.png",
    "assets/icons/SPEED_RUN.png",
  ];

  static final List<String> descriptions = [
    "Это не просто вопросы - это челлендж для твоего интеллекта. Проверь, насколько ты умеешь анализировать, сравнивать и находить скрытые решения.",
    "Тут вопросы про нашу академию - На сколько ты знаешь академию Geeks и разные направления IT",
    "Весёлые задачки, которые помогут тебе думать быстрее и находить правильные решения!",
    "Думаешь, знаешь всё про пять столпов, пророков и важные события? Проверим \nЭта категория не скучная теория, а лёгкий и понятный квиз про фундаментальные знания ислама: вера, практика, история и базовые принципы.",
    "Эта категория про культовых дизайнеров, бренды, креатив, стиль и решения, которые изменили визуальный мир.",
    "Любишь звёзды, планеты и всё, что летает быстрее интернета?\nВ этой категории ты узнаешь, сколько планет в Солнечной системе, что такое чёрная дыра, почему Луна не падает и правда ли, что в космосе никто не услышит твой крик. Готов проверить, космический ли у тебя мозг?",
    "Как устроен мир ?\nНаука - это не скучные формулы, а способ понимать реальность. Почему небо голубое? Как работает мозг? Из чего состоит всё вокруг? Проверим, насколько ты будущий учёный.",
    "Скроллишь каждый день? \nТогда пора узнать, что стоит за лайками и алгоритмами \nСоциальные сети — это не только мемы и сторис. Это алгоритмы, тренды, блогеры, безопасность и влияние на мозг. Насколько ты осознанный пользователь?",
    "Проверь, насколько хорошо ты знаешь прошлое человечества — от древних цивилизаций до современных событий.",
    "Узнай, насколько ты шаришь в хитах, артистах и музыкальных трендах.",
    "Проверь, сможешь ли ты найти любую точку на карте без Google Maps",
    "SPEED RUN MODE"
  ];

  List<String> getGameNames() {
    return gameNames;
  }
  
  List<int> getGameIds() {
    return gameIds;
  }
  
  List<String> getImages() {
    return images;
  }
  
  List<String> getImagesLocal() {
    return imagesLocal;
  }
  
  List<String> getIcons() {
    return Icons;
  }
  
  List<String> getDescriptions() {
    return descriptions;
  }

  static String get _baseUrl {
    if (Platform.isAndroid) {
      return 'http://10.0.2.2:8000/api/questions/';
    } else {
      return 'http://127.0.0.1:8000/api/questions/';
    }
  }

  static Future<List<Question>> getQuiz(int categoryId) async {
    try {
      final url = Uri.parse('$_baseUrl?category_id=$categoryId');
      final response = await http.get(url, headers: {"Accept": "application/json"});
      
      if (response.statusCode == 200) {
        final List<dynamic> jsonList = json.decode(utf8.decode(response.bodyBytes));
        
        return jsonList.map((json) {
          return Question(
            question: json['text'],
            answers: List<String>.from(json['options'] ?? []),
            correctIndex: json['correct_index'] ?? 0,
          );
        }).toList();
      } else {
        print("Error fetching questions: Status code ${response.statusCode}");
        return [];
      }
    } catch (e) {
      print("Exception fetching questions: $e");
      return [];
    }
  }
}