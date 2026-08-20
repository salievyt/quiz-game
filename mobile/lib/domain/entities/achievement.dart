enum AchievementType {
  gamesPlayed,
  correctAnswers,
  streak,
  perfectGame,
  points,
  level,
  categoryMaster,
}

class Achievement {
  final String id;
  final String title;
  final String description;
  final String icon;
  final AchievementType type;
  final int requirement;
  final bool isRare;

  const Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.type,
    required this.requirement,
    this.isRare = false,
  });

  static const List<Achievement> all = [
    // Игры
    Achievement(
      id: 'first_game',
      title: 'Первые шаги',
      description: 'Сыграй свою первую игру',
      icon: '🎮',
      type: AchievementType.gamesPlayed,
      requirement: 1,
    ),
    Achievement(
      id: '10_games',
      title: 'Любитель',
      description: 'Сыграй 10 игр',
      icon: '🎯',
      type: AchievementType.gamesPlayed,
      requirement: 10,
    ),
    Achievement(
      id: '50_games',
      title: 'Энтузиаст',
      description: 'Сыграй 50 игр',
      icon: '🏅',
      type: AchievementType.gamesPlayed,
      requirement: 50,
    ),
    Achievement(
      id: '100_games',
      title: 'Мастер викторин',
      description: 'Сыграй 100 игр',
      icon: '👑',
      type: AchievementType.gamesPlayed,
      requirement: 100,
    ),

    // Правильные ответы
    Achievement(
      id: '10_correct',
      title: 'Новичок',
      description: 'Дай 10 правильных ответов',
      icon: '✅',
      type: AchievementType.correctAnswers,
      requirement: 10,
    ),
    Achievement(
      id: '50_correct',
      title: 'Знаток',
      description: 'Дай 50 правильных ответов',
      icon: '🧠',
      type: AchievementType.correctAnswers,
      requirement: 50,
    ),
    Achievement(
      id: '100_correct',
      title: 'Эксперт',
      description: 'Дай 100 правильных ответов',
      icon: '📚',
      type: AchievementType.correctAnswers,
      requirement: 100,
    ),
    Achievement(
      id: '500_correct',
      title: 'Гений',
      description: 'Дай 500 правильных ответов',
      icon: '🧬',
      type: AchievementType.correctAnswers,
      requirement: 500,
      isRare: true,
    ),

    // Серии
    Achievement(
      id: 'streak_5',
      title: 'Огненная серия',
      description: 'Выиграй 5 игр подряд',
      icon: '🔥',
      type: AchievementType.streak,
      requirement: 5,
    ),
    Achievement(
      id: 'streak_10',
      title: 'Несокрушимый',
      description: 'Выиграй 10 игр подряд',
      icon: '⚡',
      type: AchievementType.streak,
      requirement: 10,
      isRare: true,
    ),
    Achievement(
      id: 'streak_25',
      title: 'Легенда',
      description: 'Выиграй 25 игр подряд',
      icon: '🌟',
      type: AchievementType.streak,
      requirement: 25,
      isRare: true,
    ),

    // Идеальные игры
    Achievement(
      id: 'perfect_1',
      title: 'Перфекционист',
      description: 'Выиграй игру без ошибок',
      icon: '💯',
      type: AchievementType.perfectGame,
      requirement: 1,
    ),
    Achievement(
      id: 'perfect_5',
      title: 'Мастер точности',
      description: 'Выиграй 5 игр без ошибок',
      icon: '🎯',
      type: AchievementType.perfectGame,
      requirement: 5,
      isRare: true,
    ),

    // Очки
    Achievement(
      id: '100_points',
      title: 'Старт',
      description: 'Набери 100 очков',
      icon: '⭐',
      type: AchievementType.points,
      requirement: 100,
    ),
    Achievement(
      id: '1000_points',
      title: 'Лидер',
      description: 'Набери 1000 очков',
      icon: '💎',
      type: AchievementType.points,
      requirement: 1000,
    ),
    Achievement(
      id: '5000_points',
      title: 'Чемпион',
      description: 'Набери 5000 очков',
      icon: '🏆',
      type: AchievementType.points,
      requirement: 5000,
      isRare: true,
    ),
    Achievement(
      id: '10000_points',
      title: 'Легенда',
      description: 'Набери 10000 очков',
      icon: '👑',
      type: AchievementType.points,
      requirement: 10000,
      isRare: true,
    ),

    // Уровни
    Achievement(
      id: 'level_5',
      title: 'Новичок',
      description: 'Достигни 5 уровня',
      icon: '🔰',
      type: AchievementType.level,
      requirement: 5,
    ),
    Achievement(
      id: 'level_10',
      title: 'Продвинутый',
      description: 'Достигни 10 уровня',
      icon: '🎖️',
      type: AchievementType.level,
      requirement: 10,
    ),
    Achievement(
      id: 'level_25',
      title: 'Эксперт',
      description: 'Достигни 25 уровня',
      icon: '🏅',
      type: AchievementType.level,
      requirement: 25,
      isRare: true,
    ),
  ];
}
