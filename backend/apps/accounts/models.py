from django.contrib.auth.models import AbstractUser
from django.db import models
from django.utils.translation import gettext_lazy as _


class User(AbstractUser):
    """Custom user model for Quizzy."""

    class Meta:
        verbose_name = _("пользователь")
        verbose_name_plural = _("пользователи")
        ordering = ["-date_joined"]

    def __str__(self):
        return self.username or self.email


class UserProfile(models.Model):
    """Extended profile data tied to a User."""

    user = models.OneToOneField(
        User,
        on_delete=models.CASCADE,
        related_name="profile",
        verbose_name=_("пользователь"),
    )
    avatar = models.ImageField(
        upload_to="avatars/%Y/%m/",
        blank=True,
        null=True,
        verbose_name=_("аватар"),
    )
    preferred_locale = models.CharField(
        max_length=5,
        default="ru",
        choices=[("ru", "Русский"), ("en", "English")],
        verbose_name=_("язык"),
    )

    class Meta:
        verbose_name = _("профиль")
        verbose_name_plural = _("профили")

    def __str__(self):
        return f"Профиль {self.user.username}"
