import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quiz/features/chat/presentation/viewmodels/chat_viewmodel.dart';

class UserChatScreen extends StatefulWidget {
  const UserChatScreen({super.key});

  @override
  State<UserChatScreen> createState() => _UserChatScreenState();
}

class _UserChatScreenState extends State<UserChatScreen> {
  final TextEditingController _msgController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final vm = context.read<ChatViewModel>();
      vm.loadPersonalSession().then((_) {
        vm.startPollingPersonalSession();
        _scrollToBottom();
      });
    });
  }

  @override
  void deactivate() {
    // We can stop polling when going off-screen to save resources.
    context.read<ChatViewModel>().stopPolling();
    super.deactivate();
  }

  @override
  void dispose() {
    _msgController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void _sendMessage() {
    final text = _msgController.text.trim();
    if (text.isEmpty) return;

    final vm = context.read<ChatViewModel>();
    if (vm.currentSession != null) {
      vm.sendMessage(vm.currentSession!.id, text).then((_) {
        _scrollToBottom();
      });
      _msgController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ChatViewModel>();
    final session = vm.currentSession;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(title: const Text('Support Chat')),
      body: vm.isLoading && session == null
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                if (vm.hasError)
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      vm.error!.message,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
                Expanded(
                  child: ListView.builder(
                    controller: _scrollController,
                    itemCount: session?.messages.length ?? 0,
                    itemBuilder: (context, index) {
                      final msg = session!.messages[index];
                      // Messages from support admin are treated as incoming to the user
                      final isMe = !msg.isSupport;
                      return Align(
                        alignment: isMe
                            ? Alignment.centerRight
                            : Alignment.centerLeft,
                        child: Container(
                          margin: const EdgeInsets.symmetric(
                            vertical: 4,
                            horizontal: 8,
                          ),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isMe
                                ? Colors.blue
                                : (isDark
                                      ? Colors.grey[800]
                                      : Colors.grey[200]),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (!isMe)
                                Text(
                                  msg.senderName,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                    color: isDark
                                        ? Colors.grey[400]
                                        : Colors.grey[600],
                                  ),
                                ),
                              Text(
                                msg.content,
                                style: TextStyle(
                                  color: isMe
                                      ? Colors.white
                                      : (isDark
                                            ? Colors.white
                                            : Colors.black87),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _msgController,
                            decoration: const InputDecoration(
                              hintText: 'Type your message...',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.all(
                                  Radius.circular(24),
                                ),
                              ),
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.send, color: Colors.blue),
                          onPressed: _sendMessage,
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
