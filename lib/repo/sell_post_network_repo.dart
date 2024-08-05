import 'package:cloud_firestore/cloud_firestore.dart';

class SellPostNetworkRepo {
  Future<void> sendData(){
    return FirebaseFirestore.instance
        .collection('SellProducts')
        .doc('111')
        .set({'title':'title','category':'상의','body':'red,soft'});
  }

  void getData(String select){
    FirebaseFirestore.instance
        .collection('SellProducts')
        .where('category', isEqualTo: select)  // category가 '상의'인 문서들만 필터링
        .get()
        .then((querySnapshot) {
      querySnapshot.docs.forEach((doc) {
        print(doc.data());
      });
    });
  }
}

SellPostNetworkRepo sellPostNetworkRepo = SellPostNetworkRepo();