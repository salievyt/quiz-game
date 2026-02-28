import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleProvider extends ChangeNotifier {
  static const String _localeKey = 'app_locale';
  
  Locale _locale = const Locale('ru');
  bool _isInitialized = false;

  Locale get locale => _locale;
  bool get isInitialized => _isInitialized;

  static const List<Locale> supportedLocales = [
    Locale('ru'),
    Locale('en'),
    Locale('ky'),
  ];

  static const Map<String, String> localeNames = {
    'ru': 'Русский',
    'en': 'English',
    'ky': 'Кыргызча',
  };

  static const Map<String, Map<String, String>> _translations = {
    'ru': {
      'appTitle': 'Quizzy',
      'home': 'Главная',
      'leaderboards': 'Топ',
      'statistics': 'Статистика',
      'profile': 'Профиль',
      'pet': 'Питомец',
      'settings': 'Настройки',
      'startGame': 'Начать играть',
      'game': 'Игра',
      'score': 'Очки',
      'points': 'очков',
      'coins': 'Монеты',
      'lives': 'Жизни',
      'perfect': 'Идеально!',
      'gameOver': 'Игра окончена',
      'playAgain': 'Играть снова',
      'exit': 'Выйти',
      'quitGame': 'Выйти из игры?',
      'quitGameMessage': 'Ваш прогресс будет потерян.',
      'yes': 'Да',
      'no': 'Нет',
      'cancel': 'Отмена',
      'continue': 'Продолжить',
      'buy': 'Купить',
      'equip': 'Надеть',
      'unequip': 'Снять',
      'close': 'Закрыть',
      'notEnoughCoins': 'Недостаточно монет!',
      'purchased': 'Куплено!',
      'achievements': 'Достижения',
      'quests': 'Квесты',
      'dailyQuests': 'Ежедневные квесты',
      'dailyBonus': 'Ежедневный бонус',
      'streak': 'Серия',
      'days': 'дней',
      'day': 'день',
      'claimBonus': 'Забрать',
      'newAchievement': 'Новая ачивка!',
      'noQuestions': 'В этой категории пока нет вопросов',
      'result': 'Результат',
      'correctAnswers': 'Правильных ответов',
      'accuracy': 'Точность',
      'gamesPlayed': 'Игр сыграно',
      'bestStreak': 'Лучшая серия',
      'totalPoints': 'Всего очков',
      'level': 'Уровень',
      'yourPet': 'Ваш питомец',
      'petShop': 'Магазин аксессуаров',
      'myPets': 'Мои питомцы',
      'accessories': 'Аксессуары',
      'hats': 'Шляпы',
      'glasses': 'Очки',
      'collars': 'Ошейники',
      'outfits': 'Одежда',
      'auras': 'Ауры',
      'tapToPet': 'Погладить',
      'happy': 'Счастлив!',
      'account': 'Аккаунт',
      'editProfile': 'Редактировать профиль',
      'changePassword': 'Сменить пароль',
      'gameSettings': 'Игровые настройки',
      'sound': 'Звук',
      'vibration': 'Вибрация',
      'notifications': 'Push-уведомления',
      'appearance': 'Внешний вид',
      'darkMode': 'Тёмная тема',
      'about': 'О приложении',
      'version': 'Версия',
      'privacy': 'Политика конфиденциальности',
      'logout': 'Выйти из аккаунта',
      'logoutConfirm': 'Выйти из аккаунта?',
      'logoutMessage': 'Вы уверены, что хотите выйти?',
      'speedrun': 'Speedrun',
      'timeLeft': 'Осталось',
      'category': 'Категория',
      'today': 'Сегодня',
      'completed': 'выполнено',
      'reward': 'Награда',
    },
    'en': {
      'appTitle': 'Quizzy',
      'home': 'Home',
      'leaderboards': 'Top',
      'statistics': 'Statistics',
      'profile': 'Profile',
      'pet': 'Pet',
      'settings': 'Settings',
      'startGame': 'Start Game',
      'game': 'Game',
      'score': 'Score',
      'points': 'points',
      'coins': 'Coins',
      'lives': 'Lives',
      'perfect': 'Perfect!',
      'gameOver': 'Game Over',
      'playAgain': 'Play Again',
      'exit': 'Exit',
      'quitGame': 'Quit Game?',
      'quitGameMessage': 'Your progress will be lost.',
      'yes': 'Yes',
      'no': 'No',
      'cancel': 'Cancel',
      'continue': 'Continue',
      'buy': 'Buy',
      'equip': 'Equip',
      'unequip': 'Unequip',
      'close': 'Close',
      'notEnoughCoins': 'Not enough coins!',
      'purchased': 'Purchased!',
      'achievements': 'Achievements',
      'quests': 'Quests',
      'dailyQuests': 'Daily Quests',
      'dailyBonus': 'Daily Bonus',
      'streak': 'Streak',
      'days': 'days',
      'day': 'day',
      'claimBonus': 'Claim',
      'newAchievement': 'New Achievement!',
      'noQuestions': 'No questions in this category yet',
      'result': 'Result',
      'correctAnswers': 'Correct Answers',
      'accuracy': 'Accuracy',
      'gamesPlayed': 'Games Played',
      'bestStreak': 'Best Streak',
      'totalPoints': 'Total Points',
      'level': 'Level',
      'yourPet': 'Your Pet',
      'petShop': 'Accessory Shop',
      'myPets': 'My Pets',
      'accessories': 'Accessories',
      'hats': 'Hats',
      'glasses': 'Glasses',
      'collars': 'Collars',
      'outfits': 'Outfits',
      'auras': 'Auras',
      'tapToPet': 'Pet',
      'happy': 'Happy!',
      'account': 'Account',
      'editProfile': 'Edit Profile',
      'changePassword': 'Change Password',
      'gameSettings': 'Game Settings',
      'sound': 'Sound',
      'vibration': 'Vibration',
      'notifications': 'Push Notifications',
      'appearance': 'Appearance',
      'darkMode': 'Dark Mode',
      'about': 'About',
      'version': 'Version',
      'privacy': 'Privacy Policy',
      'logout': 'Logout',
      'logoutConfirm': 'Logout?',
      'logoutMessage': 'Are you sure you want to logout?',
      'speedrun': 'Speedrun',
      'timeLeft': 'Time Left',
      'category': 'Category',
      'today': 'Today',
      'completed': 'completed',
      'reward': 'Reward',
    },
    'ky': {
      'appTitle': 'Quizzy',
      'home': 'Башкы бет',
      'leaderboards': 'Топ',
      'statistics': 'Статистика',
      'profile': 'Профиль',
      'pet': 'Питөм',
      'settings': 'Орнотуулар',
      'startGame': 'Ойноо',
      'game': 'Оюн',
      'score': 'Упай',
      'points': 'упай',
      'coins': 'Монета',
      'lives': 'Жаштар',
      'perfect': 'Татынаш!',
      'gameOver': 'Оюн бүттү',
      'playAgain': 'Кайра ойноо',
      'exit': 'Чыгуу',
      'quitGame': 'Оюндан чыгабы?',
      'quitGameMessage': 'Жетишкендиктериңиз жоголот.',
      'yes': 'Ооба',
      'no': 'Жок',
      'cancel': 'Отмена',
      'continue': 'Улантуу',
      'buy': 'Алуу',
      'equip': 'Кийүү',
      'unequip': 'Сычуу',
      'close': 'Жабуу',
      'notEnoughCoins': 'Монета жетпейт!',
      'purchased': 'Алынды!',
      'achievements': 'Жетишкендиктер',
      'quests': 'Квесттер',
      'dailyQuests': 'Күнүмдүк квесттер',
      'dailyBonus': 'Күнүмдүк бонус',
      'streak': 'Катар',
      'days': 'күн',
      'day': 'күн',
      'claimBonus': 'Алуу',
      'newAchievement': 'Жаңы жетишкендик!',
      'noQuestions': 'Бул категорияда суроо жок',
      'result': 'Натыйжа',
      'correctAnswers': 'Туура жооптор',
      'accuracy': 'Тактык',
      'gamesPlayed': 'Ойнолгон оюндар',
      'bestStreak': 'Эң узун катар',
      'totalPoints': 'Жалпы упай',
      'level': 'Деңгээл',
      'yourPet': 'Сиздин питөм',
      'petShop': 'Аксессуарлар дүкөнү',
      'myPets': 'Менин питөмдөрүм',
      'accessories': 'Аксессуарлар',
      'hats': 'Шляпалар',
      'glasses': 'Көз айнектер',
      'collars': 'Ошейниктер',
      'outfits': 'Кимдер',
      'auras': 'Ауралар',
      'tapToPet': 'Сыйпоо',
      'happy': 'Бактылуу!',
      'account': 'Аккаунт',
      'editProfile': 'Профилди өзгөртүү',
      'changePassword': 'Сырсөздү өзгөртүү',
      'gameSettings': 'Оюн орнотуулары',
      'sound': 'Үн',
      'vibration': 'Вибрация',
      'notifications': 'Билдирүүлөр',
      'appearance': 'Көрүнүш',
      'darkMode': 'Караңгы режим',
      'about': 'Колдонуу жөнүндө',
      'version': 'Версия',
      'privacy': 'Купуялык саясаты',
      'logout': 'Чыгуу',
      'logoutConfirm': 'Чыгабы?',
      'logoutMessage': 'Чыккыңыз келетби?',
      'speedrun': 'Тез ойноо',
      'timeLeft': 'Убакыт калды',
      'category': 'Категория',
      'today': 'Бүгүн',
      'completed': 'бүттү',
      'reward': 'Бонус',
    },
  };

  String translate(String key) {
    return _translations[_locale.languageCode]?[key] ?? 
           _translations['ru']?[key] ?? 
           key;
  }

  String operator [](String key) => translate(key);

  Future<void> init() async {
    if (_isInitialized) return;
    
    try {
      final prefs = await SharedPreferences.getInstance();
      final localeCode = prefs.getString(_localeKey) ?? 'ru';
      _locale = Locale(localeCode);
    } catch (e) {
      _locale = const Locale('ru');
    }
    
    _isInitialized = true;
    notifyListeners();
  }

  Future<void> setLocale(Locale locale) async {
    if (!supportedLocales.contains(locale)) return;
    
    _locale = locale;
    
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_localeKey, locale.languageCode);
    } catch (e) {
      // ignore
    }
    
    notifyListeners();
  }

  String getLocaleName(String code) {
    return localeNames[code] ?? code;
  }
}
