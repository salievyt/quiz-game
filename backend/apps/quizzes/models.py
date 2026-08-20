from django.core.validators import MinValueValidator, MaxValueValidator
from django.db import models
from django.utils.translation import gettext_lazy as _


class Category(models.Model):
    """Quiz category (e.g. Логика, География, etc.)."""

    name = models.CharField(max_length=100, unique=True, verbose_name=_("название"))
    slug = models.SlugField(max_length=100, unique=True, verbose_name=_("слаг"))
    description = models.TextField(blank=True, default="", verbose_name=_("описание"))
    image = models.URLField(
        blank=True,
        default="",
        verbose_name=_("URL изображения"),
    )
    order = models.PositiveIntegerField(default=0, verbose_name=_("порядок"))
    is_active = models.BooleanField(default=True, verbose_name=_("активна"))
    created_at = models.DateTimeField(auto_now_add=True, verbose_name=_("создана"))

    class Meta:
        verbose_name = _("категория")
        verbose_name_plural = _("категории")
        ordering = ["order", "name"]

    def __str__(self):
        return self.name


class Question(models.Model):
    """A single quiz question with 4 answer options."""

    category = models.ForeignKey(
        Category,
        on_delete=models.CASCADE,
        related_name="questions",
        verbose_name=_("категория"),
    )
    text = models.TextField(verbose_name=_("текст вопроса"))
    option_a = models.CharField(max_length=300, verbose_name=_("вариант A"))
    option_b = models.CharField(max_length=300, verbose_name=_("вариант B"))
    option_c = models.CharField(max_length=300, verbose_name=_("вариант C"))
    option_d = models.CharField(max_length=300, verbose_name=_("вариант D"))
    correct_option = models.CharField(
        max_length=1,
        choices=[("a", "A"), ("b", "B"), ("c", "C"), ("d", "D")],
        verbose_name=_("правильный ответ"),
    )
    difficulty = models.PositiveSmallIntegerField(
        default=1,
        validators=[MinValueValidator(1), MaxValueValidator(3)],
        verbose_name=_("сложность"),
        help_text=_("1 — лёгкий, 2 — средний, 3 — сложный"),
    )
    is_active = models.BooleanField(default=True, verbose_name=_("активен"))
    created_at = models.DateTimeField(auto_now_add=True, verbose_name=_("создан"))

    class Meta:
        verbose_name = _("вопрос")
        verbose_name_plural = _("вопросы")
        ordering = ["category", "id"]

    def __str__(self):
        return f"[{self.category}] {self.text[:80]}"

    @property
    def options(self) -> dict[str, str]:
        return {
            "a": self.option_a,
            "b": self.option_b,
            "c": self.option_c,
            "d": self.option_d,
        }
