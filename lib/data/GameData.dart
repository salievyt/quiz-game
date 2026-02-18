import '../models/question.dart';

class GameData {
  final List<String> gameNames = ["Логикичеткая", "Geeks", "Для детей"];
  final List<int> gameIds = [1, 2, 3];
  final List<String> images = [
    "https://i.ibb.co/k2fJzLgx/logic.jpg",
    "https://i.ibb.co/TxcY9GVk/Geeks.jpg",
    "https://i.ibb.co/zWPLDptZ/jun.jpg"
  ];

  static final List<Question> _quizLogic = [

    Question(
      question: "Что лишнее: 2, 4, 6, 9, 10?",
      answers: ["2", "4", "6", "9"],
      correctIndex: 3,
    ),

    Question(
      question: "Продолжи ряд: 3, 6, 12, 24, ?",
      answers: ["36", "48", "30", "40"],
      correctIndex: 1,
    ),

    Question(
      question: "У Маши 3 яблока, она дала 1. Сколько осталось?",
      answers: ["1", "2", "3", "4"],
      correctIndex: 1,
    ),

    Question(
      question: "Если сегодня вторник, какой день будет через 3 дня?",
      answers: ["Пятница", "Суббота", "Четверг", "Воскресенье"],
      correctIndex: 0,
    ),

    Question(
      question: "Сколько сторон у квадрата?",
      answers: ["3", "4", "5", "6"],
      correctIndex: 1,
    ),

    Question(
      question: "Что тяжелее: 1 кг железа или 1 кг ваты?",
      answers: ["Железо", "Вата", "Одинаково", "Зависит от размера"],
      correctIndex: 2,
    ),

    Question(
      question: "Продолжи: 1, 1, 2, 3, 5, ?",
      answers: ["6", "7", "8", "9"],
      correctIndex: 2,
    ),

    Question(
      question: "Сколько будет 15 - 7?",
      answers: ["6", "7", "8", "9"],
      correctIndex: 2,
    ),

    Question(
      question: "У треугольника сколько углов?",
      answers: ["2", "3", "4", "5"],
      correctIndex: 1,
    ),

    Question(
      question: "Если 5 + 5 = 10, то 10 + 10 = ?",
      answers: ["10", "15", "20", "25"],
      correctIndex: 2,
    ),

    Question(
      question: "Что идёт после 99?",
      answers: ["100", "101", "98", "109"],
      correctIndex: 0,
    ),

    Question(
      question: "Сколько минут в часе?",
      answers: ["30", "45", "60", "90"],
      correctIndex: 2,
    ),
  ];

  static final List<Question> _quizGeeks = [

    Question(
      question: "Кто создал Flutter?",
      answers: ["Apple", "Google", "Microsoft", "Meta"],
      correctIndex: 1,
    ),

    Question(
      question: "Какой язык используется во Flutter?",
      answers: ["Java", "Kotlin", "Dart", "Swift"],
      correctIndex: 2,
    ),

    Question(
      question: "Что такое IDE?",
      answers: ["Среда разработки", "База данных", "Язык", "Браузер"],
      correctIndex: 0,
    ),

    Question(
      question: "Что делает setState?",
      answers: ["Удаляет экран", "Обновляет UI", "Закрывает приложение", "Создаёт файл"],
      correctIndex: 1,
    ),

    Question(
      question: "Какой виджет центрирует элемент?",
      answers: ["Align", "Center", "Stack", "Padding"],
      correctIndex: 1,
    ),

    Question(
      question: "Что такое Widget?",
      answers: ["Кнопка", "Строительный блок UI", "Сервер", "Файл"],
      correctIndex: 1,
    ),

    Question(
      question: "Как называется основной файл Flutter?",
      answers: ["app.dart", "main.dart", "index.dart", "home.dart"],
      correctIndex: 1,
    ),

    Question(
      question: "Как создать StatefulWidget?",
      answers: ["class A {}", "stful", "new Widget()", "build()"],
      correctIndex: 1,
    ),

    Question(
      question: "Что такое Navigator?",
      answers: ["База данных", "Навигация между экранами", "Кнопка", "Пакет"],
      correctIndex: 1,
    ),

    Question(
      question: "Что такое Git?",
      answers: ["Фреймворк", "Система контроля версий", "База данных", "Язык"],
      correctIndex: 1,
    ),

    Question(
      question: "Что такое API?",
      answers: ["Интерфейс взаимодействия", "Язык", "Сервер", "Файл"],
      correctIndex: 0,
    ),

    Question(
      question: "Какой метод запускает приложение?",
      answers: ["run()", "startApp()", "runApp()", "init()"],
      correctIndex: 2,
    ),
  ];

