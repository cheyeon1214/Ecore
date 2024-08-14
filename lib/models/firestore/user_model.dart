import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecore/cosntants/firestore_key.dart';
import 'package:flutter/cupertino.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserModel extends ChangeNotifier {
  String userKey = '';
  String profileImg = '';
  String email = '';
  List<dynamic> myPosts = [];
  int followers = 0;
  List<dynamic> likedPosts = [];
  String username = '';
  List<dynamic> followings = [];
  List<dynamic> cart = [];
  DocumentReference? reference;

  UserModel();

  UserModel.fromMap(Map<String, dynamic> map, this.userKey, {this.reference})
      : username = map[KEY_USERNAME] ?? '',
        profileImg = map[KEY_PROFILEIMG] ?? '',
        email = map[KEY_EMAIL] ?? '',
        followers = map[KEY_FOLLOWERS] ?? 0,
        likedPosts = List.from(map[KEY_LIKEDPOSTS] ?? []),
        followings = List.from(map[KEY_FOLLOWINGS] ?? []),
        myPosts = List.from(map[KEY_MYPOSTS] ?? []),
        cart = List.from(map[KEY_CART] ?? []);

  UserModel.fromSnapshot(DocumentSnapshot snapshot)
      : this.fromMap(
    snapshot.data() != null ? snapshot.data() as Map<String, dynamic> : {},
    snapshot.id,
    reference: snapshot.reference,
  );

  static Map<String, dynamic> getMapForCreateUser(String email) {
    return {
      KEY_PROFILEIMG: "",
      KEY_USERNAME: email.split("@")[0],
      KEY_EMAIL: email,
      KEY_LIKEDPOSTS: [],
      KEY_FOLLOWERS: 0,
      KEY_FOLLOWINGS: [],
      KEY_MYPOSTS: [],
      KEY_CART: [],
    };
  }

  Future<void> fetchUserData(String uid) async {
    final User? user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      print("No user is currently signed in.");
      return;
    }

    final String uid = user.uid;
    final userRef = FirebaseFirestore.instance.collection('Users').doc(uid);
    final doc = await userRef.get();

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
      this.cart = List.from(data[KEY_CART] ?? []);
      this.reference = doc.reference;

      notifyListeners();
    } else {
      print("User document does not exist");
    }
  }

  void updateCart(List<dynamic> updatedCart) async {
    cart = updatedCart;

    if (reference != null) {
      try {
        await reference!.update({
          KEY_CART: cart,
        });
      } catch (e) {
        print("Failed to update cart: $e");
      }
    } else {
      print("Error: reference is null");
    }

    notifyListeners();
  }
}