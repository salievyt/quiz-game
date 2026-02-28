import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';

import 'package:quiz/features/home/presentation/pages/quiz.dart';
import 'package:quiz/features/leaderboards/presentation/pages/leaderboards.dart';
import 'package:quiz/features/statistics/presentation/pages/statistics.dart';
import 'package:quiz/features/pet/presentation/pages/pet_screen.dart';
import 'package:quiz/features/profile/presentation/pages/profile.dart';

class Navigation extends StatefulWidget {
  const Navigation({super.key});

  @override
  State<Navigation> createState() => _NavigationState();
}
int _currentIndex = 0;
void setPage(int index){
  _currentIndex = index;
}

class _NavigationState extends State<Navigation> {

  final List<Widget> _pages = [
    Quiz(),
    Leaderboards(),
    StatisticsScreen(),
    PetScreen(),
    Profile(),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    final backgroundColor = isDark ? const Color(0xFF1A1A2E) : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black;
    final shadowColor = Colors.black.withValues(alpha: isDark ? 0.3 : 0.1);

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: backgroundColor,
          boxShadow: [
            BoxShadow(
              blurRadius: 20,
              color: shadowColor,
            )
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 8),
            child: GNav(
              rippleColor: isDark ? Colors.grey[700]! : Colors.grey[300]!,
              hoverColor: isDark ? Colors.grey[800]! : Colors.grey[100]!,
              gap: 8,
              activeColor: Colors.white,
              iconSize: 24,
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              duration: Duration(milliseconds: 400),
              tabBackgroundColor: Color(0xFF7ED421)!,
              color: isDark ? Colors.grey[400]! : Colors.black,
              tabs: [
                GButton(
                  icon: Icons.home,
                  text: 'Главная',
                ),
                GButton(
                  icon: Icons.leaderboard,
                  text: 'Топ',
                ),
                GButton(
                  icon: Icons.donut_large,
                  text: 'Стат',
                ),
                GButton(
                  icon: Icons.pets,
                  text: 'Питомец',
                ),
                GButton(
                  icon: Icons.person,
                  text: 'Профиль',
                ),
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
      )
    );
  }
}
