import 'package:flutter/material.dart';
import 'package:quiz/features/game/presentation/pages/game.dart';

class Categories extends StatefulWidget {
  final String category;
  final String image;
  final String desc;
  final int id;
  final String heroTag;

  const Categories({
    super.key,
    required this.category,
    required this.image,
    required this.desc,
    required this.id,
    required this.heroTag,
  });

  @override
  State<Categories> createState() => _CategoriesState();
}

class _CategoriesState extends State<Categories> {
  Widget _buildMedia(String path) {
    if (path.startsWith('http')) {
      return Image.network(
        path,
        height: 250,
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _buildErrorPlaceholder(),
      );
    } else {
      final assetPath = path.startsWith('assets/') ? path : 'assets/$path';
      return Image.asset(
        assetPath,
        height: 250,
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _buildErrorPlaceholder(),
      );
    }
  }

  Widget _buildErrorPlaceholder() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      height: 250,
      width: double.infinity,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1A2E) : Colors.grey[200],
        borderRadius: BorderRadius.circular(20),
      ),
      child: Icon(
        Icons.quiz,
        size: 80,
        color: isDark ? Colors.grey[600] : Colors.grey[400],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDark ? const Color(0xFF0F0F1A) : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black87;
    final secondaryTextColor = isDark ? Colors.grey[400] : Colors.grey[600];

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: backgroundColor,
        title: Text(
          widget.category,
          style: TextStyle(fontSize: 22, color: textColor),
        ),
        centerTitle: true,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(Icons.arrow_back_ios_new, color: textColor),
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Column(
            children: [
              Hero(
                tag: widget.heroTag,
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
                    child: _buildMedia(widget.image),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                widget.desc,
                style: TextStyle(
                  fontSize: 18,
                  height: 1.5,
                  color: secondaryTextColor,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Game(ID: widget.id)),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF7ED421),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  minimumSize: const Size(double.infinity, 65),
                  elevation: isDark ? 0 : 8,
                  shadowColor: isDark
                      ? Colors.transparent
                      : const Color(0xFF7ED421).withValues(alpha: 0.4),
                ),
                child: const Text(
                  "Начать играть",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
