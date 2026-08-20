from django.db import transaction
from django.utils import timezone
from rest_framework import generics, permissions, status
from rest_framework.response import Response
from rest_framework.views import APIView

from apps.quizzes.models import Category

from .models import Achievement, DailyBonus, GameSession, PlayerAchievement, PlayerProfile
from .serializers import (
    AchievementSerializer,
    DailyBonusSerializer,
    GameSessionSerializer,
    PlayerAchievementSerializer,
    PlayerProfileSerializer,
    SubmitGameSerializer,
)


def get_or_create_profile(user) -> PlayerProfile:
    """DRY helper – get or create PlayerProfile for a user."""
    profile, _ = PlayerProfile.objects.get_or_create(user=user)
    return profile


# ──────────────────────── Profile ────────────────────────


class PlayerProfileView(generics.RetrieveAPIView):
    """GET /api/progress/profile/"""

    serializer_class = PlayerProfileSerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_object(self):
        return get_or_create_profile(self.request.user)


# ──────────────────────── Game ───────────────────────────


class SubmitGameView(APIView):
    """POST /api/progress/game/submit/"""

    permission_classes = [permissions.IsAuthenticated]

    @transaction.atomic
    def post(self, request):
        serializer = SubmitGameSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        data = serializer.validated_data

        profile = get_or_create_profile(request.user)

        # Check lives
        profile.refill_lives()
        if profile.lives <= 0:
            return Response(
                {"detail": "Нет жизней. Подождите или купите."},
                status=status.HTTP_403_FORBIDDEN,
            )

        category = Category.objects.filter(id=data["category_id"], is_active=True).first()
        if not category:
            return Response({"detail": "Категория не найдена"}, status=status.HTTP_404_NOT_FOUND)

        correct = data["correct_answers"]
        total = data["total_answers"]
        is_perfect = correct == total

        # Points calculation
        points = correct * 10
        if is_perfect:
            points += 50  # Perfect bonus

        # Update profile
        profile.total_points += points
        profile.level = profile.calculate_level()
        profile.games_played += 1
        profile.correct_answers += correct
        profile.total_answers += total
        profile.last_played_at = timezone.now()
        profile.lives -= 1
        profile.last_life_refill = timezone.now()

        # Streak logic
        if is_perfect:
            profile.current_streak += 1
            if profile.current_streak > profile.best_streak:
                profile.best_streak = profile.current_streak
        else:
            profile.current_streak = 0

        profile.save()

        # Record session
        result = GameSession.Result.PERFECT if is_perfect else (
            GameSession.Result.WIN if correct >= total / 2 else GameSession.Result.LOSS
        )
        GameSession.objects.create(
            player=profile,
            category=category,
            result=result,
            correct_answers=correct,
            total_answers=total,
            points_earned=points,
        )

        # Check achievements
        new_achievements = _check_achievements(profile, is_perfect)

        return Response({
            "points_earned": points,
            "is_perfect": is_perfect,
            "profile": PlayerProfileSerializer(profile).data,
            "new_achievements": PlayerAchievementSerializer(new_achievements, many=True).data,
        })


class LivesView(APIView):
    """GET /api/progress/lives/"""

    permission_classes = [permissions.IsAuthenticated]

    def get(self, request):
        profile = get_or_create_profile(request.user)
        profile.refill_lives()
        return Response({"lives": profile.lives, "max_lives": PlayerProfile.MAX_LIVES})


# ──────────────────────── Achievements ───────────────────


class AchievementListView(generics.ListAPIView):
    """GET /api/progress/achievements/"""

    queryset = Achievement.objects.all()
    serializer_class = AchievementSerializer
    permission_classes = [permissions.AllowAny]
    pagination_class = None


class PlayerAchievementListView(generics.ListAPIView):
    """GET /api/progress/achievements/mine/"""

    serializer_class = PlayerAchievementSerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_queryset(self):
        profile = get_or_create_profile(self.request.user)
        return PlayerAchievement.objects.filter(player=profile).select_related("achievement")


# ──────────────────────── Daily Bonus ────────────────────


class DailyBonusView(APIView):
    """POST /api/progress/daily-bonus/"""

    permission_classes = [permissions.IsAuthenticated]

    def post(self, request):
        profile = get_or_create_profile(request.user)
        today = timezone.now().date()

        already_claimed = DailyBonus.objects.filter(
            player=profile,
            claimed_at__date=today,
        ).exists()

        if already_claimed:
            return Response(
                {"detail": "Бонус уже получен сегодня"},
                status=status.HTTP_400_BAD_REQUEST,
            )

        bonus_amount = 50
        DailyBonus.objects.create(player=profile, bonus_amount=bonus_amount)

        profile.total_points += bonus_amount
        profile.level = profile.calculate_level()
        profile.save(update_fields=["total_points", "level"])

        return Response({
            "bonus_amount": bonus_amount,
            "profile": PlayerProfileSerializer(profile).data,
        })


# ──────────────────────── Leaderboard ────────────────────


class LeaderboardView(generics.ListAPIView):
    """GET /api/progress/leaderboard/"""

    serializer_class = PlayerProfileSerializer
    permission_classes = [permissions.AllowAny]
    pagination_class = None

    def get_queryset(self):
        return PlayerProfile.objects.select_related("user").order_by("-total_points")[:50]


# ──────────────────────── History ────────────────────────


class GameHistoryView(generics.ListAPIView):
    """GET /api/progress/history/"""

    serializer_class = GameSessionSerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_queryset(self):
        profile = get_or_create_profile(self.request.user)
        return GameSession.objects.filter(player=profile).select_related("category")


# ──────────────────────── Helpers (DRY) ──────────────────


def _check_achievements(profile: PlayerProfile, is_perfect: bool):
    """Check and unlock new achievements. Returns newly unlocked."""
    unlocked_ids = set(
        PlayerAchievement.objects.filter(player=profile).values_list("achievement_id", flat=True)
    )
    achievements = Achievement.objects.exclude(id__in=unlocked_ids)
    new_achievements = []

    for ach in achievements:
        should_unlock = False

        match ach.achievement_type:
            case Achievement.AchievementType.GAMES_PLAYED:
                should_unlock = profile.games_played >= ach.requirement
            case Achievement.AchievementType.CORRECT_ANSWERS:
                should_unlock = profile.correct_answers >= ach.requirement
            case Achievement.AchievementType.STREAK:
                should_unlock = profile.best_streak >= ach.requirement
            case Achievement.AchievementType.PERFECT_GAME:
                should_unlock = is_perfect and profile.games_played >= ach.requirement
            case Achievement.AchievementType.POINTS:
                should_unlock = profile.total_points >= ach.requirement
            case Achievement.AchievementType.LEVEL:
                should_unlock = profile.level >= ach.requirement

        if should_unlock:
            pa = PlayerAchievement.objects.create(player=profile, achievement=ach)
            new_achievements.append(pa)

    return new_achievements
