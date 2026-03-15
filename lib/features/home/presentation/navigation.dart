import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:quiz/l10n/app_localizations.dart';

import 'package:quiz/features/home/presentation/pages/quiz.dart';
import 'package:quiz/features/leaderboards/presentation/pages/leaderboards.dart';
import 'package:quiz/features/statistics/presentation/pages/statistics.dart';
import 'package:quiz/features/profile/presentation/pages/profile.dart';

class Navigation extends StatefulWidget {
  const Navigation({super.key});

  @override
  State<Navigation> createState() => _NavigationState();
}

int _currentIndex = 0;
void setPage(int index) {
  _currentIndex = index;
}

class _NavigationState extends State<Navigation> {
  final List<Widget> _pages = [
    const Quiz(),
    const Leaderboards(),
    const StatisticsScreen(),
    const Profile(),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      extendBody:
          true, // This allows the body to be shown behind the navigation bar
      body: IndexedStack(index: _currentIndex, children: _pages),
      bottomNavigationBar: Container(
        margin: const EdgeInsets.fromLTRB(20, 0, 20, 25),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(30),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.08)
                    : Colors.white.withValues(alpha: 0.8),
                borderRadius: BorderRadius.circular(30),
                border: Border.all(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.1)
                      : Colors.white.withValues(alpha: 0.3),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: GNav(
                rippleColor: const Color(0xFF7ED421).withValues(alpha: 0.2),
                hoverColor: const Color(0xFF7ED421).withValues(alpha: 0.1),
                gap: 8,
                activeColor: Colors.white,
                iconSize: 22,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                duration: const Duration(milliseconds: 400),
                tabBackgroundColor: const Color(0xFF7ED421),
                color: isDark ? Colors.grey[400]! : Colors.grey[600]!,
                tabs: [
                  GButton(icon: Icons.grid_view_rounded, text: l10n.home),
                  GButton(
                    icon: Icons.emoji_events_rounded,
                    text: l10n.leaderboards,
                  ),
                  GButton(icon: Icons.bar_chart_rounded, text: l10n.statistics),
                  GButton(icon: Icons.person_rounded, text: l10n.profile),
                ],
                selectedIndex: _currentIndex,
                onTabChange: (index) {
                  setState(() {
                    _currentIndex = index;
                  });
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
