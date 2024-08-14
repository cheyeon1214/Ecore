import 'package:flutter/material.dart';

import '../cosntants/firestore_key.dart';
import '../models/firestore/order_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class OrderList extends StatelessWidget {
  const OrderList({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('주문 내역'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection(COLLECTION_ORDERS).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data?.docs.isEmpty == true) {
            return Center(child: Text('No orders found.'));
          }

          final orders = snapshot.data!.docs.map((doc) {
            return OrderModel.fromSnapshot(doc);
          }).toList();

          return ListView.builder(
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final order = orders[index];
              return ListTile(
                title: Row(
                  children: [
                    Text('주문번호 : ${order.orderId}',style: TextStyle(fontSize: 12),),
                    // Text('date : ${order.date.toDate()}', style: TextStyle(fontSize: 10)),
                  ],
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: order.items.map((item) {
                    return ListTile(
                      leading: Image.network(
                        item.img,
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                      ),
                      title: Text(item.title),
                      subtitle: Text('Price: ${item.price} x ${item.quantity}'),
                      contentPadding: EdgeInsets.zero,
                    );
                  }).toList(),
                ),
                trailing: Text('Total Price: ${order.totalPrice}'),
                onTap: () {
                  // Add any action you want on tap
                },
              );
            },
          );
        },
      ),
    );
  }
}
