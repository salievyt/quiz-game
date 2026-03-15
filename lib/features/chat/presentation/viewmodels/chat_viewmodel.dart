import 'dart:async';
import 'package:quiz/core/base/base_viewmodel.dart';
import 'package:quiz/features/chat/domain/chat_repository.dart';

class ChatViewModel extends BaseViewModel {
  final ChatRepository _repository;
  Timer? _pollingTimer;

  ChatViewModel(this._repository);

  ChatSession? _currentSession;
  ChatSession? get currentSession => _currentSession;

  List<ChatSession> _supportSessions = [];
  List<ChatSession> get supportSessions => _supportSessions;

  Future<void> loadPersonalSession() async {
    setLoading(true);
    final result = await _repository.getOrCreatePersonalSession();
    if (result.isSuccess) {
      _currentSession = result.data;
      clearError();
    } else {
      setError(result.error);
    }
    setLoading(false);
  }

  Future<void> sendMessage(int sessionId, String content) async {
    final result = await _repository.sendMessage(sessionId, content);
    if (result.isSuccess) {
      if (_currentSession?.id == sessionId) {
        await pollPersonalSession();
      } else {
        await loadSupportSessions();
      }
    } else {
      setError(result.error);
    }
  }

  Future<void> loadSupportSessions() async {
    setLoading(true);
    final result = await _repository.getSupportSessions();
    if (result.isSuccess) {
      _supportSessions = result.data!;
      clearError();
    } else {
      setError(result.error);
    }
    setLoading(false);
  }

  Future<void> pollPersonalSession() async {
    final result = await _repository.getOrCreatePersonalSession();
    if (result.isSuccess) {
      _currentSession = result.data;
      notifyListeners();
    }
  }

  void startPollingPersonalSession() {
    stopPolling();
    _pollingTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      pollPersonalSession();
    });
  }

  void stopPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = null;
  }

  @override
  void dispose() {
    stopPolling();
    super.dispose();
  }
}
