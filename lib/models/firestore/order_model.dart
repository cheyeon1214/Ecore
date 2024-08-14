import '../../cosntants/firestore_key.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class OrderModel {
  final String orderId;
  final Timestamp date;
  final String status;
  final int totalPrice;
  final List<OrderItem> items;
  final DocumentReference reference;

  OrderModel.fromMap(Map<String, dynamic> map, {required this.reference})
      : orderId = map[KEY_ORDERID] ?? '',
        date = map[KEY_ORDERDATE] ?? Timestamp.now(),
        status = map[KEY_ORDERSTATUS] ?? '처리 중',
        totalPrice = (map[KEY_TOTALPRICE] as num).toInt() ?? 0,
        items = (map[KEY_ITEMS] as List<dynamic>?)
            ?.map((item) => OrderItem.fromMap(item as Map<String, dynamic>))
            .toList() ?? [];

  factory OrderModel.fromSnapshot(DocumentSnapshot snapshot) {
    return OrderModel.fromMap(snapshot.data() as Map<String, dynamic>, reference: snapshot.reference);
  }

  @override
  String toString() {
    return 'OrderModel{orderId: $orderId, date: $date, status: $status, totalPrice: $totalPrice, items: $items}';
  }
}

class OrderItem {
  final String itemId;
  final String title;
  final String img;
  final int price;
  final int quantity;

  OrderItem({
    required this.itemId,
    required this.title,
    required this.img,
    required this.price,
    required this.quantity,
  });

  factory OrderItem.fromMap(Map<String, dynamic> map) {
    return OrderItem(
      itemId: map[KEY_ITEMID] ?? '',
      title: map[KEY_ORDERTITLE] ?? 'Unknown Title',
      img: map[KEY_ORDERIMG] ?? 'https://via.placeholder.com/150',
      price: (map[KEY_ORDERPRICE] as num?)?.toInt() ?? 0,
      quantity: (map[KEY_ITEMQUANTITY] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      KEY_ITEMID: itemId,
      KEY_ORDERTITLE: title,
      KEY_ORDERIMG: img,
      KEY_ORDERPRICE: price,
      KEY_ITEMQUANTITY: quantity,
    };
  }
}
