import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:quiz/core/theme/app_theme.dart';
import 'package:quiz/core/providers/locale_provider.dart';
import 'package:quiz/ui/providers/theme_provider.dart';
import 'package:quiz/ui/providers/game_provider.dart';
import 'package:quiz/ui/providers/quest_provider.dart';
import 'package:quiz/ui/providers/daily_bonus_provider.dart';
import 'package:quiz/ui/providers/lives_provider.dart';
import 'package:quiz/ui/providers/coins_provider.dart';
import 'package:quiz/ui/providers/pet_provider.dart';
import 'package:quiz/ui/utils/splash_screen.dart';


import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  
  final themeProvider = ThemeProvider();
  final localeProvider = LocaleProvider();
  final gameProvider = GameProvider();
  final questProvider = QuestProvider();
  final dailyBonusProvider = DailyBonusProvider();
  final livesProvider = LivesProvider();
  final coinsProvider = CoinsProvider();
  final petProvider = PetProvider();
  
  await themeProvider.init();
  await localeProvider.init();
  await gameProvider.init();
  await questProvider.init();
  await dailyBonusProvider.init();
  await livesProvider.init();
  await coinsProvider.init();
  await petProvider.init();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: themeProvider),
        ChangeNotifierProvider.value(value: localeProvider),
        ChangeNotifierProvider.value(value: gameProvider),
        ChangeNotifierProvider.value(value: questProvider),
        ChangeNotifierProvider.value(value: dailyBonusProvider),
        ChangeNotifierProvider.value(value: livesProvider),
        ChangeNotifierProvider.value(value: coinsProvider),
        ChangeNotifierProvider.value(value: petProvider),
      ],
      child: const QuizApp(),
    ),
  );
}

class QuizApp extends StatelessWidget {
  const QuizApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final localeProvider = context.watch<LocaleProvider>();

    return MaterialApp(
      title: 'Quizzy',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeProvider.themeMode,
      locale: localeProvider.locale,
      supportedLocales: LocaleProvider.supportedLocales,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: const SplashScreen(),
    );
  }
}
