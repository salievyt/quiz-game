from rest_framework import serializers

from .models import Achievement, DailyBonus, GameSession, PlayerAchievement, PlayerProfile


class PlayerProfileSerializer(serializers.ModelSerializer):
    accuracy = serializers.FloatField(read_only=True)
    points_for_next_level = serializers.IntegerField(read_only=True)

    class Meta:
        model = PlayerProfile
        fields = (
            "total_points",
            "level",
            "games_played",
            "correct_answers",
            "total_answers",
            "best_streak",
            "current_streak",
            "lives",
            "accuracy",
            "points_for_next_level",
            "last_played_at",
        )
        read_only_fields = fields


class AchievementSerializer(serializers.ModelSerializer):
    class Meta:
        model = Achievement
        fields = ("uid", "title", "description", "icon", "achievement_type", "requirement", "is_rare")


class PlayerAchievementSerializer(serializers.ModelSerializer):
    achievement = AchievementSerializer(read_only=True)

    class Meta:
        model = PlayerAchievement
        fields = ("achievement", "unlocked_at")


class GameSessionSerializer(serializers.ModelSerializer):
    class Meta:
        model = GameSession
        fields = (
            "id",
            "category",
            "result",
            "correct_answers",
            "total_answers",
            "points_earned",
            "played_at",
        )
        read_only_fields = ("id", "played_at")


class SubmitGameSerializer(serializers.Serializer):
    """Input serializer for submitting game results."""

    category_id = serializers.IntegerField()
    correct_answers = serializers.IntegerField(min_value=0)
    total_answers = serializers.IntegerField(min_value=1)

    def validate(self, attrs):
        if attrs["correct_answers"] > attrs["total_answers"]:
            raise serializers.ValidationError("correct_answers cannot exceed total_answers")
        return attrs


class DailyBonusSerializer(serializers.ModelSerializer):
    class Meta:
        model = DailyBonus
        fields = ("bonus_amount", "claimed_at")
        read_only_fields = fields
