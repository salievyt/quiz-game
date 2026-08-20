import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:quiz/core/router/route_names.dart';

/// Данные категории, передаваемые через GoRouter extra
class CategoryExtra {
  final String name;
  final String image;
  final String desc;
  final String heroTag;

  const CategoryExtra({
    required this.name,
    required this.image,
    required this.desc,
    required this.heroTag,
  });
}

class CategoriesScreen extends StatelessWidget {
  final int id;

  const CategoriesScreen({super.key, required this.id});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDark ? const Color(0xFF0F0F1A) : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black87;
    final secondaryTextColor = isDark ? Colors.grey[400] : Colors.grey[600];

    final extra = GoRouterState.of(context).extra as CategoryExtra?;

    final category = extra?.name ?? 'Категория $id';
    final image = extra?.image ?? '';
    final desc = extra?.desc ?? '';
    final heroTag = extra?.heroTag ?? 'cat_$id';

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        title: Text(
          category,
          style: TextStyle(fontSize: 22, color: textColor),
        ),
        centerTitle: true,
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: Icon(Icons.arrow_back_ios_new, color: textColor),
        ),
      ),
      body: Container(
        margin: const EdgeInsets.symmetric(horizontal: 10),
        child: Column(
          children: [
            Hero(
              tag: heroTag,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: isDark
                          ? Colors.black.withValues(alpha: 0.5)
                          : Colors.black.withValues(alpha: 0.1),
                      blurRadius: 15,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.asset(
                    image,
                    height: 250,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: 250,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: isDark
                              ? const Color(0xFF1A1A2E)
                              : Colors.grey[200],
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Icon(
                          Icons.quiz,
                          size: 80,
                          color: isDark ? Colors.grey[600] : Colors.grey[400],
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              desc,
              style: TextStyle(fontSize: 18, color: secondaryTextColor),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () => context.push('${RouteNames.game}/$id'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF7ED421),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                minimumSize: const Size(double.infinity, 60),
                elevation: isDark ? 0 : 4,
                shadowColor: isDark
                    ? Colors.transparent
                    : const Color(0xFF7ED421),
              ),
              child: const Text('Начать играть', style: TextStyle(fontSize: 18)),
            ),
          ],
        ),
      ),
    );
  }
}
