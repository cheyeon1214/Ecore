import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import '../../cosntants/firestore_key.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChatModel extends ChangeNotifier{
  final String chatId; // Chat ID
  final String sendId; // Sender ID
  final String receiveId; // Receiver ID
  final DateTime date;
  final String text;

  ChatModel({
    required this.chatId,
    required this.sendId,
    required this.receiveId,
    required this.date,
    required this.text,
  });

  // Map<String, dynamic>으로 변환
  Map<String, dynamic> toMap() {
    final map = {
      KEY_CHATID: chatId,
      KEY_SEND_USERID: sendId,
      KEY_RECEIVE_USERID: receiveId,
      KEY_DATE: Timestamp.fromDate(date),
    };
    if (text.isNotEmpty) { // `text`가 비어 있지 않을 때만 포함
      map[KEY_TEXT] = text;
    }
    return map;
  }

  // Firestore의 Map 데이터를 객체로 변환
  factory ChatModel.fromMap(Map<String, dynamic> data) {
    return ChatModel(
      chatId: data['chatId'] ?? '',
      sendId: data['sendId'] ?? '',
      receiveId: data['receiveId'] ?? '',
      date: (data['date'] as Timestamp).toDate(),
      text: data['text'] ?? '',
    );
  }

  // DocumentSnapshot에서 객체 생성
  factory ChatModel.fromSnapshot(DocumentSnapshot snapshot) {
    final data = snapshot.data() as Map<String, dynamic>;

    return ChatModel(
      chatId: snapshot.id, // Document ID를 chatId로 사용
      sendId: data['sendId'] ?? '',
      receiveId: data['receiveId'] ?? '',
      date: (data['date'] as Timestamp).toDate(),
      text: data['text'] ?? '',
    );
  }
}

Future<List<ChatModel>> getChatsByCurrentUser() async {
  try {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      print('User not logged in');
      return [];
    }
    final userId = user.uid;

    final chatSnapshots = await FirebaseFirestore.instance
        .collection(COLLECTION_CHATS)
        .where(KEY_SEND_USERID, isEqualTo: userId)
        .get();

    final receivedChatsSnapshots = await FirebaseFirestore.instance
        .collection(COLLECTION_CHATS)
        .where(KEY_RECEIVE_USERID, isEqualTo: userId)
        .get();

    final allChatSnapshots = chatSnapshots.docs + receivedChatsSnapshots.docs;

    return allChatSnapshots.map((doc) => ChatModel.fromSnapshot(doc)).toList();
  } catch (e) {
    print('Error getting chats: $e');
    return [];
  }
}

// Future<void> startOrGetChat(String sellPostMarketId) async {
//   final user = FirebaseAuth.instance.currentUser;
//   if (user == null) {
//     print('User not logged in');
//     return;
//   }
//   final String senderId = user.uid;
//
//   // 1. Receiver ID 가져오기
//   String? receiverId = await _getReceiverId(sellPostMarketId);
//
//   if (receiverId == null) {
//     print('Receiver ID could not be fetched.');
//     return;
//   }
//
//   // 2. 기존 채팅 ID가 있는지 확인
//   String chatId = await _findExistingChatId(senderId, receiverId);
//
//   if (chatId.isEmpty) {
//     // 3. 기존 채팅이 없으면 새로운 채팅 생성
//     chatId = FirebaseFirestore.instance.collection(COLLECTION_CHATS).doc().id;
//     ChatModel newChat = ChatModel(
//       chatId: chatId,
//       sendId: senderId,
//       receiveId: receiverId,
//       date: DateTime.now(),
//       text: 'first', // 초기 메시지를 빈 문자열로 설정
//     );
//
//     await FirebaseFirestore.instance
//         .collection(COLLECTION_CHATS)
//         .doc(chatId)
//         .set(newChat.toMap());
//
//     print('New chat started with ID: $chatId');
//   } else {
//     print('Existing chat found with ID: $chatId');
//   }
// }
//
//
//
// Future<String> _findExistingChatId(String senderId, String receiverId) async {
//   try {
//     // 발신자와 수신자 ID를 기준으로 채팅 ID를 찾음
//     final chatQuerySnapshot = await FirebaseFirestore.instance
//         .collection(COLLECTION_CHATS)
//         .where(KEY_SEND_USERID, isEqualTo: senderId)
//         .where(KEY_RECEIVE_USERID, isEqualTo: receiverId)
//         .get();
//
//     if (chatQuerySnapshot.docs.isNotEmpty) {
//       return chatQuerySnapshot.docs.first.id; // 기존 채팅 ID 반환
//     }
//
//     // 수신자와 발신자 ID를 기준으로 채팅 ID를 찾음 (양방향 체크)
//     final receivedChatQuerySnapshot = await FirebaseFirestore.instance
//         .collection(COLLECTION_CHATS)
//         .where(KEY_SEND_USERID, isEqualTo: receiverId)
//         .where(KEY_RECEIVE_USERID, isEqualTo: senderId)
//         .get();
//
//     if (receivedChatQuerySnapshot.docs.isNotEmpty) {
//       return receivedChatQuerySnapshot.docs.first.id; // 기존 채팅 ID 반환
//     }
//
//     return ''; // 채팅 ID가 존재하지 않는 경우
//   } catch (e) {
//     print('Error finding existing chat: $e');
//     return ''; // 오류 발생 시 빈 문자열 반환
//   }
// }
//
// Future<String?> _getReceiverId(String marketId) async {
//   try {
//     // 'Markets' 컬렉션에서 'marketId' 문서를 가져옵니다.
//     final marketDoc = await FirebaseFirestore.instance
//         .collection('Markets')
//         .doc(marketId)
//         .get();
//
//     // 문서 데이터가 없는 경우 처리
//     if (!marketDoc.exists) {
//       print('Market document does not exist for ID: $marketId');
//       return null;
//     }
//
//     // 문서 데이터에서 'userId'를 가져옵니다.
//     final marketData = marketDoc.data();
//     final userId = marketData?['userId'] as String?;
//
//     // 'userId' 필드가 없는 경우 처리
//     if (userId == null) {
//       print('userId field is missing in Market document for ID: $marketId');
//     }
//
//     return userId;
//
//   } catch (e) {
//     // 오류 발생 시 처리
//     print('Error fetching receiverId for marketId $marketId: $e');
//     return null;
//   }

