import 'package:cloud_firestore/cloud_firestore.dart';

import '../../cosntants/firestore_key.dart';

class DonaPostModel {
  final String userId;
  final String title;
  final String img;
  final String category;
  final String body;
  final DocumentReference reference;

  // Named constructor for creating an instance from a map
  DonaPostModel.fromMap(Map<String, dynamic> map, this.userId, {required this.reference})
      : title = map[KEY_DONATITLE] ?? '',  // 기본값 설정
        img = map[KEY_DONAIMG] ?? '',
        category = map[KEY_DONACATEGORY] ?? '',
        body = map[KEY_DONABODY] ?? '';

  // Named constructor for creating an instance from a Firestore snapshot
  DonaPostModel.fromSnapshot(DocumentSnapshot snapshot)
      : this.fromMap(
      snapshot.data() as Map<String, dynamic>,
      snapshot.id,
      reference: snapshot.reference
  );
}
