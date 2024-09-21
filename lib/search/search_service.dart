import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SearchService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> saveSearchTerm(String term) async {
    final userId = _auth.currentUser?.uid; // 현재 사용자 ID 가져오기

    if (userId == null) {
      return; // 로그인하지 않은 경우
    }

    final searchRef = _firestore.collection('Users').doc(userId).collection('recent_searches');

    // 최근 검색어 저장
    await searchRef.add({
      'term': term,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  Future<List<String>> getRecentSearches() async {
    final userId = _auth.currentUser?.uid; // 현재 사용자 ID 가져오기

    if (userId == null) {
      return []; // 로그인하지 않은 경우
    }

    final searchRef = _firestore.collection('Users').doc(userId).collection('recent_searches');

    final querySnapshot = await searchRef.orderBy('timestamp', descending: true).limit(10).get();
    return querySnapshot.docs.map((doc) => doc['term'] as String).toList();
  }

}
