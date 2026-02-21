import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:quiz/data/GameData.dart';
import 'package:quiz/ui/game/speedrun.dart';
import '../utils/categories.dart';

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
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final games = GameData().getGameNames();

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FA),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFFF4F6FA),
        centerTitle: true,
        title: Text(
          "Quizzy",
          style: GoogleFonts.sen(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: ListView.builder(
          itemCount: games.length,
          itemBuilder: (context, index) {
            final animation = Tween<Offset>(
              begin: const Offset(0, 0.2),
              end: Offset.zero,
            ).animate(
              CurvedAnimation(
                parent: _controller,
                curve: Interval(
                  (index / games.length),
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
                  heroTag: "game_$index",
                  title: games[index],
                  icon: GameData().getIcons()[index],
                  image: GameData().getImagesLocal()[index],
                  description: GameData().getDescriptions()[index],
                  id: GameData().getGameIds()[index],
                  isSpeedrun: index == 8,
                  isNew: index == 8, // пример — первая категория новая
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

  const _GameCard({
    required this.heroTag,
    required this.title,
    required this.icon,
    required this.image,
    required this.description,
    required this.id,
    required this.isSpeedrun,
    required this.isNew,
  });

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
                  ID: id,
                  heroTag: "${heroTag}_icon",
                ),
              ),
            );
          }
        },
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 12,
                offset: const Offset(0, 6),
              )
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
                        horizontal: 10, vertical: 4),
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
                  /// 🎯 ОДИН Hero — только иконка
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
                        child: Image.asset(icon),
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
                        color: Colors.black87,
                      ),
                    ),
                  ),

                  const Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 18,
                    color: Colors.grey,
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