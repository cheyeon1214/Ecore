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
        print('Current User ID: ${user.uid}'); // 현재 로그인한 사용자의 UID를 출력
        print('Current User Email: ${user.email}'); // 현재 로그인한 사용자의 이메일을 출력
        userModel.fetchUserData(user.uid);
      } else {
        print('No user is currently logged in'); // 로그인된 사용자가 없을 경우 출력
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
              return ListTile(
                leading: Image.network(
                  cartItem['img'] ?? 'https://via.placeholder.com/150',
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
