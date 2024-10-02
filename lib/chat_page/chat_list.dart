import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecore/chat_page/select_chat_room.dart';
import 'package:rxdart/rxdart.dart';
import 'dart:async';

import '../models/firestore/chat_model.dart';
import '../cosntants/firestore_key.dart';

class ChatList extends StatefulWidget {
  const ChatList({Key? key}) : super(key: key);

  @override
  State<ChatList> createState() => _ChatListState();
}

class _ChatListState extends State<ChatList> {
  final StreamController<List<ChatModel>> _chatController = StreamController<List<ChatModel>>.broadcast();
  final Map<String, String> _usernameCache = {};
  final Map<String, String> _userIdCache = {};

  late StreamSubscription<QuerySnapshot<Map<String, dynamic>>> _sendSubscription;
  late StreamSubscription<QuerySnapshot<Map<String, dynamic>>> _receiveSubscription;
  late StreamSubscription<QuerySnapshot<Map<String, dynamic>>> _marketSendSubscription;
  late StreamSubscription<QuerySnapshot<Map<String, dynamic>>> _marketReceiveSubscription;

  @override
  void initState() {
    super.initState();
    _setupStreams();
  }

  void _setupStreams() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    final userId = user.uid;

    try {
      final marketId = await _getMarketIdForUser(userId);
      
      // 현재유저 = 유저 id 경우
      final messageStream = FirebaseFirestore.instance
          .collection(COLLECTION_CHATS)
          .where(KEY_SEND_USERID, isEqualTo: userId)
          .snapshots();

      final receivedStream = FirebaseFirestore.instance
          .collection(COLLECTION_CHATS)
          .where(KEY_RECEIVE_USERID, isEqualTo: userId)
          .snapshots();

      // 현재유저 = 마켓 id 경우
      final marketMessageStream = FirebaseFirestore.instance
          .collection(COLLECTION_CHATS)
          .where(KEY_SEND_USERID, isEqualTo: marketId)
          .snapshots();

      final marketReceivedStream = FirebaseFirestore.instance
          .collection(COLLECTION_CHATS)
          .where(KEY_RECEIVE_USERID, isEqualTo: marketId)
          .snapshots();

      Rx.combineLatest4(
        messageStream,
        receivedStream,
        marketMessageStream,
        marketReceivedStream,
            (QuerySnapshot<Map<String, dynamic>> sendSnapshot,
            QuerySnapshot<Map<String, dynamic>> receiveSnapshot,
            QuerySnapshot<Map<String, dynamic>> marketSendSnapshot,
            QuerySnapshot<Map<String, dynamic>> marketReceiveSnapshot) {
          final userMessages = [...sendSnapshot.docs, ...receiveSnapshot.docs];
          final marketMessages = [...marketSendSnapshot.docs, ...marketReceiveSnapshot.docs];
          _processChatUpdates(userMessages, marketMessages, userId, marketId!);
        },
      ).listen(null);
    } catch (error) {
      print('Error setting up streams: $error');
    }
  }

  void _processChatUpdates(
      List<QueryDocumentSnapshot<Map<String, dynamic>>> userMessages,
      List<QueryDocumentSnapshot<Map<String, dynamic>>> marketMessages,
      String userId,
      String marketId) async {
    try {
      List<ChatModel> allChats = [
        ...userMessages.map((doc) => ChatModel.fromSnapshot(doc)),
        ...marketMessages.map((doc) => ChatModel.fromSnapshot(doc)),
      ];

      // 상대방 유저 기준으로 메시지 그룹화
      Map<String, ChatModel> recentChatsMap = {};
      for (var chat in allChats) {
        if (chat.sendId == marketId && chat.receiveId == marketId) {
          continue; // 자신의 마켓과 주고받은 메시지는 제외
        }

        final otherUserId = chat.sendId == userId || chat.sendId == marketId
            ? chat.receiveId
            : chat.sendId;

        // 상대방 id를 캐시에 저장해 고정된 값으로 사용
        if (!_userIdCache.containsKey(chat.chatId)) {
          _userIdCache[chat.chatId] = otherUserId;
        }

        if (!recentChatsMap.containsKey(otherUserId) ||
            chat.date.isAfter(recentChatsMap[otherUserId]!.date)) {
          recentChatsMap[otherUserId] = chat;
        }
      }
      
      List<ChatModel> recentChats = recentChatsMap.values.toList();
      recentChats.sort((a, b) => b.date.compareTo(a.date));
      
      _chatController.add(recentChats); //채팅 리스트 스트림에 추가
    } catch (e) {
      print('Error processing chats: $e');
    }
  }


  Future<String?> _getMarketIdForUser(String userId) async {
    try {
      final userDoc = await FirebaseFirestore.instance
          .collection('Users')
          .doc(userId)
          .get();

      if (userDoc.exists) {
        final data = userDoc.data();
        final marketId = data?['marketId'] as String?;
        return marketId;
      }
    } catch (e) {
      print('Error fetching market ID: $e');
    }

    return null; //마켓 id 없는 경우
  }

  Future<String> _getOrFetchUsername(String userId) async {
    if (_usernameCache.containsKey(userId)) {
      return _usernameCache[userId]!;
    }

    // 캐시에 없으면 Firestore에서 가져와 캐시에 저장
    final username = await _getUsernameOrMarketName(userId);
    _usernameCache[userId] = username;
    return username;
  }

  Future<String> _getUsernameOrMarketName(String userId) async {
    if (_usernameCache.containsKey(userId)) {
      return _usernameCache[userId]!;
    }

    final userDoc = await FirebaseFirestore.instance.collection('Users').doc(userId).get();
    if (userDoc.exists) {
      final username = userDoc.data()?[KEY_USERNAME] ?? 'Unknown';
      _usernameCache[userId] = username;
      return username;
    }

    final marketDoc = await FirebaseFirestore.instance.collection('Markets').doc(userId).get();
    if (marketDoc.exists) {
      final marketName = marketDoc.data()?[KEY_MARKET_NAME] ?? 'Unknown';
      _usernameCache[userId] = marketName;
      return marketName;
    }

    return 'Unknown';
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
        stream: _chatController.stream, // 채팅 리스트를 스트림에서 가져옴
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
              final otherUserId = _userIdCache[chat.chatId]!;

              return FutureBuilder<String>(
                future: _getOrFetchUsername(otherUserId),
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
                    title: Text(username),
                    subtitle: Text(chat.text),
                    trailing: Text(
                      _formatDate(chat.date),
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
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
