import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DailyBonusNotifier extends AsyncNotifier<DailyBonusData> {
  static const String _lastBonusKey = 'last_daily_bonus';

  @override
  Future<DailyBonusData> build() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final lastDateStr = prefs.getString(_lastBonusKey);

      if (lastDateStr != null) {
        final lastClaimDate = DateTime.tryParse(lastDateStr);
        final now = DateTime.now();
        if (lastClaimDate != null &&
            lastClaimDate.year == now.year &&
            lastClaimDate.month == now.month &&
            lastClaimDate.day == now.day) {
          return const DailyBonusData(canClaim: false);
        }
      }
    } catch (e) {
      // ignore
    }
    return const DailyBonusData(canClaim: true);
  }

  Future<int> claimBonus() async {
    final current = state.value;
    if (current == null || !current.canClaim) return 0;

    state = const AsyncData(DailyBonusData(canClaim: false));

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
          _lastBonusKey, DateTime.now().toIso8601String());
    } catch (e) {
      // ignore
    }

    return 50;
  }
}

class DailyBonusData {
  final bool canClaim;

  const DailyBonusData({required this.canClaim});
}

final dailyBonusProvider =
    AsyncNotifierProvider<DailyBonusNotifier, DailyBonusData>(
        DailyBonusNotifier.new);
