import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quiz/core/providers/locale_provider.dart';
import 'package:quiz/core/utils/app_colors.dart';

class LanguageSettingsScreen extends StatelessWidget {
  const LanguageSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final localeProvider = context.watch<LocaleProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = AppColors.background(context);
    final cardColor = AppColors.card(context);
    final textColor = AppColors.text(context);

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        title: Text('Язык', style: TextStyle(color: textColor)),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: textColor),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: LocaleProvider.supportedLocales.length,
        itemBuilder: (context, index) {
          final locale = LocaleProvider.supportedLocales[index];
          final isSelected = localeProvider.locale.languageCode == locale.languageCode;
          final name = localeProvider.getLocaleName(locale.languageCode);

          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(12),
              border: isSelected ? Border.all(color: AppColors.primary, width: 2) : null,
            ),
            child: ListTile(
              onTap: () => localeProvider.setLocale(locale),
              leading: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary.withValues(alpha: 0.2) : Colors.grey.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    _getFlag(locale.languageCode),
                    style: const TextStyle(fontSize: 24),
                  ),
                ),
              ),
              title: Text(name, style: TextStyle(fontWeight: isSelected ? FontWeight.bold : FontWeight.normal, color: textColor)),
              trailing: isSelected ? const Icon(Icons.check_circle, color: AppColors.primary) : null,
            ),
          );
        },
      ),
    );
  }

  String _getFlag(String code) {
    switch (code) {
      case 'ru': return '🇷🇺';
      case 'en': return '🇬🇧';
      case 'ky': return '🇰🇬';
      default: return '🌐';
    }
  }
}
