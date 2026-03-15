import 'package:flutter/foundation.dart';
import 'package:quiz/core/error/failures.dart';

abstract class BaseViewModel extends ChangeNotifier {
  bool _isLoading = false;
  Failure? _error;

  bool get isLoading => _isLoading;
  Failure? get error => _error;
  bool get hasError => _error != null;

  void setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void setError(Failure? failure) {
    _error = failure;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
