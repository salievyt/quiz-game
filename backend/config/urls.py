from django.conf import settings
from django.conf.urls.static import static
from django.contrib import admin
from django.urls import include, path
from rest_framework_simplejwt.views import TokenObtainPairView, TokenRefreshView

urlpatterns = [
    # ── Admin (Jazzmin) ──
    path("admin/", admin.site.urls),

    # ── JWT Auth ──
    path("api/auth/token/", TokenObtainPairView.as_view(), name="token-obtain"),
    path("api/auth/token/refresh/", TokenRefreshView.as_view(), name="token-refresh"),

    # ── App APIs ──
    path("api/auth/", include("apps.accounts.urls")),
    path("api/quizzes/", include("apps.quizzes.urls")),
    path("api/progress/", include("apps.progress.urls")),
]

if settings.DEBUG:
    urlpatterns += static(settings.MEDIA_URL, document_root=settings.MEDIA_ROOT)
