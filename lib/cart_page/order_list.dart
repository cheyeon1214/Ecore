import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class OrderList extends StatefulWidget {
  const OrderList({super.key});

  @override
  _OrderListState createState() => _OrderListState();
}

class _OrderListState extends State<OrderList> {
  String searchQuery = ''; // 검색어를 저장할 변수

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text('주문 내역'),
          leading: BackButton(),
        ),
        body: Center(child: Text('User not logged in')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('주문 내역'),
        leading: BackButton(),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: 16.0, vertical: 8.0), // 양쪽 간격을 더 띄우기 위해 수평 패딩을 변경
            child: SizedBox(
              height: 40, // 검색창의 높이를 조절
              child: TextField(
                decoration: InputDecoration(
                  hintText: '검색',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  contentPadding:
                      EdgeInsets.symmetric(vertical: 10), // 내부 텍스트 간격 조절
                ),
                  onChanged: (value) {
                    setState(() {
                      searchQuery = value; // 검색어를 업데이트
                    });
                  },
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('Users')
                  .doc(user.uid)
                  .collection('Orders')
                  .orderBy('date', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                if (!snapshot.hasData || snapshot.data?.docs.isEmpty == true) {
                  return Center(child: Text('주문 내역이 없습니다.'));
                }

                final orders = snapshot.data!.docs.map((doc) {
                  return doc.data() as Map<String, dynamic>;
                }).toList();

                // 검색어에 따라 주문 목록 필터링
                final filteredOrders = orders.where((order) {
                  return (order['items'] as List).any((item) {
                    return (item['title'] ?? '')
                        .toString()
                        .toLowerCase()
                        .contains(searchQuery.toLowerCase());
                  });
                }).toList();

                // 날짜별로 그룹화된 주문 데이터
                Map<String, List<Map<String, dynamic>>> groupedOrders = {};

                for (var order in filteredOrders) {
                  Timestamp timestamp = order['date'];
                  DateTime dateTime = timestamp.toDate();
                  String formattedDate =
                      DateFormat('yyyy-MM-dd').format(dateTime);

                  if (groupedOrders.containsKey(formattedDate)) {
                    groupedOrders[formattedDate]!.add(order);
                  } else {
                    groupedOrders[formattedDate] = [order];
                  }
                }

                return Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: ListView(
                    children: groupedOrders.keys.map((date) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _viewDate(date, groupedOrders[date]!),
                          ...groupedOrders[date]!.expand((order) {
                            return (order['items'] as List).map((item) {
                              final List<String> imageList = (item['img'] is List)
                                  ? (item['img'] as List<dynamic>).cast<String>()
                                  : [
                                      item['img'] ??
                                          'https://via.placeholder.com/150'
                                    ];

                              return _buildCard(imageList, item);
                            }).toList();
                          }).toList(),
                        ],
                      );
                    }).toList(),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Padding _buildCard(List<String> imageList, item) {
    return Padding(
      padding: const EdgeInsets.all(5.0),
      child: Card(
        color: Colors.white, // 내부 색상을 흰색으로 설정
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: Colors.grey, width: 1),
        ),
        elevation: 3,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _orderBox(imageList, item),
              SizedBox(height: 16),
              _createReview(),
            ],
          ),
        ),
      ),
    );
  }

  Padding _viewDate(String date, List<Map<String, dynamic>> orders) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Divider(
            color: Colors.grey,
            thickness: 3,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  date,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: TextButton(
                  onPressed: () {
                    // 주문 상세로 이동하는 로직 추가
                  },
                  child: Text(
                    '주문상세 >',
                    style: TextStyle(
                      color: Colors.blue,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  SizedBox _createReview() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          // 리뷰 작성 버튼 액션 추가
        },
        child: Text('리뷰 작성'),
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.black,
          backgroundColor: Colors.white,
          // 텍스트 색상
          side: BorderSide(color: Colors.grey, width: 2),
          // 테두리 설정
          padding: EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }

  Column _orderBox(List<String> imageList, item) {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8.0),
              child: Image.network(
                imageList.isNotEmpty
                    ? imageList[0]
                    : 'https://via.placeholder.com/150',
                width: 80,
                height: 80,
                fit: BoxFit.cover,
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item['title'] ?? '제목 없음',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    '가격: ${item['price']}원',
                    style: TextStyle(
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}
