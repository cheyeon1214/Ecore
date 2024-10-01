import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

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

  Stream<List<ChatModel>> _fetchMyMessages() async* {
    if (loggedInUser == null) {
      yield [];
    } else {
      yield* FirebaseFirestore.instance
          .collection(COLLECTION_CHATS)
          .where(KEY_SEND_USERID, isEqualTo: loggedInUser!.uid)
          .where(KEY_RECEIVE_USERID, isEqualTo: widget.marketId)
          .orderBy(KEY_DATE, descending: false)
          .snapshots()
          .map((snapshot) => snapshot.docs
          .map((doc) => ChatModel.fromMap(doc.data() as Map<String, dynamic>))
          .toList());
    }
  }

  Stream<List<ChatModel>> _fetchOtherMessages() async* {
    if (loggedInUser == null) {
      yield [];
    } else {
      yield* FirebaseFirestore.instance
          .collection(COLLECTION_CHATS)
          .where(KEY_SEND_USERID, isEqualTo: widget.marketId)
          .where(KEY_RECEIVE_USERID, isEqualTo: loggedInUser!.uid)
          .orderBy(KEY_DATE, descending: false)
          .snapshots()
          .map((snapshot) => snapshot.docs
          .map((doc) => ChatModel.fromMap(doc.data() as Map<String, dynamic>))
          .toList());
    }
  }

  void _sendMessage(String text) async {
    if (loggedInUser == null || text.trim().isEmpty) return;

    final receiveId = widget.marketId;
    if (receiveId == null) return;

    final newChatRef = FirebaseFirestore.instance.collection(COLLECTION_CHATS).doc();
    final newChatId = newChatRef.id;

    final newChat = ChatModel(
      chatId: newChatId,
      sendId: loggedInUser!.uid,
      receiveId: receiveId,
      date: DateTime.now(),
      text: text,
    );

    await FirebaseFirestore.instance
        .collection(COLLECTION_CHATS)
        .doc(newChatId)
        .set(newChat.toMap(), SetOptions(merge: true));

    _controller.clear();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
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
              stream: _fetchMyMessages(),
              builder: (context, mySnapshot) {
                return StreamBuilder<List<ChatModel>>(
                  stream: _fetchOtherMessages(),
                  builder: (context, otherSnapshot) {
                    if (mySnapshot.connectionState == ConnectionState.waiting ||
                        otherSnapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    }

                    if (!mySnapshot.hasData && !otherSnapshot.hasData) {
                      return Center(child: Text('No messages found'));
                    }

                    final allMessages = [
                      ...mySnapshot.data ?? [],
                      ...otherSnapshot.data ?? []
                    ];

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
                          mainAxisAlignment:
                          isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
                          children: [
                            Container(
                              padding: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                              margin: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                              decoration: BoxDecoration(
                                color: isMe ? Colors.blue[100] : Colors.grey[300],
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
                                style: TextStyle(fontSize: 16),
                              ),
                            ),
                          ],
                        );
                      },
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
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(30.0),
                      border: Border.all(color: Colors.grey[300]!),
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
                    color: Colors.blue[300],
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
