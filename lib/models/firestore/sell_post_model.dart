import '../../cosntants/firestore_key.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SellPostModel {
  final String sellId; // sellPost ID
  final String marketId; // 마켓 ID (외래키)
  final String title;
  final String img;
  final int price;
  final String category;
  final String body;
  final DateTime createdAt;
  final int viewCount;
  final DocumentReference reference;

  SellPostModel({
    required this.sellId,
    required this.price,
    required this.title,
    required this.img,
    required this.category,
    required this.body,
    required this.marketId,
    required this.createdAt,
    required this.viewCount,
    required this.reference,
  });

  SellPostModel.fromMap(Map<String, dynamic> map, this.sellId, {required this.reference})
      : title = map[KEY_SELLTITLE] ?? '',
        marketId = map[KEY_SELL_MARKETID] ?? '',
        img = map[KEY_SELLIMG] ?? 'https://via.placeholder.com/150',
        price = (map[KEY_SELLPRICE] as num).toInt() ?? 0,
        category = map[KEY_SELLCATEGORY] ?? '기타',
        body = map[KEY_SELLBODY] ?? '내용 없음',
        createdAt = (map[KEY_DONA_CREATED_AT] as Timestamp?)?.toDate() ??
          DateTime.now(),
        viewCount = map[KEY_DONA_VIEW_COUNT] ?? 0;

  SellPostModel.fromSnapshot(DocumentSnapshot snapshot)
      : this.fromMap(snapshot.data() as Map<String, dynamic>, snapshot.id, reference: snapshot.reference);
}


Future<bool> isUserMarketMatched(SellPostModel sellPost) async {
  try {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      print('User is not logged in.');
      return false;
    }

    final userDoc = await FirebaseFirestore.instance
        .collection('Users')
        .doc(user.uid)
        .get();

    if (!userDoc.exists) {
      print('User document does not exist.');
      return false;
    }

    final userMarketId = userDoc.data()?['marketId'] as String?;

    if (userMarketId == null) {
      print('User market ID does not exist.');
      return false;
    }
    return sellPost.marketId == userMarketId;
  } catch (e) {
    print('Error checking market match: $e');
    return false;
  }
}
