import 'package:ecore/chat_page/select_chat_room.dart';
import 'package:flutter/material.dart';
import '../cosntants/firestore_key.dart';
import '../models/firestore/chat_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';

class ChatList extends StatefulWidget {
  const ChatList({Key? key}) : super(key: key);

  @override
  State<ChatList> createState() => _ChatListState();
}

class _ChatListState extends State<ChatList> {
  final StreamController<List<ChatModel>> _chatController = StreamController<List<ChatModel>>.broadcast();

  late StreamSubscription<QuerySnapshot<Map<String, dynamic>>> _sendSubscription;
  late StreamSubscription<QuerySnapshot<Map<String, dynamic>>> _receiveSubscription;

  @override
  void initState() {
    super.initState();
    _setupStreams();
  }

  void _setupStreams() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    final userId = user.uid;

    final sendStream = FirebaseFirestore.instance
        .collection(COLLECTION_CHATS)
        .where(KEY_SEND_USERID, isEqualTo: userId)
        .orderBy(KEY_DATE, descending: false)
        .snapshots();

    final receiveStream = FirebaseFirestore.instance
        .collection(COLLECTION_CHATS)
        .where(KEY_RECEIVE_USERID, isEqualTo: userId)
        .orderBy(KEY_DATE, descending: false)
        .snapshots();

    _sendSubscription = sendStream.listen((sendSnapshot) {
      _updateChatList(sendSnapshot: sendSnapshot);
    });

    _receiveSubscription = receiveStream.listen((receiveSnapshot) {
      _updateChatList(receiveSnapshot: receiveSnapshot);
    });
  }

  void _updateChatList({QuerySnapshot<Map<String, dynamic>>? sendSnapshot, QuerySnapshot<Map<String, dynamic>>? receiveSnapshot}) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    final userId = user.uid;

    List<ChatModel> allChats = [];
    if (sendSnapshot != null) {
      allChats.addAll(sendSnapshot.docs.map((doc) => ChatModel.fromSnapshot(doc)));
    }
    if (receiveSnapshot != null) {
      allChats.addAll(receiveSnapshot.docs.map((doc) => ChatModel.fromSnapshot(doc)));
    }

    // Filter to get the most recent message per user
    Map<String, ChatModel> recentChatsMap = {};
    for (var chat in allChats) {
      final otherUserId = chat.sendId == userId ? chat.receiveId : chat.sendId;
      if (!recentChatsMap.containsKey(otherUserId) ||
          chat.date.isAfter(recentChatsMap[otherUserId]!.date)) {
        recentChatsMap[otherUserId] = chat;
      }
    }

    // Convert to list and sort by date
    List<ChatModel> recentChats = recentChatsMap.values.toList();
    recentChats.sort((a, b) => b.date.compareTo(a.date));

    _chatController.add(recentChats);
  }

  @override
  void dispose() {
    _sendSubscription.cancel();
    _receiveSubscription.cancel();
    _chatController.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat List'),
      ),
      body: StreamBuilder<List<ChatModel>>(
        stream: _chatController.stream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(child: Text('Error loading chats'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No chats found'));
          }

          final chats = snapshot.data!;

          return ListView.builder(
            itemCount: chats.length,
            itemBuilder: (context, index) {
              final chat = chats[index];
              final isSentByMe = chat.sendId == FirebaseAuth.instance.currentUser!.uid;
              final otherUserId = isSentByMe ? chat.receiveId : chat.sendId;

              return ListTile(
                title: Text('Chat with $otherUserId'),
                subtitle: Text(chat.text),
                trailing: Text(
                  _formatDate(chat.date),
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SelectChatRoom(otherUserId: otherUserId),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 7) {
      return '${date.year}-${date.month}-${date.day}';
    } else if (difference.inDays > 1) {
      return '${difference.inDays} days ago';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inHours > 1) {
      return '${difference.inHours} hours ago';
    } else if (difference.inMinutes > 1) {
      return '${difference.inMinutes} minutes ago';
    } else {
      return 'Just now';
    }
  }
}
