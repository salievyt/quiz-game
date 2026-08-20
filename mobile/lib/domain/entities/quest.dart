enum QuestType {
  playGames,
  correctAnswers,
  perfectGames,
  points,
}

class Quest {
  final String id;
  final String title;
  final String description;
  final QuestType type;
  final int requirement;
  final int reward;
  final String icon;

  const Quest({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.requirement,
    required this.reward,
    required this.icon,
  });

  static List<Quest> get dailyQuests => [
        const Quest(
          id: 'daily_play_1',
          title: 'Первая игра',
          description: 'Сыграй 1 игру',
          type: QuestType.playGames,
          requirement: 1,
          reward: 25,
          icon: '🎮',
        ),
        const Quest(
          id: 'daily_play_3',
          title: 'Три игры',
          description: 'Сыграй 3 игры',
          type: QuestType.playGames,
          requirement: 3,
          reward: 50,
          icon: '🎯',
        ),
        const Quest(
          id: 'daily_correct_10',
          title: 'Знаток',
          description: 'Дай 10 правильных ответов',
          type: QuestType.correctAnswers,
          requirement: 10,
          reward: 30,
          icon: '✅',
        ),
        const Quest(
          id: 'daily_perfect_1',
          title: 'Перфекционист',
          description: 'Выиграй 1 игру без ошибок',
          type: QuestType.perfectGames,
          requirement: 1,
          reward: 75,
          icon: '💯',
        ),
        const Quest(
          id: 'daily_points_100',
          title: 'Набор очков',
          description: 'Набери 100 очков',
          type: QuestType.points,
          requirement: 100,
          reward: 40,
          icon: '⭐',
        ),
      ];
}
