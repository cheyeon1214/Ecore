import '../../cosntants/firestore_key.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SellPostModel {
  final String marketID;
  final String title;
  final String img;
  final int price;
  final String category;
  final String body;
  final DocumentReference reference;

  SellPostModel.fromMap(Map<String, dynamic> map, this.marketID, {required this.reference})
  : title = map[KEY_SELLTITLE],
        img = map[KEY_SELLIMG],
        price = (map[KEY_SELLPRICE] as num).toInt(),
        category = map[KEY_SELLCATEGORY],
        body = map[KEY_SELLBODY];

  SellPostModel.fromSnapshot(DocumentSnapshot snapshot)
  : this.fromMap(
      snapshot.data() as Map<String, dynamic>,
      snapshot.id,
      reference: snapshot.reference
  );


}
