import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'chat_room.dart';

class ChatBanner extends StatelessWidget {
  final String marketId;
  const ChatBanner({super.key, required this.marketId});

  @override
  Widget build(BuildContext context) {
    final _auth = FirebaseAuth.instance;

    return Scaffold(
      appBar: AppBar(
        title: Text('Chat'),
        actions: [
          IconButton(
            icon: Icon(Icons.exit_to_app),
            onPressed: () {
              _auth.signOut();
              Navigator.pop(context);
            },
          ),
        ],
      ),
      body: ChatRoom(marketId: marketId),
    );
  }
}
