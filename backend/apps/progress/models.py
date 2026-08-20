from django.conf import settings
from django.db import models
from django.utils import timezone
from django.utils.translation import gettext_lazy as _


class PlayerProfile(models.Model):
    """Per-user game statistics and progression."""

    user = models.OneToOneField(
        settings.AUTH_USER_MODEL,
        on_delete=models.CASCADE,
        related_name="game_profile",
        verbose_name=_("пользователь"),
    )
    total_points = models.PositiveIntegerField(default=0, verbose_name=_("очки"))
    level = models.PositiveIntegerField(default=1, verbose_name=_("уровень"))
    games_played = models.PositiveIntegerField(default=0, verbose_name=_("игр сыграно"))
    correct_answers = models.PositiveIntegerField(default=0, verbose_name=_("правильных ответов"))
    total_answers = models.PositiveIntegerField(default=0, verbose_name=_("всего ответов"))
    best_streak = models.PositiveIntegerField(default=0, verbose_name=_("лучшая серия"))
    current_streak = models.PositiveIntegerField(default=0, verbose_name=_("текущая серия"))
    lives = models.PositiveSmallIntegerField(default=5, verbose_name=_("жизни"))
    last_life_refill = models.DateTimeField(default=timezone.now, verbose_name=_("последнее пополнение жизней"))
    last_played_at = models.DateTimeField(null=True, blank=True, verbose_name=_("последняя игра"))
    created_at = models.DateTimeField(auto_now_add=True, verbose_name=_("создан"))
    updated_at = models.DateTimeField(auto_now=True, verbose_name=_("обновлён"))

    MAX_LIVES = 5
    LIFE_REFILL_MINUTES = 30

    class Meta:
        verbose_name = _("профиль игрока")
        verbose_name_plural = _("профили игроков")

    def __str__(self):
        return f"{self.user.username} — {self.total_points} pts, Lvl {self.level}"

    @property
    def accuracy(self) -> float:
        return self.correct_answers / self.total_answers if self.total_answers else 0.0

    @property
    def points_for_next_level(self) -> int:
        return self.level * 100

    def calculate_level(self) -> int:
        level = 1
        required = 100
        while self.total_points >= required:
            level += 1
            required += level * 100
        return level

    def refill_lives(self) -> int:
        """Refill lives based on elapsed time. Returns current lives count."""
        if self.lives >= self.MAX_LIVES:
            return self.lives
        elapsed = timezone.now() - self.last_life_refill
        restored = int(elapsed.total_seconds() // (self.LIFE_REFILL_MINUTES * 60))
        if restored > 0:
            self.lives = min(self.lives + restored, self.MAX_LIVES)
            self.last_life_refill = timezone.now()
            self.save(update_fields=["lives", "last_life_refill"])
        return self.lives


class Achievement(models.Model):
    """Achievement definition."""

    class AchievementType(models.TextChoices):
        GAMES_PLAYED = "games_played", _("Игры")
        CORRECT_ANSWERS = "correct_answers", _("Правильные ответы")
        STREAK = "streak", _("Серия побед")
        PERFECT_GAME = "perfect_game", _("Идеальная игра")
        POINTS = "points", _("Очки")
        LEVEL = "level", _("Уровень")

    uid = models.CharField(max_length=50, unique=True, verbose_name=_("идентификатор"))
    title = models.CharField(max_length=100, verbose_name=_("название"))
    description = models.TextField(verbose_name=_("описание"))
    icon = models.CharField(max_length=10, verbose_name=_("иконка"))
    achievement_type = models.CharField(
        max_length=20,
        choices=AchievementType.choices,
        verbose_name=_("тип"),
    )
    requirement = models.PositiveIntegerField(verbose_name=_("порог"))
    is_rare = models.BooleanField(default=False, verbose_name=_("редкое"))

    class Meta:
        verbose_name = _("достижение")
        verbose_name_plural = _("достижения")
        ordering = ["requirement"]

    def __str__(self):
        return f"{self.icon} {self.title}"


class PlayerAchievement(models.Model):
    """Tracks which achievements a player has unlocked."""

    player = models.ForeignKey(
        PlayerProfile,
        on_delete=models.CASCADE,
        related_name="achievements",
        verbose_name=_("игрок"),
    )
    achievement = models.ForeignKey(
        Achievement,
        on_delete=models.CASCADE,
        verbose_name=_("достижение"),
    )
    unlocked_at = models.DateTimeField(auto_now_add=True, verbose_name=_("разблокировано"))

    class Meta:
        verbose_name = _("достижение игрока")
        verbose_name_plural = _("достижения игроков")
        unique_together = ("player", "achievement")

    def __str__(self):
        return f"{self.player} — {self.achievement}"


class GameSession(models.Model):
    """Records a single completed game session."""

    class Result(models.TextChoices):
        WIN = "win", _("Победа")
        LOSS = "loss", _("Проигрыш")
        PERFECT = "perfect", _("Идеально")

    player = models.ForeignKey(
        PlayerProfile,
        on_delete=models.CASCADE,
        related_name="sessions",
        verbose_name=_("игрок"),
    )
    category = models.ForeignKey(
        "quizzes.Category",
        on_delete=models.SET_NULL,
        null=True,
        verbose_name=_("категория"),
    )
    result = models.CharField(
        max_length=7,
        choices=Result.choices,
        verbose_name=_("результат"),
    )
    correct_answers = models.PositiveSmallIntegerField(verbose_name=_("правильных"))
    total_answers = models.PositiveSmallIntegerField(verbose_name=_("всего"))
    points_earned = models.PositiveIntegerField(default=0, verbose_name=_("очки"))
    played_at = models.DateTimeField(auto_now_add=True, verbose_name=_("дата"))

    class Meta:
        verbose_name = _("сессия игры")
        verbose_name_plural = _("сессии игр")
        ordering = ["-played_at"]

    def __str__(self):
        return f"{self.player.user.username} — {self.category} ({self.result})"


class DailyBonus(models.Model):
    """Tracks daily bonus claims."""

    player = models.ForeignKey(
        PlayerProfile,
        on_delete=models.CASCADE,
        related_name="daily_bonuses",
        verbose_name=_("игрок"),
    )
    claimed_at = models.DateTimeField(auto_now_add=True, verbose_name=_("дата получения"))
    bonus_amount = models.PositiveIntegerField(default=50, verbose_name=_("сумма"))

    class Meta:
        verbose_name = _("ежедневный бонус")
        verbose_name_plural = _("ежедневные бонусы")
        unique_together = (
            "player",
            # Prevent double-claim same day via view logic
        )

    def __str__(self):
        return f"{self.player.user.username} — +{self.bonus_amount}"
