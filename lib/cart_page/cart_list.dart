import 'package:ecore/models/firestore/user_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'cart_button.dart';

class CartList extends StatelessWidget {
  const CartList({super.key});

  @override
  Widget build(BuildContext context) {
    final userModel = Provider.of<UserModel>(context);

    return Scaffold(
      body: userModel.cart.isEmpty
          ? Center(child: Text('장바구니가 비어있습니다.'))
          : ListView.builder(
        itemCount: userModel.cart.length,
        itemBuilder: (context, index) {
          final cartItem = userModel.cart[index];
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
              icon: Icon(Icons.remove_shopping_cart, color: Colors.red[300],),
              onPressed: () {
                userModel.cart.removeAt(index);
                userModel.updateCart(userModel.cart);
              },
            ),
          );
        },
      ),
      floatingActionButton: CartBtn(),
    );
  }
}
