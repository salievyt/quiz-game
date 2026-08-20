from django.urls import path

from . import views

app_name = "progress"

urlpatterns = [
    path("profile/", views.PlayerProfileView.as_view(), name="profile"),
    path("game/submit/", views.SubmitGameView.as_view(), name="submit-game"),
    path("lives/", views.LivesView.as_view(), name="lives"),
    path("achievements/", views.AchievementListView.as_view(), name="achievement-list"),
    path("achievements/mine/", views.PlayerAchievementListView.as_view(), name="player-achievements"),
    path("daily-bonus/", views.DailyBonusView.as_view(), name="daily-bonus"),
    path("leaderboard/", views.LeaderboardView.as_view(), name="leaderboard"),
    path("history/", views.GameHistoryView.as_view(), name="history"),
]
