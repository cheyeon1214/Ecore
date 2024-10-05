import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';

import '../models/firestore/sell_post_model.dart';
import '../models/firestore/user_model.dart';
import 'order_list.dart';

class PayPage extends StatefulWidget {
  final List<Map<String, dynamic>> cartItems;

  PayPage({Key? key, required this.cartItems}) : super(key: key);

  @override
  State<PayPage> createState() => _PayPageState();
}

class _PayPageState extends State<PayPage> {
  int totalShippingFee = 0; // 배송비 변수 추가
  int? _selectedSavedInfoIndex; // 추가: 변수를 선언하고 초기화

  final user = FirebaseAuth.instance.currentUser;
  String? username;
  Map<String, dynamic>? latestOrder;

  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _pointController = TextEditingController(); // 포인트 입력용 컨트롤러

  String? _phoneNumber;
  String? _address;
  List<Map<String, String>> _savedInfo = [];
  String _selectedPaymentMethod = '계좌 간편결제';
  bool _isChecked = false;
  int totalProductPrice = 0;
  int donaQuantity = 0; // 기부글 수량
  Set<String> processedMarkets = {}; // 이미 처리된 마켓을 저장하는 Set
  int usedPoints = 0; // 사용된 포인트
  int userPoints = 0; // 유저가 보유한 포인트
  int remainingPrice = 0; // 포인트 적용 후 남은 결제 금액
  int discount = 0; // 할인 금액

  @override
  void initState() {
    super.initState();
    _fetchUsername();
    _fetchUserPoints();
    getCartItems();
  }

  Future<void> _fetchUsername() async {
    if (user != null) {
      try {
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('Users')
            .doc(user!.uid)
            .get();

        setState(() {
          username = userDoc['username'] ?? "No username";
          userPoints = userDoc['points'] ?? 0; // 보유 포인트 가져오기
        });

      } catch (e) {
        print("Error fetching username: $e");
        setState(() {
          username = "Error loading username";
        });
      }
    }
  }

  Future<void> _fetchUserPoints() async {
    if (user != null) {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('Users')
          .doc(user!.uid)
          .get();
      setState(() {
        userPoints = userDoc['points'] ?? 0; // 유저의 보유 포인트 가져오기
      });
    }
  }

  Future<void> getCartItems() async {
    try {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('Users')
          .doc(user!.uid)
          .get();

      if (userDoc.exists) {
        List<dynamic> cartItems = userDoc.get('cart');
        int totalPrice = 0;
        int donaCount = 0;
        for (var item in cartItems) {
          int itemPrice = item['price'] ?? 0;
          int itemQuantity = item['quantity'] ?? 1;

          totalPrice += itemPrice * itemQuantity;
          if (item['donaId'] != null) {
            donaCount += 1;
          }
        }
        setState(() {
          latestOrder = {
            ...userDoc.data() as Map<String, dynamic>,
            'items': cartItems,
          };
          totalProductPrice = totalPrice;
          donaQuantity = donaCount; // 기부 상품 수량
          remainingPrice = totalPrice; // 포인트 적용 전 결제 금액
        });
      } else {
        print("User document does not exist.");
      }
    } catch (e) {
      print("Failed to get cart items: $e");
    }
  }

