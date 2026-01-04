import 'package:demo/Controllers/ChatController.dart';
import 'package:demo/Utils/Constants.dart';
import 'package:demo/Widgets/SmallLoader.dart';
import 'package:flutter/material.dart';
import 'ChatScreen.dart';
import 'package:get/get.dart';

class ChatListScreen extends StatelessWidget {
  const ChatListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ChatController chatController = Get.put(ChatController());

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      appBar: AppBar(
        title: const Text(
          "Messages",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: colorPrimary,
        elevation: 0,
      ),
      body: Obx(() {
        if (chatController.isLoading.value) {
          return const Center(child: SmallLoader(color: colorSecondary));
        }

        if (chatController.chatList.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.chat_bubble_outline, size: 80, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  "No messages yet",
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
                SizedBox(height: 8),
                Text(
                  "Start chatting with fellow passengers",
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: chatController.fetchChatList,
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: chatController.chatList.length,
            itemBuilder: (context, index) {
              final chat = chatController.chatList[index];
              final lastMessage = chat['lastMessage'] ?? '';
              final isFromMe = chat['isFromMe'] ?? false;
              final displayMessage =
                  isFromMe ? 'You: $lastMessage' : lastMessage;

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: colorPrimary,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.shade300,
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: colorSecondary,
                    child: Text(
                      (chat['name'] ?? 'U')[0].toUpperCase(),
                      style: const TextStyle(
                        color: colorPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  title: Text(
                    chat['name'] ??
                        'Unknown User' + chat['department'] ??
                        'Unknown Department',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  subtitle: Text(
                    displayMessage.length > 30
                        ? '${displayMessage.substring(0, 30)}...'
                        : displayMessage,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.black87,
                    ),
                  ),
                  trailing: Text(
                    chatController
                        .formatMessageTime(chat['lastMessageTime'] ?? ''),
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                  onTap: () => Get.to(() => ChatScreen(chatUser: chat)),
                ),
              );
            },
          ),
        );
      }),
    );
  }
}
