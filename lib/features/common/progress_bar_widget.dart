import 'package:flutter/material.dart';
import 'package:quiz/core/utils/app_colors.dart';

class ProgressBarWidget extends StatelessWidget {
  final double value;
  final Color? progressColor;
  final Color? backgroundColor;
  final double height;
  final bool showPercentage;

  const ProgressBarWidget({
    super.key,
    required this.value,
    this.progressColor,
    this.backgroundColor,
    this.height = 8,
    this.showPercentage = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = backgroundColor ?? (isDark ? Colors.grey[800] : Colors.grey[200]);
    final fgColor = progressColor ?? AppColors.primary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(height / 2),
          child: LinearProgressIndicator(
            value: value.clamp(0.0, 1.0),
            backgroundColor: bgColor,
            valueColor: AlwaysStoppedAnimation(fgColor),
            minHeight: height,
          ),
        ),
        if (showPercentage) ...[
          const SizedBox(height: 4),
          Text(
            '${(value * 100).toInt()}%',
            style: TextStyle(fontSize: 12, color: AppColors.textSecondary(context)),
          ),
        ],
      ],
    );
  }
}
