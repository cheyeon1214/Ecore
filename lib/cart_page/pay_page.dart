import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';

import '../models/firestore/sell_post_model.dart';
import '../models/firestore/user_model.dart';
import '../my_page/my_address_form.dart';
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
  Map<String, dynamic>? _defaultAddress; // 기본 배송지 정보를 저장할 변수 추가

  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _pointController = TextEditingController(); // 포인트 입력용 컨트롤러

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
    _fetchDefaultAddress(); // 기본 배송지 정보 가져오기
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

  Future<void> _fetchDefaultAddress() async {
    if (user != null) {
      try {
        QuerySnapshot addressSnapshot = await FirebaseFirestore.instance
            .collection('Users')
            .doc(user!.uid)
            .collection('Addresses')
            .where('isDefault', isEqualTo: true)
            .get();

        if (addressSnapshot.docs.isNotEmpty) {
          setState(() {
            _defaultAddress = addressSnapshot.docs.first.data() as Map<String, dynamic>;
          });
        } else {
          setState(() {
            _defaultAddress = null; // 기본 배송지가 없을 경우
          });
        }
      } catch (e) {
        print("Error fetching default address: $e");
      }
    }
  }

  Future<void> getCartItems() async {
    try {
      // 선택된 cartItems를 그대로 사용하여 불러옵니다.
      List<Map<String, dynamic>> selectedCartItems = widget.cartItems;

      int totalPrice = 0;
      int donaCount = 0;
      int totalShippingFee = 0;
      Set<String> processedMarkets = {}; // 중복 마켓을 처리하기 위한 Set

      // 선택된 아이템들에 대해 총 상품 금액과 배송비를 계산
      for (var item in selectedCartItems) {
        int itemPrice = item['price'] ?? 0;

        totalPrice += itemPrice;
        if (item['donaId'] != null) {
          donaCount += 1;
        }

        // 배송비 계산
        final marketId = item['marketId'] ?? '';
        if (!processedMarkets.contains(marketId)) {
          processedMarkets.add(marketId);
          if (item['donaId'] != null) {
            totalShippingFee += 1000; // 기부글은 고정 배송비 1000원
          } else {
            totalShippingFee += (item['shippingFee'] as num).toInt() ?? 0;
          }
        }
      }

      setState(() {
        totalProductPrice = totalPrice; // 총 상품 가격
        donaQuantity = donaCount; // 기부 상품 수량
        remainingPrice = totalPrice + totalShippingFee; // 포인트 적용 전 결제 금액
        this.totalShippingFee = totalShippingFee; // 총 배송비 설정
      });
    } catch (e) {
      print("Failed to get selected cart items: $e");
    }
  }

  Future<void> _createOrder() async {
    final userModel = Provider.of<UserModel>(context, listen: false);

    Set<String> processedMarkets = {}; // 중복된 마켓에 대한 처리 방지

    try {
      // 기부글 및 판매글을 분리하여 처리
      for (var item in widget.cartItems) {
        final marketId = item['marketId'] ?? '';

        // 기부글 구매 시 DonaOrders에 추가
        if (item['donaId'] != null) {
          // 구매하는 사람의 marketId를 Users 컬렉션에서 가져옵니다.
          final DocumentSnapshot userDoc = await FirebaseFirestore.instance
              .collection('Users')
              .doc(user!.uid)  // 구매자의 uid를 사용
              .get();

          final String buyerMarketId = userDoc['marketId'];  // 구매자의 marketId

          if (buyerMarketId.isNotEmpty) {
            final donaPostRef = FirebaseFirestore.instance
                .collection('Markets')
                .doc(buyerMarketId)  // 구매자의 marketId 사용
                .collection('DonaOrders');

            await donaPostRef.add({
              'userId': user!.uid,
              'username': username,
              'donaId': item['donaId'],
              'title': item['title'],
              'price': item['price'],
              'date': FieldValue.serverTimestamp(),
              'paymentMethod': _selectedPaymentMethod,
              'donaImg' : item['img'],
            });
          }
        }

        // 판매글 구매 시
        if (item['sellId'] != null && marketId.isNotEmpty) {
          // Users/{userId}/Orders에 판매글 구매 내역 저장
          DocumentReference userOrderRef = await FirebaseFirestore.instance
              .collection('Users')
              .doc(user!.uid)
              .collection('Orders')
              .add({
            'orderId': item['sellId'],
            'totalPrice': totalProductPrice + totalShippingFee - usedPoints,
            'paymentMethod': _selectedPaymentMethod,
            'date': FieldValue.serverTimestamp(),
            'shippingStatus': '배송 준비',
          });

          await userOrderRef.collection('items').add(item); // Users/{userId}/Orders/{orderId}/items에 아이템 추가

          // 마켓의 SellOrders에 추가
          if (!processedMarkets.contains(marketId)) {
            final sellOrderRef = FirebaseFirestore.instance.collection('Markets').doc(marketId).collection('SellOrders');

            await sellOrderRef.add({
              'buyerId': user!.uid,
              'username': username,
              'sellId': item['sellId'],
              'title': item['title'],
              'price': item['price'],
              'date': FieldValue.serverTimestamp(),
              'shippingStatus': '배송 준비',
              'paymentMethod': _selectedPaymentMethod,
              'sellImg' : item['img'],
            });

            processedMarkets.add(marketId); // 이미 처리된 마켓은 다시 추가하지 않음
          }
        }
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
                _buildDefaultAddressSection(), // 기본 배송지 섹션 추가
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

  void _showAddressSelectionDialog() async {
    List<Map<String, dynamic>> addresses = await _fetchSavedAddresses();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: Text('배송지 정보'),
          content: SingleChildScrollView  (
            child: Column(
              children: addresses.map((address) {
                return ListTile(
                  title: Text('${address['recipient']}'),
                  subtitle: Text('${address['address']} ${address['detailAddress'] ?? ''}'),
                  trailing: Radio(
                    value: address,
                    groupValue: _defaultAddress, // 현재 선택된 배송지
                    onChanged: (value) {
                      setState(() {
                        _defaultAddress = value as Map<String, dynamic>; // 선택된 배송지 업데이트
                      });
                      Navigator.of(context).pop(); // 다이얼로그 닫기
                    },
                  ),
                );
              }).toList(),
            ),
          ),
          actions: [
            TextButton(
              child: Text('취소'),
              onPressed: () {
                Navigator.of(context).pop(); // 다이얼로그 닫기
              },
            ),
          ],
        );
      },
    );
  }

  Future<List<Map<String, dynamic>>> _fetchSavedAddresses() async {
    if (user != null) {
      try {
        QuerySnapshot addressSnapshot = await FirebaseFirestore.instance
            .collection('Users')
            .doc(user!.uid)
            .collection('Addresses')
            .get();

        return addressSnapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
      } catch (e) {
        print("Error fetching saved addresses: $e");
      }
    }
    return [];
  }

  Widget _buildDefaultAddressSection() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('Users')
          .doc(user!.uid)
          .collection('Addresses')
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('오류가 발생했습니다.'));
        }

        final addresses = snapshot.data!.docs;
        if (addresses.isNotEmpty) {
          _defaultAddress = addresses.first.data() as Map<String, dynamic>;

          return Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${_defaultAddress?['recipient'] ?? '수령인 없음'}',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: GestureDetector(
                        onTap: _showAddressSelectionDialog,
                        child: Text(
                          '배송지 변경',
                          style: TextStyle(fontSize: 14, color: Colors.black),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10),
                Text(
                  '${_defaultAddress?['address'] ?? '주소 없음'} ${_defaultAddress?['detailAddress'] ?? ''}',
                  style: TextStyle(fontSize: 16),
                ),
                SizedBox(height: 5),
                Text(
                  _formatPhoneNumber(_defaultAddress?['phone'] ?? ''), // 포맷된 전화번호 사용
                  style: TextStyle(fontSize: 16),
                ),
                SizedBox(height: 10),
              ],
            ),
          );
        } else {
          return Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Text(
                    '저장된 배송지가 없습니다.',
                    style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                    textAlign: TextAlign.center,
                  ),
                ),
                SizedBox(height: 10),
                Center(
                  child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: ElevatedButton(
                      onPressed: () {
                        _navigateToAddAddress();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        side: BorderSide(color: Colors.grey),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: Text('+ 배송지 추가하기', style: TextStyle(fontSize: 16, color: Colors.black)),
                    ),
                  ),
                ),
              ],
            ),
          );
        }
      },
    );
  }

// 전화번호 포맷팅 메서드
  String _formatPhoneNumber(String phoneNumber) {
    if (phoneNumber.length == 11) {
      return '${phoneNumber.substring(0, 3)}-${phoneNumber.substring(3, 7)}-${phoneNumber.substring(7)}';
    }
    return phoneNumber; // 길이가 11이 아닐 경우 원래 전화번호 반환
  }



// 배송지 추가 페이지로 이동하는 메서드
  void _navigateToAddAddress() {
    // 배송지 추가 페이지로 이동하는 로직 추가
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AddressForm()), // AddAddressPage는 배송지 추가 페이지입니다.
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

  Widget _buildOrderSummary() {
    if (widget.cartItems.isEmpty) {
      return Center(child: Text('주문할 상품이 없습니다.'));
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
    if (widget.cartItems.isEmpty) {
      return [
        Center(
          child: Text('주문할 상품이 없습니다.'),
        ),
      ];
    }

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
    }).toList();
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
