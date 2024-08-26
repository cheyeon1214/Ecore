import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecore/models/firestore/sell_post_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../cosntants/firestore_key.dart';


class UserModel extends ChangeNotifier {
  String userKey = '';
  String profileImg = '';
  String email = '';
  String marketId = '';
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
    this.marketId = '',
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
        cart = List.from(map[KEY_CART] ?? []),
        marketId = (map['marketId'] ?? '').isNotEmpty ? map['marketId'] : null;

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
      KEY_USER_MARKETID : []
    };
  }

  //최근 본 상품 추가
  Future<void> addRecentlyViewed(SellPostModel sellPost) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      print('No user is currently logged in');
      return;
    }

    try {
      final firestore = FirebaseFirestore.instance;
      final userDoc = firestore.collection('Users').doc(user.uid);

      final recentlyViewedRef = userDoc.collection('RecentlyViewed').doc(sellPost.sellId);
      await recentlyViewedRef.set(sellPost.toMap()..['viewedAt'] = Timestamp.now()); // Map으로 변환하여 저장

      notifyListeners();
    } catch (e) {
      print('Error adding recently viewed post: $e');
    }
  }

  //최근 본 상품 가져오기
  Stream<List<SellPostModel>> get recentlyViewedStream {
    if (userKey.isEmpty) {
      return Stream.value([]);
    }

    return FirebaseFirestore.instance
        .collection('Users')
        .doc(userKey)
        .collection('RecentlyViewed')
        .orderBy('viewedAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return SellPostModel.fromSnapshot(doc);
      }).toList();
    });
  }
  //상품 찜하기
  Future<void> addItemToWishlist(SellPostModel sellPost) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      print('No user is currently logged in');
      return;
    }

    try {
      final firestore = FirebaseFirestore.instance;
      final userDoc = firestore.collection('Users').doc(user.uid);

      final recentlyViewedRef = userDoc.collection('FavoriteList').doc(sellPost.sellId);
      await recentlyViewedRef.set(sellPost.toMap()..['selectedAt'] = Timestamp.now()); // Map으로 변환하여 저장

      notifyListeners();
    } catch (e) {
      print('Error adding recently viewed post: $e');
    }
  }
  //찜상품 가져오기
  Stream<List<SellPostModel>> get favoriteListStream {
    if (userKey.isEmpty) {
      return Stream.value([]);
    }

    return FirebaseFirestore.instance
        .collection('Users')
        .doc(userKey)
        .collection('FavoriteList')
        .orderBy('selectedAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return SellPostModel.fromSnapshot(doc);
      }).toList();
    });
  }

  Future<void> createOrder(List<SellPostModel> sellPosts) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      print('No user is currently logged in');
      return;
    }

    try {
      final firestore = FirebaseFirestore.instance;
      final userDoc = firestore.collection('Users').doc(user.uid);

      final orderRef = userDoc.collection('Orders').doc();
      final orderId = orderRef.id;

      final int totalPrice = sellPosts.fold<int>(0, (int sum, SellPostModel post) {
        return sum + post.price.toInt();
      });

      await orderRef.set({
        'orderId': orderId,
        'date': Timestamp.now(),
        'status': '처리 중',
        'totalPrice': totalPrice,
      });

      // items를 서브컬렉션으로 저장
      for (var post in sellPosts) {
        await orderRef.collection('items').add({
          'sellId': post.sellId,
          'title': post.title,
          'img': post.img,
          'price': post.price,
          'marketId' : post.marketId,
          'reviewed' : false,
        });
      }

      await updateCart([]);

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
        marketId = data[KEY_USER_MARKETID] ?? '';
        reference = doc.reference;

        notifyListeners();
      }
    } catch (e) {
      print('Error fetching user data: $e');
    }
  }

  Stream<List<Map<String, dynamic>>> get cartStream {
    if (userKey.isEmpty) {
      return Stream.value([]);
    }

    return FirebaseFirestore.instance
        .collection('Users')
        .doc(userKey)
        .snapshots()
        .map((snapshot) {
      final data = snapshot.data() as Map<String, dynamic>?;
      final cartItems = data?[KEY_CART] as List<dynamic>? ?? [];
      return cartItems.map((item) => item as Map<String, dynamic>).toList();
    });
  }


  Future<void> removeCartItem(String itemId) async {
    try {
      final userDoc = FirebaseFirestore.instance.collection('Users').doc(userKey);

      final userSnapshot = await userDoc.get();
      final cartList = List<Map<String, dynamic>>.from(userSnapshot.data()?['cart'] ?? []);

      cartList.removeWhere((item) => item['sellId'] == itemId);

      await userDoc.update({'cart': cartList});

      cart = cartList;
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

  Future<void> clearCart() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      print('No user is currently logged in');
      return;
    }

    try {
      await FirebaseFirestore.instance.collection('Users').doc(user.uid).update({'cart': []});
      cart.clear();
      notifyListeners();
    } catch (e) {
      print('Error clearing cart: $e');
    }
  }

}
