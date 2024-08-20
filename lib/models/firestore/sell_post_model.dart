import 'package:cloud_firestore/cloud_firestore.dart';
import '../../cosntants/firestore_key.dart';

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

  // Map<String, dynamic>으로 변환
  Map<String, dynamic> toMap() {
    return {
      KEY_SELLID: sellId,
      KEY_SELL_MARKETID: marketId,
      KEY_SELLTITLE: title,
      KEY_SELLIMG: img,
      KEY_SELLPRICE: price,
      KEY_SELLCATEGORY: category,
      KEY_SELLBODY: body,
      KEY_SELL_CREATED_AT: Timestamp.fromDate(createdAt),
      KEY_SELL_VIEW_COUNT: viewCount,
    };
  }

  // Firestore의 Map 데이터를 객체로 변환
  SellPostModel.fromMap(Map<String, dynamic> map, this.sellId, {required this.reference})
      : title = map[KEY_SELLTITLE] ?? '',
        marketId = map[KEY_SELL_MARKETID] ?? '',
        img = map[KEY_SELLIMG] ?? 'https://via.placeholder.com/150',
        price = (map[KEY_SELLPRICE] as num).toInt(),
        category = map[KEY_SELLCATEGORY] ?? '기타',
        body = map[KEY_SELLBODY] ?? '내용 없음',
        createdAt = (map[KEY_SELL_CREATED_AT] as Timestamp?)?.toDate() ?? DateTime.now(),
        viewCount = map[KEY_SELL_VIEW_COUNT] ?? 0;

  // DocumentSnapshot에서 객체 생성
  SellPostModel.fromSnapshot(DocumentSnapshot snapshot)
      : this.fromMap(snapshot.data() as Map<String, dynamic>, snapshot.id, reference: snapshot.reference);
}
