 import 'package:flutter/material.dart';

import 'cart_list.dart';

class CartBanner extends StatelessWidget {

  const CartBanner({super.key});

  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Row(
            children: [
              Expanded(
                  child: Text('장바구니')
              ),
            ],
          ),
        ),
        body: CartList(),
    );
  }
}
