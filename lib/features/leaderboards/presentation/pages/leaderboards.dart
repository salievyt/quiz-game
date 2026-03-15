import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:quiz/features/leaderboards/presentation/viewmodels/leaderboard_viewmodel.dart';
import 'package:quiz/features/leaderboards/domain/leaderboard_repository.dart';

class Leaderboards extends StatefulWidget {
  const Leaderboards({super.key});

  @override
  State<Leaderboards> createState() => _LeaderboardsState();
}

class _LeaderboardsState extends State<Leaderboards> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<LeaderboardViewModel>().fetchLeaderboard(refresh: true);
    });

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200) {
        context.read<LeaderboardViewModel>().fetchLeaderboard();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final viewModel = context.watch<LeaderboardViewModel>();

    final backgroundColor = isDark
        ? const Color(0xFF0F0F1A)
        : const Color(0xFFF4F6FA);
    final textColor = isDark ? Colors.white : const Color(0xFF1A1A2E);

    return Scaffold(
      backgroundColor: backgroundColor,
      body: Stack(
        children: [
          // Background Gradient decoration same as Auth
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isDark
                    ? [const Color(0xFF0F0F1A), const Color(0xFF1A1A2E)]
                    : [const Color(0xFFF4F6FA), const Color(0xFFE0E5EC)],
              ),
            ),
          ),

          SafeArea(
            child: viewModel.isLoading && viewModel.users.isEmpty
                ? const Center(
                    child: CircularProgressIndicator(color: Color(0xFF7ED421)),
                  )
                : RefreshIndicator(
                    color: const Color(0xFF7ED421),
                    onRefresh: () => viewModel.fetchLeaderboard(refresh: true),
                    child: CustomScrollView(
                      controller: _scrollController,
                      physics: const AlwaysScrollableScrollPhysics(),
                      slivers: [
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.all(24.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Топ Игроков",
                                  style: GoogleFonts.sen(
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold,
                                    color: textColor,
                                  ),
                                ),
                                Text(
                                  "Лучшие знатоки этой недели",
                                  style: TextStyle(
                                    color: isDark
                                        ? Colors.grey[400]
                                        : Colors.grey[600],
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        // Podium Section
                        if (viewModel.users.isNotEmpty)
                          SliverToBoxAdapter(
                            child: _Podium(
                              users: viewModel.users,
                              isDark: isDark,
                            ),
                          ),

                        // List Section
                        SliverPadding(
                          padding: const EdgeInsets.fromLTRB(16, 20, 16, 40),
                          sliver: SliverList(
                            delegate: SliverChildBuilderDelegate(
                              (context, index) {
                                // We show users from index 3 onwards
                                final actualIndex = index + 3;

                                if (actualIndex >= viewModel.users.length) {
                                  if (!viewModel.hasReachedMax &&
                                      viewModel.users.length >= 3) {
                                    return const Padding(
                                      padding: EdgeInsets.symmetric(
                                        vertical: 20,
                                      ),
                                      child: Center(
                                        child: CircularProgressIndicator(
                                          color: Color(0xFF7ED421),
                                        ),
                                      ),
                                    );
                                  }
                                  return const SizedBox.shrink();
                                }

                                final user = viewModel.users[actualIndex];
                                return _LeaderboardTile(
                                  user: user,
                                  rank: actualIndex + 1,
                                  isDark: isDark,
                                );
                              },
                              childCount: viewModel.users.length <= 3
                                  ? 0
                                  : viewModel.users.length -
                                        3 +
                                        (viewModel.hasReachedMax ? 0 : 1),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class _Podium extends StatelessWidget {
  final List<LeaderboardUser> users;
  final bool isDark;

  const _Podium({required this.users, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // 2nd Place
          if (users.length > 1)
            Expanded(
              child: _PodiumStep(
                user: users[1],
                rank: 2,
                height: 140,
                color: const Color(0xFFC0C0C0),
                isDark: isDark,
              ),
            )
          else
            const Spacer(),

          const SizedBox(width: 10),

          // 1st Place
          if (users.isNotEmpty)
            Expanded(
              child: _PodiumStep(
                user: users[0],
                rank: 1,
                height: 180,
                color: const Color(0xFFFFD700),
                isDark: isDark,
                isLarge: true,
              ),
            ),

          const SizedBox(width: 10),

          // 3rd Place
          if (users.length > 2)
            Expanded(
              child: _PodiumStep(
                user: users[2],
                rank: 3,
                height: 120,
                color: const Color(0xFFCD7F32),
                isDark: isDark,
              ),
            )
          else
            const Spacer(),
        ],
      ),
    );
  }
}

class _PodiumStep extends StatelessWidget {
  final LeaderboardUser user;
  final int rank;
  final double height;
  final Color color;
  final bool isDark;
  final bool isLarge;

  const _PodiumStep({
    required this.user,
    required this.rank,
    required this.height,
    required this.color,
    required this.isDark,
    this.isLarge = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Stack(
          alignment: Alignment.bottomCenter,
          children: [
            Container(
              margin: const EdgeInsets.only(bottom: 10),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: color, width: 3),
                boxShadow: [
                  BoxShadow(
                    color: color.withValues(alpha: 0.3),
                    blurRadius: 12,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: CircleAvatar(
                radius: isLarge ? 40 : 30,
                backgroundColor: isDark
                    ? const Color(0xFF1A1A2E)
                    : Colors.white,
                child: Text(
                  user.username.substring(0, 1).toUpperCase(),
                  style: TextStyle(
                    fontSize: isLarge ? 32 : 24,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              child: Text(
                rank.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          user.username,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: isLarge ? 16 : 14,
            color: isDark ? Colors.white : Colors.black87,
          ),
          overflow: TextOverflow.ellipsis,
        ),
        Text(
          "${user.points} pts",
          style: TextStyle(
            color: const Color(0xFF7ED421),
            fontWeight: FontWeight.bold,
            fontSize: isLarge ? 14 : 12,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          height: height,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                color.withValues(alpha: 0.6),
                color.withValues(alpha: 0.1),
              ],
            ),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
          ),
        ),
      ],
    );
  }
}

class _LeaderboardTile extends StatelessWidget {
  final LeaderboardUser user;
  final int rank;
  final bool isDark;

  const _LeaderboardTile({
    required this.user,
    required this.rank,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.05)
                  : Colors.white.withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.1)
                    : Colors.white.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              children: [
                SizedBox(
                  width: 30,
                  child: Text(
                    rank.toString(),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                CircleAvatar(
                  radius: 20,
                  backgroundColor: const Color(
                    0xFF7ED421,
                  ).withValues(alpha: 0.1),
                  child: Text(
                    user.username.substring(0, 1).toUpperCase(),
                    style: const TextStyle(
                      color: Color(0xFF7ED421),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    user.username,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                ),
                Text(
                  "${user.points} pts",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF7ED421),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
