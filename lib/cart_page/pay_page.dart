import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PayPage extends StatefulWidget {
  const PayPage({Key? key}) : super(key: key);

  @override
  State<PayPage> createState() => _PayPageState();
}

class _PayPageState extends State<PayPage> {
  final user = FirebaseAuth.instance.currentUser;
  String? username;
  List<Map<String, dynamic>> cartItems = [];
  Map<String, dynamic>? latestOrder;

  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();

  String? _phoneNumber;
  String? _address;
  List<Map<String, String>> _savedInfo = [];

  @override
  void initState() {
    super.initState();
    _fetchUsername();
    _fetchLatestOrder();
  }

  Future<void> _fetchUsername() async {
    if (user != null) {
      try {
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('Users')
            .doc(user!.uid)
            .get();

        setState(() {
          username = userDoc['name'] ?? "No username";
        });
      } catch (e) {
        print("Error fetching username: $e");
        setState(() {
          username = "Error loading username";
        });
      }
    }
  }

  Future<List<Map<String, dynamic>>> _fetchOrderItems(String orderId) async {
    try {
      final orderItemsSnapshot = await FirebaseFirestore.instance
          .collection('Users')
          .doc(user!.uid)
          .collection('Orders')
          .doc(orderId)
          .collection('items')
          .get();

      return orderItemsSnapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();
    } catch (e) {
      print("Error fetching order items: $e");
      return [];
    }
  }

  Future<void> _fetchLatestOrder() async {
    if (user != null) {
      try {
        QuerySnapshot ordersSnapshot = await FirebaseFirestore.instance
            .collection('Users')
            .doc(user!.uid)
            .collection('Orders')
            .orderBy('date', descending: true)
            .limit(1)
            .get();

        if (ordersSnapshot.docs.isNotEmpty) {
          final latestOrderDoc = ordersSnapshot.docs.first;
          final orderId = latestOrderDoc.id;

          final items = await _fetchOrderItems(orderId);

          setState(() {
            latestOrder = {
              ...latestOrderDoc.data() as Map<String, dynamic>,
              'items': items,
            };
          });
        } else {
          setState(() {
            latestOrder = null;
          });
        }
      } catch (e) {
        print("Error fetching latest order: $e");
      }
    }
  }

  void _saveInfo() {
    if (_phoneNumber != null &&
        _phoneNumber!.isNotEmpty &&
        _address != null &&
        _address!.isNotEmpty) {
      setState(() {
        _savedInfo.add({'phone': _phoneNumber!, 'address': _address!});
        _phoneController.clear();
        _addressController.clear();
        _phoneNumber = '';
        _address = '';
      });
    }
  }

