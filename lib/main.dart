import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:quiz/l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:quiz/core/theme/app_theme.dart';
import 'package:quiz/core/providers/locale_provider.dart';
import 'package:quiz/ui/providers/theme_provider.dart';
import 'package:quiz/ui/providers/game_provider.dart';
import 'package:quiz/ui/providers/quest_provider.dart';
import 'package:quiz/ui/providers/daily_bonus_provider.dart';
import 'package:quiz/ui/providers/lives_provider.dart';
import 'package:quiz/ui/providers/coins_provider.dart';
import 'package:quiz/ui/utils/splash_screen.dart';
import 'package:quiz/core/storage/secure_storage.dart';
import 'package:quiz/core/network/dio_client.dart';
import 'package:quiz/features/auth/data/auth_api_service.dart';
import 'package:quiz/features/auth/domain/auth_repository.dart';
import 'package:quiz/features/auth/presentation/viewmodels/auth_viewmodel.dart';
import 'package:quiz/features/auth/presentation/pages/login_screen.dart';
import 'package:quiz/features/auth/presentation/pages/register_screen.dart';
import 'package:quiz/features/leaderboards/data/leaderboard_api_service.dart';
import 'package:quiz/features/leaderboards/domain/leaderboard_repository.dart';
import 'package:quiz/features/leaderboards/presentation/viewmodels/leaderboard_viewmodel.dart';
import 'package:quiz/features/chat/data/chat_api_service.dart';
import 'package:quiz/features/chat/domain/chat_repository.dart';
import 'package:quiz/features/chat/presentation/viewmodels/chat_viewmodel.dart';
import 'package:quiz/features/game/data/quiz_api_service.dart';
import 'package:quiz/features/game/data/quiz_repository_impl.dart';
import 'package:quiz/features/game/domain/quiz_repository.dart';
import 'package:quiz/features/home/presentation/viewmodels/home_viewmodel.dart';

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

  await themeProvider.init();
  await localeProvider.init();
  await gameProvider.init();
  await questProvider.init();
  await dailyBonusProvider.init();
  await livesProvider.init();
  await coinsProvider.init();


  final secureStorage = SecureStorage();
  final dioClient = DioClient(secureStorage);
  final authApiService = AuthApiService(dioClient.dio);
  final authRepository = AuthRepository(authApiService, secureStorage);
  final authViewModel = AuthViewModel(authRepository);

  final leaderboardApiService = LeaderboardApiService(dioClient.dio);
  final leaderboardRepository = LeaderboardRepository(leaderboardApiService);
  final leaderboardViewModel = LeaderboardViewModel(leaderboardRepository);

  final chatApiService = ChatApiService(dioClient.dio);
  final chatRepository = ChatRepository(chatApiService);
  final chatViewModel = ChatViewModel(chatRepository);

  final quizApiService = QuizApiService(dioClient.dio);
  final quizRepository = QuizRepositoryImpl(quizApiService);
  final homeViewModel = HomeViewModel(quizRepository);

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

        // New architecture providers
        ChangeNotifierProvider.value(value: authViewModel),
        ChangeNotifierProvider.value(value: leaderboardViewModel),
        ChangeNotifierProvider.value(value: chatViewModel),
        ChangeNotifierProvider.value(value: homeViewModel),
        Provider<QuizRepository>.value(value: quizRepository),
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
      localizationsDelegates: [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      routes: {
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
      },
      home: const SplashScreen(),
    );
  }
}
