import 'package:flutter/material.dart';
import 'package:quiz/core/utils/app_colors.dart';

class StatBadge extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color? color;

  const StatBadge({
    super.key,
    required this.icon,
    required this.value,
    required this.label,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final badgeColor = color ?? AppColors.primary;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.card(context),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: badgeColor, size: 28),
          const SizedBox(height: 8),
          Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.text(context))),
          Text(label, style: TextStyle(fontSize: 12, color: AppColors.textSecondary(context))),
        ],
      ),
    );
  }
}