  static final List<Question> _quizJunior = [

    Question(
      question: "Сколько будет 2 + 2?",
      answers: ["3", "4", "5", "6"],
      correctIndex: 1,
    ),

    Question(
      question: "Какого цвета небо?",
      answers: ["Зелёное", "Синее", "Красное", "Чёрное"],
      correctIndex: 1,
    ),

    Question(
      question: "Сколько ног у кошки?",
      answers: ["2", "3", "4", "5"],
      correctIndex: 2,
    ),

    Question(
      question: "Сколько дней в неделе?",
      answers: ["5", "6", "7", "8"],
      correctIndex: 2,
    ),

    Question(
      question: "Какой месяц идёт после января?",
      answers: ["Март", "Февраль", "Апрель", "Май"],
      correctIndex: 1,
    ),

    Question(
      question: "Сколько будет 5 - 2?",
      answers: ["2", "3", "4", "5"],
      correctIndex: 1,
    ),

    Question(
      question: "Сколько глаз у человека?",
      answers: ["1", "2", "3", "4"],
      correctIndex: 1,
    ),

    Question(
      question: "Какой цвет у травы?",
      answers: ["Синий", "Красный", "Зелёный", "Жёлтый"],
      correctIndex: 2,
    ),

    Question(
      question: "Сколько будет 3 + 3?",
      answers: ["5", "6", "7", "8"],
      correctIndex: 1,
    ),

    Question(
      question: "Сколько месяцев в году?",
      answers: ["10", "11", "12", "13"],
      correctIndex: 2,
    ),

    Question(
      question: "Как называется планета, на которой мы живём?",
      answers: ["Марс", "Земля", "Юпитер", "Солнце"],
      correctIndex: 1,
    ),

    Question(
      question: "Сколько пальцев на одной руке?",
      answers: ["4", "5", "6", "7"],
      correctIndex: 1,
    ),
  ];

  final List<String> imagesLocal = [
    "assets/images/logic.jpg",
    "assets/images/geeks.jpg",
    "assets/images/jun.jpg",
  ];
  final List<String> Icons = [
    "assets/icons/LOGIC_ICON.jpg",
    "assets/icons/GEEKS_ICON.jpg",
    "assets/icons/JUNIOR_ICON.jpg",
  ];
  final List<String> descriptions = [
    "Это не просто вопросы - это челлендж для твоего интеллекта. Проверь, насколько ты умеешь анализировать, сравнивать и находить скрытые решения.",
    "Тут вопросы про нашу академию - На сколько ты знаешь академию Geeks и разные направления IT",
    "Весёлые задачки, которые помогут тебе думать быстрее и находить правильные решения!"
  ];

  List<String> getGameNames(){
    return gameNames;
  }
  List<int> getGameIds(){
    return gameIds;
  }
  List<String> getImages(){
    return images;
  }
  List<String> getImagesLocal(){
    return imagesLocal;
  }
  List<String> getIcons(){
    return Icons;
  }
  List<String> getDescriptions(){
    return descriptions;
  }

  static List<Question> getQuiz(int id) {
    switch (id) {
      case 1:
        return _quizLogic;
      case 2:
        return _quizGeeks;
      case 3:
        return _quizJunior;
      default:
        return _quizLogic;
    }
  }
}