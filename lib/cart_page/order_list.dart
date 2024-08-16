import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class OrderList extends StatelessWidget {
  const OrderList({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text('주문 내역'),
          leading: BackButton(), // Add a BackButton to the AppBar
        ),
        body: Center(child: Text('User not logged in')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('주문 내역'),
        leading: BackButton(), // Add a BackButton to the AppBar
      ),

      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('Users')
            .doc(user.uid)
            .collection('Orders')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data?.docs.isEmpty == true) {
            print('No data found: ${snapshot.connectionState}, ${snapshot.data?.docs}');
            return Center(child: Text('주문 내역이 없습니다.'));
          }

          final orders = snapshot.data!.docs.map((doc) {
            return doc.data() as Map<String, dynamic>;
          }).toList();

          return ListView.builder(
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final order = orders[index];

              return ListTile(
                title: Row(
                  children: [
                    Text('주문번호 : ${order['orderId']}', style: TextStyle(fontSize: 12)),
                  ],
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: (order['items'] as List).map((item) {
                    return ListTile(
                      leading: Image.network(
                        item['img'] ?? 'https://via.placeholder.com/150',
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                      ),
                      title: Text(item['title'] ?? '제목 없음'),
                      subtitle: Text('Price: ${item['price']} x ${item['quantity']}'),
                      contentPadding: EdgeInsets.zero,
                    );
                  }).toList(),
                ),
                trailing: Text('Total Price: ${order['totalPrice']}'),
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
