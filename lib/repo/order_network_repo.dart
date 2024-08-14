import '../cosntants/firestore_key.dart';
import '../models/firestore/order_model.dart';
import '../models/firestore/sell_post_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class OrderNetworkRepository {
  Future<void> createOrder(List<SellPostModel> sellPosts, String userId) async {
    final orderRef = FirebaseFirestore.instance.collection(COLLECTION_ORDERS).doc();
    final orderId = orderRef.id;

    int totalPrice = 0;
    List<OrderItem> items = [];

    for (var post in sellPosts) {
      totalPrice += post.price;
      items.add(OrderItem(
        itemId: post.sellId,
        title: post.title,
        img: post.img,
        price: post.price,
        quantity: 1,
      ));
    }

    final orderData = {
      'orderId': orderId,
      'date': Timestamp.now(),
      'status': '처리 중',
      'totalPrice': totalPrice,
      'items': items.map((item) => item.toMap()).toList(),
    };

    await orderRef.set(orderData);
  }
}
