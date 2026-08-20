from rest_framework import generics, permissions

from .models import Category, Question
from .serializers import CategoryDetailSerializer, CategoryListSerializer


class CategoryListView(generics.ListAPIView):
    """GET /api/quizzes/categories/"""

    queryset = Category.objects.filter(is_active=True)
    serializer_class = CategoryListSerializer
    permission_classes = [permissions.AllowAny]
    pagination_class = None  # Return all categories


class CategoryDetailView(generics.RetrieveAPIView):
    """GET /api/quizzes/categories/{slug}/"""

    queryset = Category.objects.filter(is_active=True)
    serializer_class = CategoryDetailSerializer
    lookup_field = "slug"
    permission_classes = [permissions.AllowAny]
