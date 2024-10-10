import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../cosntants/common_color.dart';
import '../cosntants/firestore_key.dart';
import '../models/firestore/chat_model.dart';

class ChatRoom extends StatefulWidget {
  final String marketId;
  const ChatRoom({Key? key, required this.marketId}) : super(key: key);

  @override
  _ChatRoomState createState() => _ChatRoomState();
}

class _ChatRoomState extends State<ChatRoom> {
  final _controller = TextEditingController();
  final _auth = FirebaseAuth.instance;
  User? loggedInUser;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    getCurrentUser();
  }

  void getCurrentUser() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        setState(() {
          loggedInUser = user;
        });
      }
    } catch (e) {
      print(e);
    }
  }

  Future<String?> getChatId(String userId) async {
    final chatQuery = await FirebaseFirestore.instance
        .collection(COLLECTION_CHATS)
        .where('users', arrayContainsAny: [userId, widget.marketId])
        .get();

    for (var doc in chatQuery.docs) {
      final data = doc.data();
      List<dynamic> users = data['users'] ?? [];

      if (users.contains(widget.marketId)) {
        return doc.id;
      }
    }

    return null;
  }


  Stream<List<ChatModel>> _fetchAllMessages() async* {
    if (loggedInUser == null) {
      yield [];
      return;
    }

    String? chatId = await getChatId(loggedInUser!.uid);
    if (chatId == null) {
      print('No chat room found for user: ${loggedInUser!.uid} and market: ${widget.marketId}');
      yield [];
      return;
    }

    final messagesStream = FirebaseFirestore.instance
        .collection(COLLECTION_CHATS)
        .doc(chatId)
        .collection(COLLECTION_MESSAGES)
        .orderBy(KEY_DATE, descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => ChatModel.fromMap(doc.data() as Map<String, dynamic>)).toList());

    yield* messagesStream;
  }


  void _sendMessage(String text) async {
    if (loggedInUser == null || text.trim().isEmpty) return;

    final receiveId = widget.marketId;
    if (receiveId == null) return;

    final List<String> userIds = [loggedInUser!.uid, receiveId];

    final chatQuery = await FirebaseFirestore.instance
        .collection(COLLECTION_CHATS)
        .where('users', arrayContainsAny: [loggedInUser!.uid, receiveId])
        .get();

    String chatId;

    if (chatQuery.docs.isNotEmpty) {
      chatId = chatQuery.docs.first.id;
    } else {
      final chatRef = FirebaseFirestore.instance.collection(COLLECTION_CHATS).doc();
      chatId = chatRef.id;

      await chatRef.set({
        KEY_CHATID: chatId,
        'users': userIds,
        KEY_DATE: FieldValue.serverTimestamp()
      });
    }

    final messageRef = FirebaseFirestore.instance
        .collection(COLLECTION_CHATS)
        .doc(chatId)
        .collection(COLLECTION_MESSAGES)
        .doc();

    await messageRef.set({
      KEY_MESSAGE: messageRef.id,
      KEY_TEXT: text,
      KEY_SEND_USERID: loggedInUser!.uid,
      KEY_RECEIVE_USERID: receiveId,
      KEY_READBY: [loggedInUser!.uid],
      KEY_DATE: FieldValue.serverTimestamp()
    });

    setState(() {});

    _controller.clear();
    _scrollToBottom();
  }


  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (loggedInUser == null) {
      return Scaffold(
        body: Center(child: Text('유저가 존재하지 않습니다.')),
      );
    }

    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<List<ChatModel>>(
              stream: _fetchAllMessages(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text('채팅을 시작하세요!'));
                }

                final allMessages = snapshot.data ?? [];

                allMessages.sort((a, b) => a.date.compareTo(b.date));

                WidgetsBinding.instance.addPostFrameCallback((_) {
                  _scrollToBottom();
                });

                return ListView.builder(
                  controller: _scrollController,
                  itemCount: allMessages.length,
                  itemBuilder: (ctx, index) {
                    final chat = allMessages[index];
                    bool isMe = chat.sendId == loggedInUser!.uid;
                    return Row(
                      mainAxisAlignment: isMe
                          ? MainAxisAlignment.end
                          : MainAxisAlignment.start,
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                          margin: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                          decoration: BoxDecoration(
                            color: isMe ? iconColor : Colors.grey[200],
                            borderRadius: isMe
                                ? BorderRadius.only(
                              topLeft: Radius.circular(14),
                              topRight: Radius.circular(14),
                              bottomLeft: Radius.circular(14),
                            )
                                : BorderRadius.only(
                              topLeft: Radius.circular(14),
                              topRight: Radius.circular(14),
                              bottomRight: Radius.circular(14),
                            ),
                          ),
                          child: Text(
                            chat.text,
                            style: TextStyle(
                                fontSize: 15,
                                color: isMe ? Colors.white : Colors.black,
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12.0),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(30.0),
                    ),
                    child: TextField(
                      controller: _controller,
                      decoration: InputDecoration(
                        hintText: '메시지를 입력해주세요.',
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 8.0),
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: iconColor,
                  ),
                  child: IconButton(
                    icon: Icon(Icons.send, color: Colors.white),
                    onPressed: () {
                      final message = _controller.text.trim();
                      if (message.isNotEmpty) {
                        _sendMessage(message);
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
