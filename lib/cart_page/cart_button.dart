import 'package:flutter/material.dart';
import '../cosntants/firestore_key.dart';
import '../models/firestore/sell_post_model.dart';
import '../models/firestore/user_model.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../repo/order_network_repo.dart';
import 'order_list.dart';

class CartBtn extends StatefulWidget {
  const CartBtn({super.key});

  @override
  State<CartBtn> createState() => _CartBtnState();
}

class _CartBtnState extends State<CartBtn> {
  final OrderNetworkRepository _orderRepository = OrderNetworkRepository();

  @override
  Widget build(BuildContext context) {
    final userModel = Provider.of<UserModel>(context);
    int totalPrice = userModel.cart.fold(0, (sum, item) {
      return sum + (item['price'] as int);
    });
    final isCartEmpty = userModel.cart.isEmpty;

    return Align(
      alignment: Alignment.bottomCenter,
      child: Padding(
        padding: const EdgeInsets.only(left: 40),
        child: FloatingActionButton.extended(
          onPressed: isCartEmpty ? null : () async {
            try {
              final sellPosts = await Future.wait(
                  userModel.cart.map((item) async {
                    final sellPostRef = FirebaseFirestore.instance.collection(
                        COLLECTION_SELL_PRODUCTS).doc(item['sellId']);
                    final snapshot = await sellPostRef.get();

                    if (snapshot.exists) {
                      final data = snapshot.data() as Map<String, dynamic>?;

                      if (data != null) {
                        return SellPostModel.fromMap(
                            data, item['sellId'], reference: snapshot
                            .reference);
                      }
                    }
                    throw Exception('Sell post not found');
                  }));

              await _orderRepository.createOrder(sellPosts, userModel.userKey);

              userModel.cart.clear();
              userModel.updateCart(userModel.cart);

              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const OrderList()),
              );
            } catch (e) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Error: $e')),
              );
            }
          },
          label: Text(
              '총 금액 : ${totalPrice}      주문하기', style: TextStyle(fontSize: 15)),
          backgroundColor: Colors.blue[50],
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
      ),
    );
  }
}
