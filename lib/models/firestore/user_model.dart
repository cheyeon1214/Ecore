import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecore/cosntants/firestore_key.dart';
import 'package:flutter/cupertino.dart';
class UserModel extends ChangeNotifier{

  final String userKey;
  final String profileImg;
  final String email;
  final List<dynamic> myPosts;
  final int followers;
  final List<dynamic> likedPosts;
  final String username;
  final List<dynamic> followings;
  List<dynamic> cart;
  final DocumentReference? reference;

  UserModel.fromMap(Map<String, dynamic> map, this.userKey, {this.reference})
      : username = map[KEY_USERNAME],
        profileImg = map[KEY_PROFILEIMG],
        email = map[KEY_EMAIL],
        followers = map[KEY_FOLLOWERS],
        likedPosts = map[KEY_LIKEDPOSTS],
        followings = map[KEY_FOLLOWINGS],
        myPosts = map[KEY_MYPOSTS],
        cart = List.from(map[KEY_CART]);

  UserModel.fromSnapshot(DocumentSnapshot snapshot)
      : this.fromMap(
    snapshot.data() as Map<String, dynamic>,
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
    map[KEY_CART] = [];
    return map; // 반환값 추가
  }
}
