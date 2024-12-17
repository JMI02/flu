import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

// Assuming you have authentication and data services
import 'services/auth_service.dart';
import 'services/chat_service.dart';
import 'models/chat_model.dart';
import 'screens/chat_detail_screen.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({Key? key}) : super(key: key);

  @override
  _ChatListScreenState createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  List<ChatModel> _chats = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchChats();
  }

  Future<void> _fetchChats() async {
    try {
      final userId = AuthService.getCurrentUserId();
      final chats = await ChatService.getChatsForUser(userId);
      
      setState(() {
        _chats = chats;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load chats: $e')),
      );
    }
  }

  String _formatChatDate(DateTime? date) {
    if (date == null) return '';
    
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return DateFormat('HH:mm').format(date);
    }

    if (difference.inDays <= 7) {
      return DateFormat('EEE').format(date);
    }

    return DateFormat('dd.MM.yyyy').format(date);
  }

  Widget _buildChatItem(ChatModel chat) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: CircleAvatar(
        backgroundColor: Colors.grey[800],
        child: Text(
          chat.name.isNotEmpty ? chat.name[0].toUpperCase() : '?',
          style: const TextStyle(color: Colors.white),
        ),
      ),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              if (chat.type == ChatType.group)
                const Icon(Icons.group, color: Colors.grey, size: 16),
              const SizedBox(width: 4),
              Text(
                chat.name,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          Row(
            children: [
              if (chat.from == AuthService.getCurrentUserId())
                Icon(
                  chat.isRead 
                    ? Icons.done_all 
                    : Icons.done, 
                  color: Colors.grey, 
                  size: 20,
                ),
              const SizedBox(width: 4),
              Text(
                _formatChatDate(chat.date),
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
      subtitle: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              chat.lastMessage,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Colors.grey),
            ),
          ),
          if (chat.unreadCount > 0)
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.grey[800],
                shape: BoxShape.circle,
              ),
              child: Text(
                '${chat.unreadCount}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                ),
              ),
            ),
        ],
      ),
      onTap: () => _openChat(chat.id),
    );
  }

  Widget _buildLoadingState() {
    return ListView.builder(
      itemCount: 4,
      itemBuilder: (context, index) {
        return ListTile(
          leading: const CircleAvatar(
            backgroundColor: Colors.grey,
          ),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 100,
                height: 16,
                color: Colors.grey,
              ),
              const SizedBox(height: 8),
              Container(
                width: 80,
                height: 14,
                color: Colors.grey,
              ),
            ],
          ),
        );
      },
    );
  }

  void _openChat(String chatId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatDetailScreen(chatId: chatId),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'EAS Chat', 
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.grey[800],
        elevation: 4,
      ),
      body: _isLoading 
        ? _buildLoadingState() 
        : _chats.isEmpty
          ? const Center(child: Text('No chats yet'))
          : ListView.builder(
              itemCount: _chats.length,
              itemBuilder: (context, index) {
                return _buildChatItem(_chats[index]);
              },
            ),
    );
  }
}

// Supporting models and services (simplified for context)
enum ChatType { private, group }

class ChatModel {
  final String id;
  final String name;
  final ChatType type;
  final String from;
  final bool isRead;
  final DateTime? date;
  final String lastMessage;
  final int unreadCount;

  ChatModel({
    required this.id,
    required this.name,
    required this.type,
    required this.from,
    required this.isRead,
    this.date,
    required this.lastMessage,
    required this.unreadCount,
  });
}

// Placeholder services - you'd replace these with your actual implementation
class AuthService {
  static String getCurrentUserId() {
    // Implement actual user ID retrieval
    return 'current_user_id';
  }
}

class ChatService {
  static Future<List<ChatModel>> getChatsForUser(String userId) async {
    // Implement actual chat fetching logic
    return [
      ChatModel(
        id: '1',
        name: 'John Doe',
        type: ChatType.private,
        from: 'current_user_id',
        isRead: false,
        date: DateTime.now(),
        lastMessage: 'Hey, how are you?',
        unreadCount: 2,
      ),
      // Add more mock chats
    ];
  }
}