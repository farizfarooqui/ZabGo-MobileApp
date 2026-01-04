import 'dart:developer';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../Utils/Utils.dart';

class ChatController extends GetxController {
  final supabase = Supabase.instance.client;

  var isLoading = false.obs;
  var messages = <Map<String, dynamic>>[].obs;
  var chatList = <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchChatList();
    listenToNewMessages();
  }

  /// Fetch list of chats for current user
  Future<void> fetchChatList() async {
    try {
      isLoading(true);
      final currentUser = supabase.auth.currentUser;
      if (currentUser == null) return;

      // Get all unique chat partners from messages
      final response = await supabase
          .from('messages')
          .select('''
            sender_id,
            receiver_id,
            content,
            created_at,
            sender:users!messages_sender_id_fkey(id, name, department),
            receiver:users!messages_receiver_id_fkey(id, name, department)
          ''')
          .or('sender_id.eq.${currentUser.id},receiver_id.eq.${currentUser.id}')
          .order('created_at', ascending: false);

      // Group messages by chat partner
      final Map<String, Map<String, dynamic>> chatMap = {};

      for (final message in response) {
        final isFromMe = message['sender_id'] == currentUser.id;
        final partnerId = isFromMe ? message['receiver_id'] : message['sender_id'];
        final partnerData = isFromMe ? message['receiver'] : message['sender'];

        if (!chatMap.containsKey(partnerId)) {
          chatMap[partnerId] = {
            'id': partnerId,
            'name': partnerData['name'] ?? 'Unknown',
            'department': partnerData['department'] ?? 'Unknown',
            'lastMessage': message['content'],
            'lastMessageTime': message['created_at'],
            'isFromMe': isFromMe,
          };
        }
      }

      chatList.value = chatMap.values.toList();
    } catch (e) {
      log("Fetch chat list error: $e");
      Utils.showError("Error", "Could not load chats");
    } finally {
      isLoading(false);
    }
  }

  /// Fetch messages for a specific chat
  Future<void> fetchMessages(String otherUserId) async {
    try {
      isLoading(true);
      final currentUser = supabase.auth.currentUser;
      if (currentUser == null) return;

      final response = await supabase
          .from('messages')
          .select('''
            *,
            sender:users!messages_sender_id_fkey(name),
            receiver:users!messages_receiver_id_fkey(name)
          ''')
          .or('and(sender_id.eq.${currentUser.id},receiver_id.eq.$otherUserId),and(sender_id.eq.$otherUserId,receiver_id.eq.${currentUser.id})')
          .order('created_at', ascending: true);

      messages.value = List<Map<String, dynamic>>.from(response);
    } catch (e) {
      log("Fetch messages error: $e");
      Utils.showError("Error", "Could not load messages");
    } finally {
      isLoading(false);
    }
  }

  /// Send a message
  Future<void> sendMessage(String receiverId, String content) async {
    try {
      final currentUser = supabase.auth.currentUser;
      if (currentUser == null) return;

      if (content.trim().isEmpty) {
        Utils.showError("Error", "Message cannot be empty");
        return;
      }

      await supabase.from('messages').insert({
        'sender_id': currentUser.id,
        'receiver_id': receiverId,
        'content': content.trim(),
        'created_at': DateTime.now().toIso8601String(),
      });

      // Refresh messages after sending
      await fetchMessages(receiverId);
    } catch (e) {
      log("Send message error: $e");
      Utils.showError("Error", "Could not send message");
    }
  }

  /// Listen to new messages in real-time
  void listenToNewMessages() {
    final currentUser = supabase.auth.currentUser;
    if (currentUser == null) return;

    final channel = supabase.channel('messages_changes');

    channel.onPostgresChanges(
      event: PostgresChangeEvent.insert,
      schema: 'public',
      table: 'messages',
      callback: (payload) {
        // Refresh chat list when new message arrives
        fetchChatList();
      },
    );

    channel.subscribe();
  }

  /// Format message time
  String formatMessageTime(String timestamp) {
    try {
      final dateTime = DateTime.parse(timestamp);
      final now = DateTime.now();
      final difference = now.difference(dateTime);

      if (difference.inDays > 0) {
        return '${difference.inDays}d ago';
      } else if (difference.inHours > 0) {
        return '${difference.inHours}h ago';
      } else if (difference.inMinutes > 0) {
        return '${difference.inMinutes}m ago';
      } else {
        return 'Just now';
      }
    } catch (e) {
      return '';
    }
  }
}