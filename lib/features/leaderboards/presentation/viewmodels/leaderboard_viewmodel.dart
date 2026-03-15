import 'package:quiz/core/base/base_viewmodel.dart';
import 'package:quiz/features/leaderboards/domain/leaderboard_repository.dart';

class LeaderboardViewModel extends BaseViewModel {
  final LeaderboardRepository _repository;

  LeaderboardViewModel(this._repository);

  final List<LeaderboardUser> _users = [];
  List<LeaderboardUser> get users => _users;

  final int _limit = 20;
  int _offset = 0;
  bool _hasReachedMax = false;
  bool get hasReachedMax => _hasReachedMax;

  Future<void> fetchLeaderboard({bool refresh = false}) async {
    if (isLoading || (_hasReachedMax && !refresh)) return;

    if (refresh) {
      _offset = 0;
      _hasReachedMax = false;
      _users.clear();
      setLoading(true); // show initial loading
    }
    
    // When not refreshing, we rely on a bottom indicator instead of full loading flag
    
    final result = await _repository.getLeaderboard(limit: _limit, offset: _offset);
    
    if (result.isSuccess) {
      final newUsers = result.data!;
      if (newUsers.length < _limit) {
        _hasReachedMax = true;
      }
      _users.addAll(newUsers);
      _offset += newUsers.length;
      clearError();
    } else {
      setError(result.error);
    }
    
    if (refresh) {
      setLoading(false);
    } else {
      notifyListeners();
    }
  }
}
