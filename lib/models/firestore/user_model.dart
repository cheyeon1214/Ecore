import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';

class UserModel extends ChangeNotifier {
  late final String userKey;
  late final String profileImg;
  late final String email;
  late final List<dynamic> myPosts;
  late final int followers;
  late final List<dynamic> likedPosts;
  late final String username;
  late final List<dynamic> followings;
  List<dynamic> cart = [];
  late final DocumentReference? reference;
  String? marketId; // marketId를 nullable로 설정

  UserModel({
    this.userKey = '',
    this.profileImg = '',
    this.email = '',
    this.myPosts = const [],
    this.followers = 0,
    this.likedPosts = const [],
    this.username = '',
    this.followings = const [],
    List<dynamic>? cart,
    this.reference,
    this.marketId,
  }) : cart = cart ?? [];

  UserModel.fromMap(Map<String, dynamic> map, this.userKey, {this.reference})
      : username = map['username'] ?? '',
        profileImg = map['profileImg'] ?? '',
        email = map['email'] ?? '',
        followers = map['followers'] ?? 0,
        likedPosts = List.from(map['likedPosts'] ?? []),
        followings = List.from(map['followings'] ?? []),
        myPosts = List.from(map['myPosts'] ?? []),
        cart = List.from(map['cart'] ?? []),
        marketId = (map['marketId'] ?? '').isNotEmpty ? map['marketId'] : null;

  UserModel.fromSnapshot(DocumentSnapshot snapshot)
      : this.fromMap(
    snapshot.data() != null ? snapshot.data() as Map<String, dynamic> : {},
    snapshot.id,
    reference: snapshot.reference,
  );

  static Map<String, dynamic> getMapForCreateUser(String email) {
    Map<String, dynamic> map = {};
    map['profileImg'] = "";
    map['username'] = email.split("@")[0];
    map['email'] = email;
    map['likedPosts'] = [];
    map['followers'] = 0;
    map['followings'] = [];
    map['myPosts'] = [];
    map['cart'] = [];
    map['marketId'] = ''; // 기본값 설정, 필요에 따라 변경
    return map;
  }

  Future<void> fetchUserData(String uid) async {
    final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
    if (doc.exists) {
      final data = doc.data() as Map<String, dynamic>;
      this.userKey = doc.id;
      this.username = data['username'] ?? '';
      this.profileImg = data['profileImg'] ?? '';
      this.email = data['email'] ?? '';
      this.followers = data['followers'] ?? 0;
      this.likedPosts = List.from(data['likedPosts'] ?? []);
      this.followings = List.from(data['followings'] ?? []);
      this.myPosts = List.from(data['myPosts'] ?? []);
      this.cart = List.from(data['cart'] ?? []);
      this.marketId = (data['marketId'] ?? '').isNotEmpty ? data['marketId'] : null;
      this.reference = doc.reference;

      notifyListeners();
    }
  }

  void updateCart(List<dynamic> updatedCart) {
    cart = updatedCart;
    notifyListeners();
  }
}
