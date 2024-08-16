import 'package:cloud_firestore/cloud_firestore.dart';

import '../../cosntants/firestore_key.dart';

class MarketModel {
  final String userId;
  final String marketId;
  final String name;
  final String img;
  final List<dynamic> sellPosts; // 판매글 ID 리스트
  final DocumentReference reference;

  MarketModel.fromMap(Map<String, dynamic> map, this.marketId,
      {required this.reference})
      : name = map[KEY_MARKET_NAME] ?? '',
        userId = map[KEY_MARKET_USERKEY] ?? '',
        img = map[KEY_MARKET_PROFILEIMG] ?? 'https://via.placeholder.com/150',
        sellPosts = List<dynamic>.from(map[KEY_MYSELLPOST] ?? []); // 기본값 빈 리스트

  MarketModel.fromSnapshot(DocumentSnapshot snapshot)
      : this.fromMap(snapshot.data() as Map<String, dynamic>, snapshot.id,
      reference: snapshot.reference);


  Stream<List<dynamic>> get sellPostsStream {
    print(marketId);

    if (marketId.isEmpty) {
      return Stream.value([]);
    }

    return FirebaseFirestore.instance
        .collection('Markets')
        .doc(marketId)
        .snapshots()
        .map((snapshot) {
      final data = snapshot.data() as Map<String, dynamic>?;
      if (data == null) {
        return [];
      }

      final sellPosts = data[KEY_MYSELLPOST] as List<dynamic>? ?? [];
      print(sellPosts);

      // sellPosts를 그대로 반환
      return sellPosts;
    });
  }

}
