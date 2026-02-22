class PlayerProgress {
  final int totalPoints;
  final int level;
  final int gamesPlayed;
  final int correctAnswers;
  final int totalAnswers;
  final int bestStreak;
  final int currentStreak;
  final DateTime? lastPlayedAt;

  PlayerProgress({
    this.totalPoints = 0,
    this.level = 1,
    this.gamesPlayed = 0,
    this.correctAnswers = 0,
    this.totalAnswers = 0,
    this.bestStreak = 0,
    this.currentStreak = 0,
    this.lastPlayedAt,
  });

  double get accuracy => totalAnswers > 0 ? correctAnswers / totalAnswers : 0;

  int get pointsForNextLevel => level * 100;

  double get levelProgress => (totalPoints % pointsForNextLevel) / pointsForNextLevel;

  PlayerProgress copyWith({
    int? totalPoints,
    int? level,
    int? gamesPlayed,
    int? correctAnswers,
    int? totalAnswers,
    int? bestStreak,
    int? currentStreak,
    DateTime? lastPlayedAt,
  }) {
    return PlayerProgress(
      totalPoints: totalPoints ?? this.totalPoints,
      level: level ?? this.level,
      gamesPlayed: gamesPlayed ?? this.gamesPlayed,
      correctAnswers: correctAnswers ?? this.correctAnswers,
      totalAnswers: totalAnswers ?? this.totalAnswers,
      bestStreak: bestStreak ?? this.bestStreak,
      currentStreak: currentStreak ?? this.currentStreak,
      lastPlayedAt: lastPlayedAt ?? this.lastPlayedAt,
    );
  }

  Map<String, dynamic> toJson() => {
    'totalPoints': totalPoints,
    'level': level,
    'gamesPlayed': gamesPlayed,
    'correctAnswers': correctAnswers,
    'totalAnswers': totalAnswers,
    'bestStreak': bestStreak,
    'currentStreak': currentStreak,
    'lastPlayedAt': lastPlayedAt?.toIso8601String(),
  };

  factory PlayerProgress.fromJson(Map<String, dynamic> json) => PlayerProgress(
    totalPoints: json['totalPoints'] ?? 0,
    level: json['level'] ?? 1,
    gamesPlayed: json['gamesPlayed'] ?? 0,
    correctAnswers: json['correctAnswers'] ?? 0,
    totalAnswers: json['totalAnswers'] ?? 0,
    bestStreak: json['bestStreak'] ?? 0,
    currentStreak: json['currentStreak'] ?? 0,
    lastPlayedAt: json['lastPlayedAt'] != null 
        ? DateTime.tryParse(json['lastPlayedAt']) 
        : null,
  );
}
