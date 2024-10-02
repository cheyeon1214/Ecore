import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:rxdart/rxdart.dart';

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

  Future<String?> _getMarketIdForUser(String userId) async {
    final querySnapshot = await FirebaseFirestore.instance
        .collection('Markets')
        .where(KEY_MARKET_USERKEY, isEqualTo: userId)
        .get();

    if (querySnapshot.docs.isEmpty) return null;

    return querySnapshot.docs.first.id;
  }

  Future<bool> _isMarketId(String id) async {
    final querySnapshot = await FirebaseFirestore.instance
        .collection('Markets')
        .doc(id)
        .get();

    return querySnapshot.exists;
  }

  Stream<List<ChatModel>> _fetchMessages(String loggedInUser, String otherUserId) {
    final myMessages = FirebaseFirestore.instance
        .collection(COLLECTION_CHATS)
        .where(KEY_SEND_USERID, isEqualTo: loggedInUser)
        .where(KEY_RECEIVE_USERID, isEqualTo: otherUserId)
        .orderBy(KEY_DATE, descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => ChatModel.fromMap(doc.data() as Map<String, dynamic>))
        .toList());

    final otherMessages = FirebaseFirestore.instance
        .collection(COLLECTION_CHATS)
        .where(KEY_SEND_USERID, isEqualTo: otherUserId)
        .where(KEY_RECEIVE_USERID, isEqualTo: loggedInUser)
        .orderBy(KEY_DATE, descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => ChatModel.fromMap(doc.data() as Map<String, dynamic>))
        .toList());

    return Rx.combineLatest2(myMessages, otherMessages, (myMessages, otherMessages) {
      final allMessages = [...myMessages, ...otherMessages];
      allMessages.sort((a, b) => a.date.compareTo(b.date));
      return allMessages;
    });
  }

  void _sendMessage(String text) async {
    if (loggedInUser == null) return;

    final receiveId = widget.otherUserId;
    if (receiveId == null) {
      print('Receiver ID is null');
      return;
    }

    final marketId = await _getMarketIdForUser(loggedInUser!.uid);
    if (marketId == null) {
      print('Market ID not found');
      return;
    }

    final isMarketId = await _isMarketId(receiveId);
    final sendId = isMarketId ? loggedInUser!.uid : marketId;

    final newChatRef = FirebaseFirestore.instance.collection(COLLECTION_CHATS).doc();
    final newChatId = newChatRef.id;

    final newChat = ChatModel(
      chatId: newChatId,
      sendId: sendId,
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
      appBar: AppBar(
        title: FutureBuilder<String>(
          future: _getUsernameOrMarketName(widget.otherUserId),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Text('Loading...');
            } else if (snapshot.hasError || !snapshot.hasData) {
              return Text('Error');
            } else {
              return Text(
                '${snapshot.data}',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              );
            }
          },
        ),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(20.0),
          child: Padding(
            padding: const EdgeInsets.only(bottom: 15),
            child: Container(
              color: Colors.grey[300],
              height: 3.0,
            ),
          ),
        ),
      ),
      body: FutureBuilder<String?>(
        future: _getMarketIdForUser(loggedInUser!.uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError || !snapshot.hasData) {
            return Center(child: Text('Error fetching market ID'));
          }

          final marketId = snapshot.data;
          if (marketId == null) {
            return Center(child: Text('Market ID not found'));
          }

          return FutureBuilder<bool>(
            future: _isMarketId(widget.otherUserId),
            builder: (context, isMarketSnapshot) {
              if (isMarketSnapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }

              final isMarketId = isMarketSnapshot.data ?? false;
              final userId1 = isMarketId ? loggedInUser!.uid : marketId;
              final userId2 = widget.otherUserId;

              return StreamBuilder<List<ChatModel>>(
                stream: _fetchMessages(userId1!, userId2),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }

                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(child: Text('No messages found'));
                  }

                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    _scrollToBottom();
                  });

                  final allMessages = snapshot.data!;

                  return ListView.builder(
                    controller: _scrollController,
                    itemCount: allMessages.length,
                    itemBuilder: (ctx, index) {
                      final chat = allMessages[index];
                      bool isMe = chat.sendId == loggedInUser!.uid || chat.sendId == marketId;

                      return Row(
                        mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
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
          );
        },
      ),
      bottomNavigationBar: Padding(
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
    );
  }
}
