import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ecore/models/firestore/user_model.dart';
import 'cart_button.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CartList extends StatelessWidget {
  const CartList({super.key});

  @override
  Widget build(BuildContext context) {
    final userModel = Provider.of<UserModel>(context);

    // Fetch user data if userKey is empty
    if (userModel.userKey.isEmpty) {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        userModel.fetchUserData(user.uid);
      }
    }

    return Scaffold(
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: userModel.cartStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final cartItems = snapshot.data ?? [];

          if (cartItems.isEmpty) {
            return Center(child: Text('장바구니가 비어있습니다.'));
          }

          return ListView.builder(
            itemCount: cartItems.length,
            itemBuilder: (context, index) {
              final cartItem = cartItems[index];
              String imageUrl;

              // img 필드가 리스트인지 확인하고 첫 번째 이미지를 사용
              if (cartItem['img'] is List<dynamic> && cartItem['img'].isNotEmpty) {
                imageUrl = cartItem['img'][0]; // 첫 번째 이미지를 가져옴
              } else if (cartItem['img'] is String) {
                imageUrl = cartItem['img'];
              } else {
                imageUrl = 'https://via.placeholder.com/150'; // 기본 이미지
              }

              return ListTile(
                leading: Image.network(
                  imageUrl,
                  width: 50,
                  height: 50,
                  fit: BoxFit.cover,
                ),
                title: Text(cartItem['title'] ?? '제목 없음'),
                subtitle: Text('${cartItem['price']}원'),
                trailing: IconButton(
                  icon: Icon(Icons.remove_shopping_cart, color: Colors.red[300]),
                  onPressed: () {
                    userModel.removeCartItem(cartItem['sellId']);
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: CartBtn(),
    );
  }
}
