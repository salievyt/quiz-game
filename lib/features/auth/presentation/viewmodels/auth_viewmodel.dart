import 'package:quiz/core/base/base_viewmodel.dart';
import 'package:quiz/features/auth/domain/auth_repository.dart';

class AuthViewModel extends BaseViewModel {
  final AuthRepository _repository;

  AuthViewModel(this._repository);

  bool _isAuthenticated = false;
  bool get isAuthenticated => _isAuthenticated;

  UserProfile? _profile;
  UserProfile? get profile => _profile;

  Future<void> checkAuthStatus() async {
    _isAuthenticated = await _repository.isAuthenticated();
    if (_isAuthenticated) {
      await fetchProfile();
    }
    notifyListeners();
  }

  Future<void> fetchProfile() async {
    final result = await _repository.getProfile();
    if (result.isSuccess) {
      _profile = result.data;
      notifyListeners();
    }
  }

  Future<void> updateScores(int additionalPoints, int additionalCoins) async {
    if (_profile == null) return;

    final newPoints = _profile!.points + additionalPoints;
    final newCoins = _profile!.coins + additionalCoins;

    final result = await _repository.updateProfile(
      points: newPoints,
      coins: newCoins,
    );
    if (result.isSuccess) {
      _profile = result.data;
      notifyListeners();
    }
  }

  Future<bool> login(String username, String password) async {
    setLoading(true);
    clearError();

    final result = await _repository.login(username, password);

    setLoading(false);

    if (result.isSuccess) {
      _isAuthenticated = true;
      await fetchProfile();
      notifyListeners();
      return true;
    } else {
      setError(result.error);
      return false;
    }
  }

  Future<bool> register(String username, String password) async {
    setLoading(true);
    clearError();

    final result = await _repository.register(username, password);

    setLoading(false);

    if (result.isSuccess) {
      return true;
    } else {
      setError(result.error);
      return false;
    }
  }

  Future<void> logout() async {
    await _repository.logout();
    _isAuthenticated = false;
    _profile = null;
    notifyListeners();
  }
}
