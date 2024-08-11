import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecore/cosntants/firestore_key.dart';
import 'package:flutter/cupertino.dart';
class UserModel extends ChangeNotifier{

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
  }) : cart = cart ?? [];

  UserModel.fromMap(Map<String, dynamic> map, this.userKey, {this.reference})
      : username = map[KEY_USERNAME],
        profileImg = map[KEY_PROFILEIMG],
        email = map[KEY_EMAIL],
        followers = map[KEY_FOLLOWERS],
        likedPosts = map[KEY_LIKEDPOSTS],
        followings = map[KEY_FOLLOWINGS],
        myPosts = map[KEY_MYPOSTS]
        // cart = List.from(map[KEY_CART])
  ;

  UserModel.fromSnapshot(DocumentSnapshot snapshot)
      : this.fromMap(
      snapshot.data() != null ? snapshot.data() as Map<String, dynamic> : {},
  snapshot.id,
  reference: snapshot.reference,
  );

  static Map<String, dynamic> getMapForCreateUser(String email) {
    Map<String, dynamic> map = {};
    map[KEY_PROFILEIMG] = "";
    map[KEY_USERNAME] = email.split("@")[0];
    map[KEY_EMAIL] = email;
    map[KEY_LIKEDPOSTS] = [];
    map[KEY_FOLLOWERS] = 0;
    map[KEY_FOLLOWINGS] = [];
    map[KEY_MYPOSTS] = [];
    // map[KEY_CART] = [];
    return map;
  }

  Future<void> fetchUserData(String uid) async {
    final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
    if (doc.exists) {
      final data = doc.data() as Map<String, dynamic>;
      this.userKey = doc.id;
      this.username = data[KEY_USERNAME] ?? '';
      this.profileImg = data[KEY_PROFILEIMG] ?? '';
      this.email = data[KEY_EMAIL] ?? '';
      this.followers = data[KEY_FOLLOWERS] ?? 0;
      this.likedPosts = List.from(data[KEY_LIKEDPOSTS] ?? []);
      this.followings = List.from(data[KEY_FOLLOWINGS] ?? []);
      this.myPosts = List.from(data[KEY_MYPOSTS] ?? []);
      // this.cart = List.from(data[KEY_CART] ?? []);
      this.reference = doc.reference;

      notifyListeners();
    }
  }

  void updateCart(List<dynamic> updatedCart) {
    cart = updatedCart;
    notifyListeners();
  }
}
