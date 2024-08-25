import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../cosntants/firestore_key.dart';
import '../models/firestore/chat_model.dart';
import 'package:async/async.dart';

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
  String? _initialMessage;
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
      final receiveId = await _getReceiverId();
      yield* FirebaseFirestore.instance
          .collection(COLLECTION_CHATS)
          .where(KEY_SEND_USERID, isEqualTo: loggedInUser!.uid)
          .where(KEY_RECEIVE_USERID, isEqualTo: receiveId)
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
      final receiveId = await _getReceiverId();
      yield* FirebaseFirestore.instance
          .collection(COLLECTION_CHATS)
          .where(KEY_SEND_USERID, isEqualTo: receiveId)
          .where(KEY_RECEIVE_USERID, isEqualTo: loggedInUser!.uid)
          .orderBy(KEY_DATE, descending: false)
          .snapshots()
          .map((snapshot) => snapshot.docs
          .map((doc) => ChatModel.fromMap(doc.data() as Map<String, dynamic>))
          .toList());
    }
  }

  Stream<List<ChatModel>> _combineStreams() {
    final myMessagesStream = _fetchMyMessages();
    final otherMessagesStream = _fetchOtherMessages();

    return StreamGroup.merge([myMessagesStream, otherMessagesStream]).map((List<List<ChatModel>> results) {
      final myMessages = results[0];
      final otherMessages = results[1];
      final allMessages = [...myMessages, ...otherMessages];
      allMessages.sort((a, b) => a.date.compareTo(b.date));
      return allMessages;
    } as List<ChatModel> Function(List<ChatModel> event));
  }


  List<ChatModel> _getSortedMessages(List<ChatModel> myMessages, List<ChatModel> otherMessages) {
    final allMessages = [...myMessages, ...otherMessages];
    allMessages.sort((a, b) => a.date.compareTo(b.date));
    return allMessages;
  }

  Future<void> startOrGetChat(String initialMessage) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      print('User not logged in');
      return;
    }
    final String senderId = user.uid;

    String? receiverId = await _getReceiverId();

    if (receiverId == null) {
      print('Receiver ID could not be fetched.');
      return;
    }

    String chatId = await _findExistingChatId(senderId, receiverId);

    if (chatId.isEmpty) {
      chatId = FirebaseFirestore.instance.collection(COLLECTION_CHATS).doc().id;
      ChatModel newChat = ChatModel(
        chatId: chatId,
        sendId: senderId,
        receiveId: receiverId,
        date: DateTime.now(),
        text: initialMessage,
      );

      await FirebaseFirestore.instance
          .collection(COLLECTION_CHATS)
          .doc(chatId)
          .set(newChat.toMap());

      print('New chat started with ID: $chatId');
    } else {
      print('Existing chat found with ID: $chatId');
    }
  }

  Future<String> _findExistingChatId(String senderId, String receiverId) async {
    try {
      final chatQuerySnapshot = await FirebaseFirestore.instance
          .collection(COLLECTION_CHATS)
          .where(KEY_SEND_USERID, isEqualTo: senderId)
          .where(KEY_RECEIVE_USERID, isEqualTo: receiverId)
          .get();

      if (chatQuerySnapshot.docs.isNotEmpty) {
        return chatQuerySnapshot.docs.first.id;
      }

      final receivedChatQuerySnapshot = await FirebaseFirestore.instance
          .collection(COLLECTION_CHATS)
          .where(KEY_SEND_USERID, isEqualTo: receiverId)
          .where(KEY_RECEIVE_USERID, isEqualTo: senderId)
          .get();

      if (receivedChatQuerySnapshot.docs.isNotEmpty) {
        return receivedChatQuerySnapshot.docs.first.id;
      }

      return '';
    } catch (e) {
      print('Error finding existing chat: $e');
      return '';
    }
  }

  void _sendMessage(String text) async {
    if (loggedInUser == null || text.trim().isEmpty) return;

    final receiveId = await _getReceiverId();
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

  Future<String?> _getReceiverId() async {
    final marketDoc = await FirebaseFirestore.instance
        .collection('Markets')
        .doc(widget.marketId)
        .get();

    if (!marketDoc.exists) {
      print('Market document does not exist for ID: $marketDoc');
      return null;
    }

    final marketData = marketDoc.data();
    final receiveId = marketData?['userId'] as String?;

    return receiveId;
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
        body: Center(child: Text('User not logged in')),
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
