import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MarketFeedPageView extends StatefulWidget {
  final String marketId;

  const MarketFeedPageView({super.key, required this.marketId});

  @override
  _MarketFeedPageViewState createState() => _MarketFeedPageViewState();
}

class _MarketFeedPageViewState extends State<MarketFeedPageView> {
  List<String> _feedPosts = [];

  // Firestore에서 데이터를 불러오는 함수
  Future<Map<String, dynamic>?> _getMarketData() async {
    try {
      DocumentSnapshot docSnapshot = await FirebaseFirestore.instance
          .collection('Markets')
          .doc(widget.marketId)
          .get();

      if (docSnapshot.exists) {
        var data = docSnapshot.data() as Map<String, dynamic>;
        _feedPosts = List<String>.from(data['feedPosts'] ?? []);
        return data;
      }
    } catch (e) {
      print('Error fetching market data: $e');
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>?>(
      future: _getMarketData(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError || !snapshot.hasData) {
          return Center(child: Text('데이터를 불러오는 중 오류가 발생했습니다.'));
        }

        var marketData = snapshot.data!;

        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.campaign_outlined),
                    SizedBox(width: 8),
                    Text('커뮤니티 | 공지사항', style: TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
                SizedBox(height: 8),
                // 판매자 정보 박스
                Container(
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.blue, width: 1.0),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('판매자 정보 확인', style: TextStyle(fontWeight: FontWeight.bold)),
                      SizedBox(height: 8),
                      _infoRow('대표자명', marketData['seller_name'] ?? 'N/A'),
                      _infoRow('상호명', marketData['name'] ?? 'N/A'),
                      _infoRow('문의전화', marketData['cs_phone'] ?? 'N/A'),
                      _infoRow('문의메일', marketData['email'] ?? 'N/A'),
                      _infoRow('사업자주소', marketData['address'] ?? 'N/A'),
                      SizedBox(height: 8),
                      // 사업자 등록 번호가 있을 경우에만 표시
                      if (marketData['business_number'] != null &&
                          marketData['business_number'].isNotEmpty)
                        _infoRow('사업자등록번호', marketData['business_number']),
                    ],
                  ),
                ),
                SizedBox(height: 16), // 파란 네모와 공지사항 리스트 사이 간격
                // 공지사항 리스트
                ..._feedPosts.asMap().entries.map((entry) {
                  int index = entry.key;
                  String post = entry.value;
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: Container(
                      padding: const EdgeInsets.all(8.0),
                      width: double.infinity, // 부모 위젯의 가로 길이를 채우도록 설정
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: Text(post, style: TextStyle(fontSize: 16)),
                    ),
                  );
                }).toList(),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _infoRow(String title, String value) {
    return Row(
      children: [
        Text(
          '$title  ',
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: Colors.grey[800],
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(color: Colors.black),
          ),
        ),
      ],
    );
  }
}
