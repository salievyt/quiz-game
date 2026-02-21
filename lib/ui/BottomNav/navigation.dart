import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'dart:io';

import 'package:quiz/ui/game/quiz.dart';
import 'package:quiz/ui/leaderboards/leaderboards.dart';
import 'package:quiz/ui/profile/profile.dart';
import 'package:quiz/ui/statistics/statistics.dart';

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
    Profile()
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              blurRadius: 20,
              color: Colors.black.withOpacity(.1),
            )
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 8),
            child: GNav(
              rippleColor: Colors.grey[300]!,
              hoverColor: Colors.grey[100]!,
              gap: 8,
              activeColor: Colors.white,
              iconSize: 24,
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              duration: Duration(milliseconds: 400),
              tabBackgroundColor: Color(0xFF7ED421)!,
              color: Colors.black,
              tabs: [
                GButton(
                  icon: Icons.home,
                  text: 'Home',
                ),
                GButton(
                  icon: Icons.leaderboard,
                  text: 'Leaderboards',
                ),
                GButton(
                  icon: Icons.bar_chart,
                  text: 'Statistics',
                ),
                GButton(
                  icon: Icons.person,
                  text: 'Profile',
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
