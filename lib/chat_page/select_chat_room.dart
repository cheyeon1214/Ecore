import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../cosntants/firestore_key.dart';
import '../models/firestore/chat_model.dart';

class SelectChatRoom extends StatefulWidget {
  final String otherUserId;

  const SelectChatRoom({Key? key, required this.otherUserId}) : super(key: key);

  @override
  _SelectChatRoomState createState() => _SelectChatRoomState();
}

class _SelectChatRoomState extends State<SelectChatRoom> {
  final _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  User? loggedInUser;

  @override
  void initState() {
    super.initState();
    getCurrentUser();
  }

  void getCurrentUser() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        setState(() {
          loggedInUser = user;
        });
      }
    } catch (e) {
      print(e);
    }
  }

  // 로그인된 사용자가 보낸 메시지
  Stream<List<ChatModel>> _fetchMyMessages() {
    if (loggedInUser == null) {
      return Stream.value([]);
    }

    return FirebaseFirestore.instance
        .collection(COLLECTION_CHATS)
        .where(KEY_SEND_USERID, isEqualTo: loggedInUser!.uid)
        .where(KEY_RECEIVE_USERID, isEqualTo: widget.otherUserId)
        .orderBy(KEY_DATE, descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => ChatModel.fromMap(doc.data() as Map<String, dynamic>))
        .toList());
  }

  // 다른 사용자가 보낸 메시지
  Stream<List<ChatModel>> _fetchOtherMessages() {
    if (loggedInUser == null) {
      return Stream.value([]);
    }

    return FirebaseFirestore.instance
        .collection(COLLECTION_CHATS)
        .where(KEY_SEND_USERID, isEqualTo: widget.otherUserId)
        .where(KEY_RECEIVE_USERID, isEqualTo: loggedInUser!.uid)
        .orderBy(KEY_DATE, descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => ChatModel.fromMap(doc.data() as Map<String, dynamic>))
        .toList());
  }

  void _sendMessage(String text) async {
    if (loggedInUser == null) return;

    final receiveId = await _getReceiverId();
    if (receiveId == null) {
      print('Receiver ID is null');
      return;
    }

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
    _scrollToBottom();
  }

  Future<String?> _getReceiverId() async {
    if (loggedInUser == null) return null;

    // 수신자의 ID는 `widget.otherUserId`에서 가져옵니다.
    return widget.otherUserId;
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
        body: Center(child: Text('User not logged in')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Chat with ${widget.otherUserId}'),
      ),
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

                    // 두 스트림의 데이터를 합침
                    final allMessages = [
                      ...mySnapshot.data ?? [],
                      ...otherSnapshot.data ?? []
                    ];

                    // 날짜 순으로 메시지 정렬
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
                                color: isMe ? Colors.grey[300] : Colors.grey[500],
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
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(labelText: 'Send a message...'),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: () {
                    final message = _controller.text.trim();
                    if (message.isNotEmpty) {
                      _sendMessage(message);
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
