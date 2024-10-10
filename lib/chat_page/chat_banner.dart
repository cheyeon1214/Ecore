import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../cosntants/firestore_key.dart';
import 'chat_room.dart';

class ChatBanner extends StatefulWidget {
  final String marketId;
  const ChatBanner({Key? key, required this.marketId}) : super(key: key);

  @override
  _ChatBannerState createState() => _ChatBannerState();
}

class _ChatBannerState extends State<ChatBanner> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String marketName = '';

  @override
  void initState() {
    super.initState();
    _getMarketName();
  }

  Future<void> _getMarketName() async {
    try {
      // Reference to the Firestore collection
      DocumentSnapshot marketSnapshot = await FirebaseFirestore.instance
          .collection('Markets')
          .doc(widget.marketId)
          .get();

      if (marketSnapshot.exists) {
        setState(() {
          marketName = marketSnapshot[KEY_MARKET_NAME] ?? 'No Name Available';
        });
      }
    } catch (e) {
      print('Error getting market name: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text(marketName.isEmpty ? 'Chat' : marketName, style: TextStyle(
        fontSize: 22,
        fontFamily: 'NanumSquare',
        )),
      ),
      body: ChatRoom(marketId: widget.marketId),
    );
  }
}