  Future<void> _createOrder() async {
    final userModel = Provider.of<UserModel>(context, listen: false);
    final sellPosts = widget.cartItems.map((item) {
      final sellPostRef = FirebaseFirestore.instance
          .collection('SellPosts')
          .doc(item['sellId']);

      return SellPostModel(
        sellId: item['sellId'] ?? '',
        marketId: item['marketId'] ?? '',
        title: item['title'] ?? 'Untitled',
        img: (item['img'] as List<dynamic>?)?.cast<String>() ?? ['https://via.placeholder.com/150'],
        price: item['price'] ?? 0,
        category: item['category'] ?? '기타',
        body: item['body'] ?? '내용 없음',
        createdAt: (item['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
        viewCount: item['viewCount'] ?? 0,
        shippingFee: item['shippingFee'] ?? 0, // 배송비
        reference: sellPostRef,
        stock: item['sellId'] ?? '',
      );
    }).toList();

    // 이미 처리된 마켓을 추적하여 중복 배송비 방지
    Set<String> processedMarkets = {}; // 마켓 ID를 저장할 Set

    // 배송비를 포함한 총 금액 계산
    int totalShippingFee = widget.cartItems.fold<int>(0, (int sum, item) {
      final marketId = item['marketId'] ?? '';

      if (processedMarkets.contains(marketId)) {
        return sum; // 이미 처리된 마켓은 배송비 추가하지 않음
      }

      processedMarkets.add(marketId); // 마켓 ID 추가

      if (item['donaId'] != null) {
        return sum + 1000; // 기부글은 배송비 1000원
      } else {
        return sum + ((item['shippingFee'] ?? 0) as num).toInt(); // 일반 상품의 배송비 계산
      }
    });

    int totalPriceWithShipping = totalProductPrice + totalShippingFee;

    try {
      // 주문 정보를 Orders 컬렉션에 저장
      DocumentReference orderRef = await FirebaseFirestore.instance.collection('Orders').add({
        'userId': user!.uid,
        'username': username,
        'date': FieldValue.serverTimestamp(),
        'totalPrice': totalPriceWithShipping - usedPoints, // 포인트 차감 후 총 결제 금액
        'paymentMethod': _selectedPaymentMethod,
        'address': _address ?? '주소 없음',
        'phoneNumber': _phoneNumber ?? '전화번호 없음',
        'shippingStatus': '배송 준비', // 배송 상태 추가
      });

      // 주문 정보를 Users 컬렉션의 orders 서브컬렉션에 저장
      DocumentReference userOrderRef = await FirebaseFirestore.instance
          .collection('Users')
          .doc(user!.uid)
          .collection('Orders')
          .add({
        'orderId': orderRef.id, // Orders 컬렉션의 주문 ID
        'totalPrice': totalPriceWithShipping - usedPoints,
        'paymentMethod': _selectedPaymentMethod,
        'date': FieldValue.serverTimestamp(),
        'shippingStatus': '배송 준비',
      });

      // 각 orderId 아래 items 서브컬렉션에 아이템 추가
      for (var item in widget.cartItems) {
        await orderRef.collection('items').add(item); // Orders 컬렉션 안에 items 서브컬렉션 추가
        await userOrderRef.collection('items').add(item); // Users 컬렉션 안에 orders -> items 서브컬렉션 추가
      }

      // 포인트 사용 처리 (사용된 포인트 차감 및 기록)
      if (usedPoints > 0) {
        await FirebaseFirestore.instance.collection('Users').doc(user!.uid).update({
          'points': FieldValue.increment(-usedPoints), // 사용된 포인트 차감
        });

        // 포인트 사용 내역 기록
        await FirebaseFirestore.instance.collection('Users').doc(user!.uid).collection('PointHistory').add({
          'point': usedPoints,
          'timestamp': FieldValue.serverTimestamp(),
          'type': 'use', // 포인트 사용 기록
        });
      }

      // 포인트 적립 처리 (기부글 구매 시)
      for (var item in widget.cartItems) {
        if (item['donaId'] != null) {
          final donaPostRef = FirebaseFirestore.instance.collection('DonaPosts').doc(item['donaId']);
          final donaPostDoc = await donaPostRef.get();

          if (donaPostDoc.exists) {
            final donaUserId = donaPostDoc['userId'];
            final point = donaPostDoc['point'] ?? 0;

            // donaUser에게 포인트 추가
            final userRef = FirebaseFirestore.instance.collection('Users').doc(donaUserId);
            await userRef.update({
              'points': FieldValue.increment(point), // 포인트 증가
            });

            // 사용자 서브컬렉션에 포인트 기록 저장
            await userRef.collection('PointHistory').add({
              'point': point,
              'timestamp': FieldValue.serverTimestamp(),
              'type': 'earn' // 적립이라는 것을 구분하기 위한 필드
            });
          }
        }
      }

      // 카트 초기화
      await userModel.clearCart();

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }


  void _applyPoints() {
    int inputPoints = int.tryParse(_pointController.text) ?? 0;

    if (inputPoints > userPoints) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('사용할 수 있는 포인트를 초과했습니다.')),
      );
    } else if (inputPoints > remainingPrice) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('결제 금액을 초과하는 포인트를 사용할 수 없습니다.')),
      );
    } else {
      setState(() {
        usedPoints = inputPoints;
        discount = usedPoints; // 할인 금액에 사용한 포인트를 적용
        remainingPrice = totalProductPrice + totalShippingFee - usedPoints; // 포인트 적용 후 남은 금액
      });
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
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(55.0),
        child: AppBar(
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
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
                if (user != null) _buildUserInfo(),
                SizedBox(height: 10),
                _buildSavedInfo(),
                SizedBox(height: 10),
                _buildContactForm(),
                SizedBox(height: 10),
                _buildOrderSummary(),
                SizedBox(height: 10),
                _buildDiscountSection(),
                SizedBox(height: 10),
                _buildPaymentSection(),
                SizedBox(height: 10),
                _buildAgreementSection(),
                SizedBox(height: 10),
                _buildOrderButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAgreementSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        confirmAgree(),
        SizedBox(height: 5),
        Divider(color: Colors.black54, thickness: 1),
      ],
    );
  }

  Column confirmAgree() {
    return Column(
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
            Text("주문내용 확인 및 동의", style: TextStyle(fontSize: 17)),
          ],
        ),
        Text("(필수) 개인정보 수집-이용 동의", style: TextStyle(fontSize: 10)),
        Text("(필수) 개인정보 제3자 정보 제공 동의", style: TextStyle(fontSize: 10)),
      ],
    );
  }

  Widget _buildUserInfo() {
    return Text(
      '${username}',
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _buildSavedInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List<Widget>.generate(_savedInfo.length, (index) {
        final info = _savedInfo[index];
        return RadioListTile<int>(
          value: index,
          groupValue: _selectedSavedInfoIndex, // 선택된 인덱스와 비교
          onChanged: (int? value) {
            setState(() {
              _selectedSavedInfoIndex = value; // 인덱스 업데이트
            });
          },
          title: Text(
            '전화번호: ${info['phone']}, 배송지: ${info['address']}',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
        );
      }),
    );
  }

  Widget _buildContactForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            ElevatedButton(
              onPressed: _saveInfo,
              child: Text("등록"),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildOrderSummary() {
    if (latestOrder == null) {
      return Center(child: Text('최신 주문 정보가 없습니다.'));
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Divider(color: Colors.blue[100], thickness: 3),
        Text(
          '주문 상품',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 10),
        ..._buildOrderItems(),
        SizedBox(height: 15),
        _buildPriceSummary(),
      ],
    );
  }

  List<Widget> _buildOrderItems() {
    return widget.cartItems.map((item) {
      final imageUrl =
          (item['img'] as List<dynamic>?)?.first ??
              'https://via.placeholder.com/150';
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 4.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.network(
              imageUrl,
              height: 100,
              width: 100,
              fit: BoxFit.cover,
            ),
            SizedBox(width: 15),
            Expanded(
              child: Text(
                '상품명: ${item['title']}  가격: ${item['price']}원',
                style: TextStyle(fontSize: 14),
              ),
            ),
          ],
        ),
      );
    }).toList() ?? [];
  }

  Widget _buildPriceSummary() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildPriceRow('상품 금액', totalProductPrice),
        SizedBox(height: 10),
        _buildPriceRow('배송비', totalShippingFee), // 배송비 표시
        SizedBox(height: 10),
        _buildPriceRow('할인 금액', discount), // 할인 금액 (포인트 적용 후)
        SizedBox(height: 10),
        Divider(color: Colors.black54, thickness: 1),
        SizedBox(height: 10),
        _buildPriceRow('총 결제 금액', remainingPrice), // 포인트 적용 후 총 결제 금액
      ],
    );
  }

  Widget _buildPriceRow(String label, int amount) {
    return Row(
      children: [
        Expanded(
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(label),
          ),
        ),
        Expanded(
          child: Align(
            alignment: Alignment.centerRight,
            child: Text('${amount}원'),
          ),
        ),
      ],
    );
  }

  Widget _buildDiscountSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Divider(color: Colors.blue[100], thickness: 3),
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
            Text('포인트'),
            Expanded(
              child: Center(
                child: Container(
                  width: 150,
                  height: 30,
                  child: TextField(
                    controller: _pointController, // 포인트 입력 필드 컨트롤러
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
                  onPressed: _applyPoints, // 포인트 적용 버튼
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(
                      color: Colors.black,
                    ),
                  ),
                  child: Text('적용'),
                ),
                Text(
                  '보유: ${userPoints}P', // 보유 포인트 표시
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[700],
                  ),
                ),
              ],
            )
          ],
        ),
      ],
    );
  }

  Widget _buildPaymentSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Divider(color: Colors.blue[100], thickness: 3),
        Text(
          '결제 수단',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 10),
        payType(),
      ],
    );
  }

  Column payType() {
    return Column(
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
        Divider(color: Colors.blue[100], thickness: 3),
      ],
    );
  }

  Widget _buildOrderButton() {
    return Container(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: () async {
          if (_isChecked) {
            await _createOrder();
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => OrderList()),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('주문 내용을 확인하고 동의해야 합니다.')),
            );
          }
        },
        style: OutlinedButton.styleFrom(
          backgroundColor: Colors.blue[100],
          side: BorderSide.none,
        ),
        child: Text(
          '주문',
          style: TextStyle(color: Colors.black87, fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _addressController.dispose();
    _pointController.dispose(); // 포인트 입력 컨트롤러 dispose
    super.dispose();
  }
}
