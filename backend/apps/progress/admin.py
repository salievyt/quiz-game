from django.contrib import admin
from django.utils.translation import gettext_lazy as _

from .models import Achievement, DailyBonus, GameSession, PlayerAchievement, PlayerProfile


@admin.register(PlayerProfile)
class PlayerProfileAdmin(admin.ModelAdmin):
    list_display = ("user", "total_points", "level", "games_played", "lives", "accuracy_display")
    list_filter = ("level",)
    search_fields = ("user__username", "user__email")
    readonly_fields = ("created_at", "updated_at")
    raw_id_fields = ("user",)

    @admin.display(description=_("Точность"))
    def accuracy_display(self, obj):
        return f"{obj.accuracy:.0%}"


@admin.register(Achievement)
class AchievementAdmin(admin.ModelAdmin):
    list_display = ("icon", "title", "achievement_type", "requirement", "is_rare")
    list_filter = ("achievement_type", "is_rare")
    search_fields = ("title", "description")


@admin.register(PlayerAchievement)
class PlayerAchievementAdmin(admin.ModelAdmin):
    list_display = ("player", "achievement", "unlocked_at")
    list_filter = ("achievement__achievement_type",)
    raw_id_fields = ("player", "achievement")


@admin.register(GameSession)
class GameSessionAdmin(admin.ModelAdmin):
    list_display = ("player", "category", "result", "correct_answers", "total_answers", "points_earned", "played_at")
    list_filter = ("result", "category")
    search_fields = ("player__user__username",)
    raw_id_fields = ("player", "category")
    readonly_fields = ("played_at",)


@admin.register(DailyBonus)
class DailyBonusAdmin(admin.ModelAdmin):
    list_display = ("player", "bonus_amount", "claimed_at")
    raw_id_fields = ("player",)
    readonly_fields = ("claimed_at",)
