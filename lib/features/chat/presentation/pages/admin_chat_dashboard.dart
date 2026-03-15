import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quiz/features/chat/presentation/viewmodels/chat_viewmodel.dart';
import 'package:quiz/features/chat/domain/chat_repository.dart';

class AdminChatDashboard extends StatefulWidget {
  const AdminChatDashboard({super.key});

  @override
  State<AdminChatDashboard> createState() => _AdminChatDashboardState();
}

class _AdminChatDashboardState extends State<AdminChatDashboard> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ChatViewModel>().loadSupportSessions();
    });
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ChatViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Support Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => vm.loadSupportSessions(),
          ),
        ],
      ),
      body: vm.isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: vm.supportSessions.length,
              itemBuilder: (context, index) {
                final session = vm.supportSessions[index];
                return ListTile(
                  leading: const CircleAvatar(child: Icon(Icons.person)),
                  title: Text(session.userName),
                  subtitle: Text('Messages: ${session.messages.length}'),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => AdminChatDetailScreen(session: session),
                      ),
                    ).then((_) => vm.loadSupportSessions());
                  },
                );
              },
            ),
    );
  }
}

class AdminChatDetailScreen extends StatefulWidget {
  final ChatSession session;
  const AdminChatDetailScreen({super.key, required this.session});

  @override
  State<AdminChatDetailScreen> createState() => _AdminChatDetailScreenState();
}

class _AdminChatDetailScreenState extends State<AdminChatDetailScreen> {
  final TextEditingController _msgController = TextEditingController();

  void _sendMessage() {
    final text = _msgController.text.trim();
    if (text.isEmpty) return;

    final vm = context.read<ChatViewModel>();
    vm.sendMessage(widget.session.id, text).then((_) {
      // Ideally we'd poll or reload this specific session, but for simplicity,
      // forcing the parent to reload and returning is fine, or reloading the list of sessions.
      Navigator.pop(context); // Close and refresh
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(title: Text('Chat with ${widget.session.userName}')),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: widget.session.messages.length,
              itemBuilder: (context, index) {
                final msg = widget.session.messages[index];
                final isMe = msg.isSupport;
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
                          : (isDark ? Colors.grey[800] : Colors.grey[200]),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      msg.content,
                      style: TextStyle(
                        color: isMe
                            ? Colors.white
                            : (isDark ? Colors.white : Colors.black87),
                      ),
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
                        hintText: 'Type your reply...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(24)),
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
