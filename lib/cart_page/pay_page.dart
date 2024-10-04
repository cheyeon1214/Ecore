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
  final user = FirebaseAuth.instance.currentUser;
  String? username;
  Map<String, dynamic>? latestOrder;

  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();

  String? _phoneNumber;
  String? _address;
  List<Map<String, String>> _savedInfo = [];
  String _selectedPaymentMethod = '계좌 간편결제';
  bool _isChecked = false;
  int totalProductPrice = 0;
  int? _selectedSavedInfoIndex;
  int donaQuantity = 0; // 친구 코드에서 추가된 필드

  @override
  void initState() {
    super.initState();
    _fetchUsername();
    getCartItems(); // 친구 코드에서 추가된 호출
  }

  // 유저 이름을 불러오는 함수
  Future<void> _fetchUsername() async {
    if (user != null) {
      try {
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('Users')
            .doc(user!.uid)
            .get();

        setState(() {
          username = userDoc['username'] ?? "No username";
        });
      } catch (e) {
        print("Error fetching username: $e");
        setState(() {
          username = "Error loading username";
        });
      }
    }
  }

  // 친구 코드에서 추가된 장바구니 아이템을 가져오는 함수
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
          donaQuantity = donaCount; // 기부 상품 수량을 계산
        });
      } else {
        print("User document does not exist.");
      }
    } catch (e) {
      print("Failed to get cart items: $e");
    }
  }

  // 주문을 생성하는 함수
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
        shippingFee: item['shippingFee'] ?? 0, // 배송비 추가
        reference: sellPostRef,
      );
    }).toList();

    // 배송비를 포함한 총 금액 계산
    int totalShippingFee = widget.cartItems.fold<int>(0, (int sum, item) {
      return sum + ((item['shippingFee'] ?? 0) as num).toInt(); // shippingFee가 num일 경우 int로 변환
    });
    int totalPriceWithShipping = totalProductPrice + totalShippingFee;

    try {
      // Orders 컬렉션에 저장
      await FirebaseFirestore.instance.collection('Orders').add({
        'userId': user!.uid,
        'username': username,
        'date': FieldValue.serverTimestamp(),
        'items': widget.cartItems,
        'totalPrice': totalPriceWithShipping, // 배송비 포함한 총 금액
        'paymentMethod': _selectedPaymentMethod,
        'address': _address ?? '주소 없음',
        'phoneNumber': _phoneNumber ?? '전화번호 없음',
        'shippingStatus': '배송 준비', // 배송 상태 추가
      });

      // 카트 초기화
      await userModel.clearCart();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  // 사용자 정보를 저장하는 함수
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

  // 화면 UI
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
                // SizedBox(height: 10),
                // _buildAgreementSection(),
                SizedBox(height: 10),
                _buildOrderButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // 사용자 이름을 보여주는 위젯
  Widget _buildUserInfo() {
    return Text(
      '${username}',
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  // 저장된 사용자 정보(배송지, 연락처)를 보여주는 위젯
  Widget _buildSavedInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List<Widget>.generate(_savedInfo.length, (index) {
        final info = _savedInfo[index];
        return RadioListTile<int>(
          value: index,
          groupValue: _selectedSavedInfoIndex,
          onChanged: (int? value) {
            setState(() {
              _selectedSavedInfoIndex = value;
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

  // 연락처 및 배송지 입력 폼
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

  // 주문 요약 부분
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

  // 주문 아이템을 보여주는 리스트
  List<Widget> _buildOrderItems() {
    return widget.cartItems.map((item) {
      final imageUrl =
          (item['img'] as List<dynamic>?)?.first ?? 'https://via.placeholder.com/150';
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

  // 가격 요약 부분
  Widget _buildPriceSummary() {
    // 총 배송비 계산
    int totalShippingFee = widget.cartItems.fold<int>(0, (int sum, item) {
      return sum + ((item['shippingFee'] ?? 0) as num).toInt(); // 배송비 계산
    });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildPriceRow('상품 금액', totalProductPrice),
        SizedBox(height: 10),
        _buildPriceRow('배송비', totalShippingFee), // 배송비 표시
        SizedBox(height: 10),
        _buildPriceRow('할인 금액', 0),
        SizedBox(height: 10),
        Divider(color: Colors.black54, thickness: 1),
        SizedBox(height: 10),
        _buildPriceRow('총 결제 금액', totalProductPrice + totalShippingFee), // 배송비 포함 총 금액
      ],
    );
  }

  // 가격 항목을 보여주는 행
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

  // 할인 섹션
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
      ],
    );
  }

  // 결제 수단 섹션
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

  // 결제 수단 선택 라디오 버튼
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

  // 동의 섹션
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

  // 주문 버튼
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
    super.dispose();
  }
}
