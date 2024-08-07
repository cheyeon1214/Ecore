import 'package:ecore/CartPage/cart_list.dart';
import 'package:flutter/material.dart';

class CartBanner extends StatelessWidget {

  const CartBanner({super.key});

  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Row(
            children: [
              Expanded(
                  child: Text('ecore')
              ),
            ],
          ),
        ),
        body: CartList(),
    );
  }
}
