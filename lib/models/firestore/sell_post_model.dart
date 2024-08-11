import '../../cosntants/firestore_key.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SellPostModel {
  final String sellId; // sellPost ID
  final String marketId; // 마켓 ID (외래키)
  final String title;
  final String img;
  final int price;
  final String category;
  final String body;
  final DocumentReference reference;

  SellPostModel.fromMap(Map<String, dynamic> map, this.sellId, {required this.reference})
      : title = map[KEY_SELLTITLE] ?? '',
        marketId = map[KEY_SELL_MARKETID] ?? '', // KEY_SELL_MARKETID 사용
        img = map[KEY_SELLIMG] ?? 'https://via.placeholder.com/150',
        price = (map[KEY_SELLPRICE] as num).toInt() ?? 0,
        category = map[KEY_SELLCATEGORY] ?? '기타',
        body = map[KEY_SELLBODY] ?? '내용 없음';

  SellPostModel.fromSnapshot(DocumentSnapshot snapshot)
      : this.fromMap(snapshot.data() as Map<String, dynamic>, snapshot.id, reference: snapshot.reference);
}

