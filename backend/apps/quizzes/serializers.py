import random

from rest_framework import serializers

from .models import Category, Question


class QuestionSerializer(serializers.ModelSerializer):
    options = serializers.DictField(source="options", read_only=True)

    class Meta:
        model = Question
        fields = ("id", "text", "options", "correct_option", "difficulty")
        # correct_option is intentionally kept for game validation
        # but can be excluded from public list endpoints if needed


class CategoryListSerializer(serializers.ModelSerializer):
    question_count = serializers.IntegerField(read_only=True, source="questions.count")

    class Meta:
        model = Category
        fields = ("id", "name", "slug", "description", "image", "question_count")


class CategoryDetailSerializer(serializers.ModelSerializer):
    questions = serializers.SerializerMethodField()

    class Meta:
        model = Category
        fields = ("id", "name", "slug", "description", "image", "questions")

    def get_questions(self, obj):
        qs = obj.questions.filter(is_active=True)
        # Shuffle for gameplay
        questions = list(qs)
        random.shuffle(questions)
        return QuestionSerializer(questions, many=True).data
