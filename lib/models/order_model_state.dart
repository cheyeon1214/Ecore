import 'package:flutter/material.dart';
import 'firestore/order_model.dart';

class OrderModelState extends ChangeNotifier {
  OrderModel? _orderModel;

  OrderModel get orderModel => _orderModel!;

  set orderModel(OrderModel orderModel) {
    _orderModel = orderModel;
    notifyListeners();
  }
}