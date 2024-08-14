import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecore/cosntants/firestore_key.dart';
import 'package:flutter/material.dart';
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

  UserModel({
    this.userKey = '',
    this.profileImg = '',
    this.email = '',
    List<dynamic>? myPosts,
    this.followers = 0,
    List<dynamic>? likedPosts,
    this.username = '',
    List<dynamic>? followings,
    List<dynamic>? cart,
    this.reference,
  })  : myPosts = myPosts ?? [],
        likedPosts = likedPosts ?? [],
        followings = followings ?? [],
        cart = cart ?? [];

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

  Future<void> createOrder(List<dynamic> items) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      print('No user is currently logged in');
      return;
    }

    try {
      final orderId = FirebaseFirestore.instance.collection('orders').doc().id;
      final orderData = {
        'orderId': orderId,
        'items': items,
        'totalPrice': items.fold(0, (sum, item) {
          final price = item['price'] as int?;
          final quantity = item['quantity'] as int? ?? 1;
          return sum + (price ?? 0) * quantity;
        }),
        'date': FieldValue.serverTimestamp(),
      };

      // Create order in orders collection
      await FirebaseFirestore.instance.collection('Users').doc(user.uid).collection('orders').doc(orderId).set(orderData);

      // Optionally clear cart
      cart.clear();
      await updateCart(cart);

      notifyListeners();
    } catch (e) {
      print('Error creating order: $e');
    }
  }

  Future<void> fetchUserData(String uid) async {
    try {
      final doc = await FirebaseFirestore.instance.collection('Users').doc(uid).get();
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        userKey = doc.id;
        username = data[KEY_USERNAME] ?? '';
        profileImg = data[KEY_PROFILEIMG] ?? '';
        email = data[KEY_EMAIL] ?? '';
        followers = data[KEY_FOLLOWERS] ?? 0;
        likedPosts = List.from(data[KEY_LIKEDPOSTS] ?? []);
        followings = List.from(data[KEY_FOLLOWINGS] ?? []);
        myPosts = List.from(data[KEY_MYPOSTS] ?? []);
        cart = List.from(data[KEY_CART] ?? []);
        reference = doc.reference;

        notifyListeners();
      }
    } catch (e) {
      print('Error fetching user data: $e');
    }
  }

  Stream<List<Map<String, dynamic>>> get cartStream {
    if (userKey.isEmpty) {
      return Stream.value([]); // Return an empty list if userKey is empty
    }

    return FirebaseFirestore.instance
        .collection('Users')
        .doc(userKey)
        .collection('cart') // Ensure this path is correct
        .snapshots()
        .map((snapshot) {
      final cartItems = snapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();
      print('Cart items: $cartItems'); // Add this line
      return cartItems;
    });
  }

  Future<void> removeCartItem(String itemId) async {
    try {
      await FirebaseFirestore.instance
          .collection('Users')
          .doc(userKey)
          .collection('cart')
          .doc(itemId)
          .delete();
      // Refresh cart after deletion
      final updatedCart = await FirebaseFirestore.instance
          .collection('Users')
          .doc(userKey)
          .collection('cart')
          .get()
          .then((snapshot) => snapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList());
      cart = updatedCart;
      notifyListeners();
    } catch (e) {
      print('Error removing cart item: $e');
    }
  }

  Future<void> updateCart(List<dynamic> updatedCart) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      print('No user is currently logged in');
      return;
    }

    try {
      await FirebaseFirestore.instance.collection('Users').doc(user.uid).update({'cart': updatedCart});
      cart = updatedCart;
      notifyListeners();
    } catch (e) {
      print('Error updating cart: $e');
    }
  }

}
