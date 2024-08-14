import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/firestore/user_model.dart';
import '../repo/order_network_repo.dart';
import '../models/firestore/sell_post_model.dart';
import 'order_list.dart';

class CartBtn extends StatefulWidget {
  const CartBtn({super.key});

  @override
  State<CartBtn> createState() => _CartBtnState();
}

class _CartBtnState extends State<CartBtn> {
  @override
  Widget build(BuildContext context) {
    final userModel = Provider.of<UserModel>(context);

    // Calculate total price and handle potential null values
    int totalPrice = userModel.cart.fold(0, (sum, item) {
      final price = item['price'] as int?;
      final quantity = item['quantity'] as int? ?? 1; // Default to 1 if quantity is null
      return sum + (price ?? 0) * quantity;
    });

    final isCartEmpty = userModel.cart.isEmpty;

    return Align(
      alignment: Alignment.bottomCenter,
      child: Padding(
        padding: const EdgeInsets.only(left: 40),
        child: FloatingActionButton.extended(
          onPressed: isCartEmpty ? null : () async {
            try {
              // Save the order to user's orders collection
              await userModel.createOrder(userModel.cart);

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
              '총 금액 : ${totalPrice}원  주문하기', style: TextStyle(fontSize: 15)),
          backgroundColor: Colors.blue[50],
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
      ),
    );
  }
}
