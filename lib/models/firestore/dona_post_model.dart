import '../../cosntants/firestore_key.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DonaPostModel {
  final String userId;
  final String title;
  final String img;
  final String category;
  final String body;
  final DocumentReference reference;

  DonaPostModel.fromMap(Map<String, dynamic> map, this.userId,
      {required this.reference})
      : title = map[KEY_DONATITLE],
        img = map[KEY_DONAIMG],
        category = map[KEY_DONACATEGORY],
        body = map[KEY_DONABODY];

  DonaPostModel.fromSnapshot(DocumentSnapshot snapshot)
      : this.fromMap(snapshot.data() as Map<String, dynamic>, snapshot.id,
            reference: snapshot.reference);
}
