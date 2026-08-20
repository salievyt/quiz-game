import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:quiz/core/router/route_names.dart';
import 'package:quiz/data/models/game_data.dart';
import 'package:quiz/domain/providers/game_provider.dart';
import 'package:quiz/presentation/screens/categories/categories_screen.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black87;
    final secondaryTextColor = isDark ? Colors.grey[400] : Colors.grey[600];
    final gameData = GameData();
    final gameDataState = ref.watch(gameProvider).value;

    final List<_CategoryItem> categories = [
      _CategoryItem(name: gameData.gameNames[0], image: 'assets/images/logic.jpg', desc: 'Тренируй логику и мышление', id: 1, heroTag: 'cat_1'),
      _CategoryItem(name: gameData.gameNames[1], image: 'assets/images/geeks.jpg', desc: 'Проверь свои знания в IT', id: 2, heroTag: 'cat_2'),
      _CategoryItem(name: gameData.gameNames[2], image: 'assets/images/jun.jpg', desc: 'Викторина для самых маленьких', id: 3, heroTag: 'cat_3'),
      _CategoryItem(name: gameData.gameNames[3], image: 'assets/images/islam.jpg', desc: 'Основы ислама', id: 4, heroTag: 'cat_4'),
      _CategoryItem(name: gameData.gameNames[4], image: 'assets/images/designer.jpg', desc: 'Мир дизайна и креатива', id: 5, heroTag: 'cat_5'),
      _CategoryItem(name: gameData.gameNames[5], image: 'assets/images/cosmos.jpg', desc: 'Путешествие по космосу', id: 6, heroTag: 'cat_6'),
      _CategoryItem(name: gameData.gameNames[6], image: 'assets/images/science.jpg', desc: 'Научные открытия и факты', id: 7, heroTag: 'cat_7'),
      _CategoryItem(name: gameData.gameNames[7], image: 'assets/images/socialMedia.jpg', desc: 'Мир социальных сетей', id: 8, heroTag: 'cat_8'),
      _CategoryItem(name: gameData.gameNames[8], image: 'assets/images/history.jpg', desc: 'Исторические события', id: 9, heroTag: 'cat_9'),
      _CategoryItem(name: gameData.gameNames[9], image: 'assets/images/music.jpg', desc: 'Музыкальная викторина', id: 10, heroTag: 'cat_10'),
      _CategoryItem(name: gameData.gameNames[10], image: 'assets/images/geography.jpg', desc: 'География нашей планеты', id: 11, heroTag: 'cat_11'),
      _CategoryItem(name: gameData.gameNames[11], image: 'assets/images/speedRun.png', desc: 'Быстрая игра на время', id: 12, heroTag: 'cat_12'),
    ];

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F0F1A) : const Color(0xFFF4F6FA),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                child: Text(
                  'Выбери категорию',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                child: Text(
                  'Играй и узнавай новое!',
                  style: TextStyle(fontSize: 16, color: secondaryTextColor),
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 0.85,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final cat = categories[index];
                    final totalQ = gameData.getQuestionCount(cat.id);
                    final answered = gameDataState?.categoryProgress[cat.id] ?? 0;
                    final progress = totalQ > 0 ? (answered / totalQ).clamp(0.0, 1.0) : 0.0;

                    return _CategoryCard(
                      category: cat,
                      isDark: isDark,
                      progress: progress,
                      answered: answered,
                      total: totalQ,
                      onTap: () => context.push(
                        '${RouteNames.categories}/${cat.id}',
                        extra: CategoryExtra(
                          name: cat.name,
                          image: cat.image,
                          desc: cat.desc,
                          heroTag: cat.heroTag,
                        ),
                      ),
                    );
                  },
                  childCount: categories.length,
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 20)),
          ],
        ),
      ),
    );
  }
}

class _CategoryItem {
  final String name;
  final String image;
  final String desc;
  final int id;
  final String heroTag;

  const _CategoryItem({
    required this.name,
    required this.image,
    required this.desc,
    required this.id,
    required this.heroTag,
  });
}

class _CategoryCard extends StatelessWidget {
  final _CategoryItem category;
  final bool isDark;
  final double progress;
  final int answered;
  final int total;
  final VoidCallback onTap;

  const _CategoryCard({
    required this.category,
    required this.isDark,
    required this.progress,
    required this.answered,
    required this.total,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final textColor = isDark ? Colors.white : Colors.black87;

    return GestureDetector(
      onTap: onTap,
      child: Hero(
        tag: category.heroTag,
        child: Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1A1A2E) : Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: isDark
                    ? Colors.black.withValues(alpha: 0.5)
                    : Colors.black.withValues(alpha: 0.08),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(16),
                      ),
                      child: Image.asset(
                        category.image,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: isDark
                                ? const Color(0xFF252540)
                                : Colors.grey[200],
                            child: Icon(
                              Icons.quiz,
                              size: 50,
                              color: isDark
                                  ? Colors.grey[600]
                                  : Colors.grey[400],
                            ),
                          );
                        },
                      ),
                    ),
                    // Прогресс-бар внизу картинки
                    if (progress > 0)
                      Positioned(
                        left: 0,
                        right: 0,
                        bottom: 0,
                        child: Container(
                          height: 4,
                          decoration: const BoxDecoration(
                            borderRadius: BorderRadius.vertical(
                              top: Radius.circular(2),
                            ),
                          ),
                          child: LinearProgressIndicator(
                            value: progress,
                            backgroundColor: Colors.black.withValues(alpha: 0.3),
                            valueColor: const AlwaysStoppedAnimation(
                                Color(0xFF7ED421)),
                            minHeight: 4,
                          ),
                        ),
                      ),
                    // Бейдж прогресса
                    if (progress > 0)
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.6),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '$answered/$total',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(10),
                child: Text(
                  category.name,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
