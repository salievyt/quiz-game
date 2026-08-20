from django.contrib import admin
from django.utils.translation import gettext_lazy as _

from .models import Category, Question


class QuestionInline(admin.TabularInline):
    model = Question
    extra = 1
    fields = ("text", "option_a", "option_b", "option_c", "option_d", "correct_option", "difficulty", "is_active")


@admin.register(Category)
class CategoryAdmin(admin.ModelAdmin):
    list_display = ("name", "slug", "question_count", "order", "is_active")
    list_filter = ("is_active",)
    search_fields = ("name", "description")
    prepopulated_fields = {"slug": ("name",)}
    inlines = [QuestionInline]
    ordering = ("order", "name")

    @admin.display(description=_("Кол-во вопросов"))
    def question_count(self, obj):
        return obj.questions.count()


@admin.register(Question)
class QuestionAdmin(admin.ModelAdmin):
    list_display = ("short_text", "category", "correct_option", "difficulty", "is_active")
    list_filter = ("category", "difficulty", "is_active")
    search_fields = ("text",)
    list_editable = ("is_active",)

    @admin.display(description=_("Вопрос"))
    def short_text(self, obj):
        return obj.text[:60] + ("…" if len(obj.text) > 60 else "")
