import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'dart:io';

class Leaderboards extends StatefulWidget {
  const Leaderboards({super.key});

  @override
  State<Leaderboards> createState() => _LeaderboardsState();
}

class _LeaderboardsState extends State<Leaderboards> {

  final List<Map<String, dynamic>> players = [
    {"name": "Ahror", "score": 980},
    {"name": "Sofia", "score": 870},
    {"name": "Daniel", "score": 820},
    {"name": "Emma", "score": 760},
    {"name": "Mark", "score": 720},
    {"name": "Alex", "score": 720},
    {"name": "Hitler", "score": 720},
    {"name": "Ilon", "score": 720},
    {"name": "Olivia", "score": 690},
  ];

  @override
  Widget build(BuildContext context) {
    players.sort((a, b) => b["score"].compareTo(a["score"]));

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      body: Column(
        children: [

          const SizedBox(height: 90),

          //Top 3 Podium
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _buildTopPlayer(players[1], 2, 120),
              _buildTopPlayer(players[0], 1, 150),
              _buildTopPlayer(players[2], 3, 110),
            ],
          ),

          const SizedBox(height: 30),

          //Остальные игроки
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: players.length - 3,
              itemBuilder: (context, index) {
                final player = players[index + 3];
                return _buildPlayerTile(
                  player["name"],
                  player["score"],
                  index + 4,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopPlayer(Map<String, dynamic> player, int place, double height) {
    Color medalColor;

    switch (place) {
      case 1:
        medalColor = Colors.amber;
        break;
      case 2:
        medalColor = Colors.grey;
        break;
      default:
        medalColor = const Color(0xFFCD7F32);
    }

    return Column(
      children: [
        CircleAvatar(
          radius: 28,
          backgroundColor: medalColor,
          child: Text(
            place.toString(),
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          player["name"],
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        Text("${player["score"]} pts"),
        const SizedBox(height: 10),
        Container(
          width: 60,
          height: height,
          decoration: BoxDecoration(
            color: medalColor.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ],
    );
  }

  Widget _buildPlayerTile(String name, int score, int rank) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Text(
            "#$rank",
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Text(
              name,
              style: const TextStyle(fontSize: 16),
            ),
          ),
          Text(
            "$score pts",
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}