  Future<void> _refreshData() async {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    String _selectedPaymentMethod = '계좌 간편결제';
    bool _isChecked = false;

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(55.0),
        child: AppBar(
          automaticallyImplyLeading: false,
          flexibleSpace: Container(
            color: Colors.blue[200],
            child: Center(
              child: Text(
                "주문",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: SingleChildScrollView(
          physics: AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (user != null)
                  Text(
                    '$username',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                SizedBox(height: 10),
                ..._savedInfo.map((info) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: Text(
                      '전화번호: ${info['phone']}, 배송지: ${info['address']}',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                    ),
                  );
                }).toList(),
                SizedBox(height: 10),
                TextField(
                  controller: _phoneController,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: '전화번호를 입력해주세요.',
                  ),
                  maxLines: 1,
                  onChanged: (value) {
                    setState(() {
                      _phoneNumber = value;
                    });
                  },
                ),
                SizedBox(height: 10),
                TextField(
                  controller: _addressController,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: '배송지를 입력해주세요.',
                  ),
                  maxLines: 1,
                  onChanged: (value) {
                    setState(() {
                      _address = value;
                    });
                  },
                ),
                SizedBox(height: 10),
                ElevatedButton(
                  onPressed: _saveInfo,
                  child: Text("등록"),
                ),
                SizedBox(height: 10),
                if (latestOrder != null)
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '주문 상품',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 10),
                        ...(latestOrder!['items'] as List<dynamic>?)!
                            .map((item) {
                          final imageUrl =
                              (item['img'] as List<dynamic>?)?.first ??
                                  'https://via.placeholder.com/150';
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4.0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Image.network(
                                  imageUrl,
                                  height: 100, // Set the desired height
                                  width: 100, // Set the desired width
                                  fit: BoxFit.cover, // Cover the box, might crop the image
                                ),
                                SizedBox(width: 15),
                                Expanded(
                                  child: Text(
                                    '상품명: ${item['title']}, 가격: ${item['price']}',
                                    style: TextStyle(fontSize: 14),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList() ?? [],
                        SizedBox(height: 15),
                        Divider(color: Colors.blue[100], thickness: 2),
                        SizedBox(height: 10),
                        Text(
                          '할인 적용',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: Text('쿠폰'),
                              ),
                            ),
                            Expanded(
                              child: Align(
                                alignment: Alignment.centerRight,
                                child: Text('사용 가능한 쿠폰 3장'),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 10),
                        Row(
                          children: [
                            Text('포인트'),
                            Expanded(
                              child: Center(
                                child: Container(
                                  width: 150,
                                  height: 30,
                                  child: TextField(
                                    decoration: InputDecoration(
                                      border: OutlineInputBorder(),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Text('P'),
                            SizedBox(width: 8),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                OutlinedButton(
                                  onPressed: () {},
                                  style: OutlinedButton.styleFrom(
                                    side: BorderSide(
                                      color: Colors.black,
                                    ),
                                  ),
                                  child: Text('전액사용'),
                                ),
                                Text(
                                  '보유: 0P',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[700],
                                  ),
                                ),
                              ],
                            )
                          ],
                        ),
                        SizedBox(height: 10),
                        Divider(color: Colors.blue[100], thickness: 2),
                        SizedBox(height: 10),
                        Text(
                          '결제 금액',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: Text('상품 금액'),
                              ),
                            ),
                            Expanded(
                              child: Align(
                                alignment: Alignment.centerRight,
                                child: Text('0원'),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: Text('배송비'),
                              ),
                            ),
                            Expanded(
                              child: Align(
                                alignment: Alignment.centerRight,
                                child: Text('0원'),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: Text('할인 금액'),
                              ),
                            ),
                            Expanded(
                              child: Align(
                                alignment: Alignment.centerRight,
                                child: Text('0원'),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 10),
                        Divider(color: Colors.black54, thickness: 1),
                        SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: Text('총 결제 금액'),
                              ),
                            ),
                            Expanded(
                              child: Align(
                                alignment: Alignment.centerRight,
                                child: Text('0원'),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 10),
                        Divider(color: Colors.blue[100], thickness: 2),
                        SizedBox(height: 10),
                        Text(
                          '결제 수단',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ListTile(
                              title: Text('계좌 간편결제'),
                              leading: Radio<String>(
                                value: '계좌 간편결제',
                                groupValue: _selectedPaymentMethod,
                                onChanged: (String? value) {
                                  setState(() {
                                    _selectedPaymentMethod = value!;
                                  });
                                },
                              ),
                            ),
                            ListTile(
                              title: Text('일반 결제'),
                              leading: Radio<String>(
                                value: '일반 결제',
                                groupValue: _selectedPaymentMethod,
                                onChanged: (String? value) {
                                  setState(() {
                                    _selectedPaymentMethod = value!;
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 10),
                        Divider(color: Colors.blue[100], thickness: 2),
                        SizedBox(height: 10),
                        Divider(color: Colors.black54, thickness: 1),
                        SizedBox(height: 3),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Checkbox(
                                  value: _isChecked,
                                  onChanged: (bool? value) {
                                    setState(() {
                                      _isChecked = value ?? false;
                                    });
                                  },
                                ),
                                Text("주문내용 확인 및 동의", style: TextStyle(fontSize: 17),),
                              ],
                            ),
                            Text("(필수) 개인정보 수집-이용 동의", style: TextStyle(fontSize: 10),),
                            Text("(필수) 개인정보 제3자 정보 제공 동의", style: TextStyle(fontSize: 10),),
                          ],
                        ),
                        SizedBox(height: 5),
                        Divider(color: Colors.black54, thickness: 1),
                        SizedBox(height: 10),
                        Container(
                          width: double.infinity,
                          child: OutlinedButton(
                            onPressed: () {},
                            style: OutlinedButton.styleFrom(
                              backgroundColor: Colors.blue[100],
                              side: BorderSide.none,
                            ),
                            child: Text('주문', style: TextStyle(color: Colors.black87, fontSize: 16, fontWeight: FontWeight.bold),),
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  Center(child: Text('최신 주문 정보가 없습니다.')),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }
}
