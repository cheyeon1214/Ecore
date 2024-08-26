import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';

import '../models/firestore/chat_model.dart';
import 'package:ecore/chat_page/select_chat_room.dart';
import '../cosntants/firestore_key.dart';
import '../models/firestore/user_model.dart';

class ChatList extends StatefulWidget {
  const ChatList({Key? key}) : super(key: key);

  @override
  State<ChatList> createState() => _ChatListState();
}

class _ChatListState extends State<ChatList> {
  final StreamController<List<ChatModel>> _chatController = StreamController<List<ChatModel>>.broadcast();
  final Map<String, String> _usernameCache = {}; // 사용자 이름 캐시

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

    // 각 사용자와의 최근 메시지만 필터링
    Map<String, ChatModel> recentChatsMap = {};
    for (var chat in allChats) {
      final otherUserId = chat.sendId == userId ? chat.receiveId : chat.sendId;
      if (!recentChatsMap.containsKey(otherUserId) ||
          chat.date.isAfter(recentChatsMap[otherUserId]!.date)) {
        recentChatsMap[otherUserId] = chat;
      }
    }

    // List로 변환 후 날짜순으로 정렬
    List<ChatModel> recentChats = recentChatsMap.values.toList();
    recentChats.sort((a, b) => b.date.compareTo(a.date));

    _chatController.add(recentChats);
  }

  Future<String> _getUsername(String userId) async {
    // 캐시에 username이 있으면 반환
    if (_usernameCache.containsKey(userId)) {
      return _usernameCache[userId]!;
    }

    // Firestore에서 username 가져오기
    final doc = await FirebaseFirestore.instance.collection('Users').doc(userId).get();
    final username = doc.data()?[KEY_USERNAME] ?? 'Unknown';

    // 캐시에 저장
    _usernameCache[userId] = username;

    return username;
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
        title: const Text('채팅'),
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

              return FutureBuilder<String>(
                future: _getUsername(otherUserId), // otherUserId의 username 가져오기
                builder: (context, userSnapshot) {
                  if (userSnapshot.connectionState == ConnectionState.waiting) {
                    return ListTile(
                      title: Text('Loading...'),
                      subtitle: Text(chat.text),
                    );
                  }

                  if (userSnapshot.hasError) {
                    return ListTile(
                      title: Text('Error'),
                      subtitle: Text(chat.text),
                    );
                  }

                  final username = userSnapshot.data ?? 'Unknown';

                  return ListTile(
                    title: Padding(
                      padding: const EdgeInsets.only(bottom: 5),
                      child: Text('$username',style: TextStyle(fontWeight: FontWeight.bold),),
                    ),
                    subtitle: Container(
                      padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                      decoration: BoxDecoration(
                        color: Colors.blue[100], // 배경색 설정
                        borderRadius: BorderRadius.circular(5.0), // 둥글게 만들기
                      ),
                      child: Text(
                        chat.text,
                        style: TextStyle(
                          fontSize: 12,
                        ),
                        overflow: TextOverflow.ellipsis, // 텍스트가 길 경우 말줄임표로 표시
                      ),
                    ),
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
