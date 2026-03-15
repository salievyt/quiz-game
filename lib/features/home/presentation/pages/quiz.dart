import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:quiz/features/home/presentation/viewmodels/home_viewmodel.dart';
import 'package:quiz/features/game/presentation/pages/speedrun.dart';
import 'package:quiz/ui/utils/categories.dart';

class Quiz extends StatefulWidget {
  const Quiz({super.key});

  @override
  State<Quiz> createState() => _QuizState();
}

class _QuizState extends State<Quiz> with TickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..forward();

    // Fetch categories from backend
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HomeViewModel>().fetchCategories();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final homeViewModel = context.watch<HomeViewModel>();

    final backgroundColor = isDark
        ? const Color(0xFF0F0F1A)
        : const Color(0xFFF4F6FA);
    final cardColor = isDark ? const Color(0xFF1A1A2E) : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black87;

    if (homeViewModel.isLoading) {
      return Scaffold(
        backgroundColor: backgroundColor,
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (homeViewModel.error != null) {
      return Scaffold(
        backgroundColor: backgroundColor,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("Ошибка: ${homeViewModel.error}"),
              ElevatedButton(
                onPressed: () => homeViewModel.fetchCategories(),
                child: const Text("Повторить"),
              ),
            ],
          ),
        ),
      );
    }

    final categories = homeViewModel.categories;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: backgroundColor,
        centerTitle: true,
        title: Text(
          "Quizzy",
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: ListView.builder(
          itemCount: categories.length,
          itemBuilder: (context, index) {
            final category = categories[index];
            final animation =
                Tween<Offset>(
                  begin: const Offset(0, 0.2),
                  end: Offset.zero,
                ).animate(
                  CurvedAnimation(
                    parent: _controller,
                    curve: Interval(
                      (index / (categories.isEmpty ? 1 : categories.length))
                          .clamp(0.0, 1.0),
                      1,
                      curve: Curves.easeOut,
                    ),
                  ),
                );

            return FadeTransition(
              opacity: _controller,
              child: SlideTransition(
                position: animation,
                child: _GameCard(
                  heroTag: "game_${category.id}",
                  title: category.name,
                  icon: category.iconUrl,
                  image: category.imageUrl,
                  description: category.description,
                  id: category.id,
                  isSpeedrun: category.name.toLowerCase().contains("speed run"),
                  isNew: false,
                  isDark: isDark,
                  cardColor: cardColor,
                  textColor: textColor,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _GameCard extends StatelessWidget {
  final String heroTag;
  final String title;
  final String icon;
  final String image;
  final String description;
  final int id;
  final bool isSpeedrun;
  final bool isNew;
  final bool isDark;
  final Color cardColor;
  final Color textColor;

  const _GameCard({
    required this.heroTag,
    required this.title,
    required this.icon,
    required this.image,
    required this.description,
    required this.id,
    required this.isSpeedrun,
    required this.isNew,
    required this.isDark,
    required this.cardColor,
    required this.textColor,
  });

  Widget _buildMedia(String path, {bool isIcon = false}) {
    if (path.startsWith('http')) {
      return Image.network(
        path,
        fit: isIcon ? BoxFit.contain : BoxFit.cover,
        errorBuilder: (context, error, stackTrace) =>
            const Icon(Icons.error_outline),
      );
    } else {
      // Fallback for asset icons/images
      final assetPath = path.startsWith('assets/') ? path : 'assets/$path';
      return Image.asset(
        assetPath,
        fit: isIcon ? BoxFit.contain : BoxFit.cover,
        errorBuilder: (context, error, stackTrace) =>
            const Icon(Icons.broken_image),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () {
          if (isSpeedrun) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const Speedrun()),
            );
          } else {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => Categories(
                  category: title,
                  image: image,
                  desc: description,
                  id: id,
                  heroTag: "${heroTag}_icon",
                ),
              ),
            );
          }
        },
        child: Container(
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: isDark
                    ? Colors.black.withValues(alpha: 0.3)
                    : Colors.black.withValues(alpha: 0.05),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          padding: const EdgeInsets.all(18),
          child: Stack(
            children: [
              if (isNew)
                Positioned(
                  right: 0,
                  top: 0,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.redAccent,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      "NEW",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

              Row(
                children: [
                  Hero(
                    tag: "${heroTag}_icon",
                    child: Container(
                      height: 60,
                      width: 60,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: _buildMedia(icon, isIcon: true),
                      ),
                    ),
                  ),

                  const SizedBox(width: 16),

                  Expanded(
                    child: Text(
                      title,
                      style: GoogleFonts.sen(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: textColor,
                      ),
                    ),
                  ),

                  Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 18,
                    color: isDark ? Colors.grey[400] : Colors.grey,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
