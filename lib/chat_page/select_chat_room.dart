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
  final Map<String, String> _usernameCache = {};

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
        title: FutureBuilder<String>(
          future: _getUsername(widget.otherUserId), // 유저네임을 가져옴
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Text('Loading...');
            } else if (snapshot.hasError || !snapshot.hasData) {
              return Text('Error');
            } else {
              return Text(
                '${snapshot.data}',
                style: TextStyle(
                  fontSize: 22, // 사용자 이름의 크기
                  fontWeight: FontWeight.bold, // 사용자 이름의 굵기
                ),
              );
            }
          },
        ),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(20.0), // 구분선의 높이 설정
          child: Padding(
            padding: const EdgeInsets.only(bottom: 15),
            child: Container(
              color: Colors.grey[300], // 구분선 색상
              height: 3.0, // 구분선의 두께
            ),
          ),
        ),
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
                      border: Border.all(color: Colors.grey[300]!), // 선택적으로 테두리 추가
                    ),
                    child: TextField(
                      controller: _controller,
                      decoration: InputDecoration(
                        hintText: 'Send a message...',
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 8.0), // 텍스트 필드와 버튼 사이의 간격
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.blue[300], // 버튼 배경색
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
